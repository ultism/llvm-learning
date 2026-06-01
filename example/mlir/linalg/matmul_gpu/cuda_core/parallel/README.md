# parallel 路 —— `--convert-parallel-loops-to-gpu`（MLIR 官方的 parallel→GPU 映射）

> CUDA core(标量)路下的**两条子路之一**。总览(两条子路对比)见 [`../README.md`](../README.md);
> GPU 顶层见 [`../../README.md`](../../README.md);另一条 affine 子路见 [`../affine/`](../affine/README.md);张量核见 [`../../tensor_core/`](../../tensor_core/README.md)。
> **这条用 `scf.parallel` + 官方 `--convert-parallel-loops-to-gpu` 把并行维摊进网格;同样落到 CUDA core 的标量 `FMUL`/`FADD`,只是网格模型和 affine 路不同。**

和 `../affine/` 是**同一个手写源 `matmul.mlir`**(字节相同),换一条下降路:不走 `affine.for`,
而是 `--convert-linalg-to-parallel-loops` 先出 **`scf.parallel`**(MLIR 表达"这几维可并行"的标准构造),
再用专门的 **`--convert-parallel-loops-to-gpu`** 把它映射成 `gpu.launch`。这一对 pass(配 `--gpu-map-parallel-loops`)
是 MLIR **官方/规范**的 parallel→GPU 通路,`affine-for-to-gpu` 更像规整循环的便捷特例。

> 工具同 affine 路:自编 `mlir-opt`(`23.0.0git`,NVPTX)+ conda `ptxas`/`cuobjdump`(12.8),目标 **`sm_120`**。

## 一个曾经的坑:`--lower-affine` 必须在抽 kernel 之前

这条路我们最早试过、当场失败了:`gpu-module-to-binary` 报 `LLVM Translation failed ... unrealized_conversion_cast %.. = (i64)->index`。
根因不是路线错,而是 **`--convert-parallel-loops-to-gpu` 会往 kernel 体里插 `affine.apply`**(从 block id 反算原下标,见下 ②)。
要是不先把这些 `affine.apply` 用 `--lower-affine` 拆成 arith,它们一路漏到 NVVM,`reconcile` 又折不掉那对孤立的 index↔i64 cast,序列化就崩。
**把 `--lower-affine` 放在 `--gpu-kernel-outlining` 之前,kernel 内零残留 cast,这条官方路就通了。**

## 网格映射:并行维全变 block,每 block 一个线程

`--gpu-map-parallel-loops` 给 `scf.parallel` 的两维标上 block 映射,`--convert-parallel-loops-to-gpu` 落地:

| 维 | 在 GPU 上 | 网格 |
|---|---|---|
| m(`scf.parallel` 第 1 维)| **block.x**(`ctaid.x`,NVVM range `<0,4>`)| 4 个 block |
| n(`scf.parallel` 第 2 维)| **block.y**(`ctaid.y`,NVVM range `<0,16>`)| 16 个 block |
| k(内层 `scf.for`,归约)| kernel 内的**顺序循环** | — |
| 线程 | 全 1(`.maxntid 1, 1, 1`)| 每 block **1 个线程** |

> **和 `../affine/` 的差别一句话:两条都把 m 放 `block.x`,但 n 不同——**
> parallel 这条把 n 也变成一维 **block**(`block.y`),于是是 **4×16 个 block、每 block 1 线程**;
> affine 那条把 n 变成 **thread**(`thread.x`),于是是 **4 个 block、每 block 16 线程**。
> 两种都对、都落到标量 `FMUL/FADD`,只是"并行维该当 block 还是 thread"的选择不同。

## 路线与文件

```
matmul.mlir ──bufferize──▶ scf.parallel(m,n)+scf.for(k)
   ──gpu-map + convert-parallel-loops-to-gpu──▶ gpu.launch（m,n→blocks）
   ──lower-affine + 抽 kernel──▶ gpu.module ──scf→cf + gpu→nvvm──▶ NVVM
   ──attach-target + module-to-binary=isa──▶ PTX ──ptxas/cuobjdump──▶ SASS
```

| 文件 | 来历 | 内容 |
|---|---|---|
| `matmul.mlir` | **手写(与 affine/ 同源)** | tensor 版 `linalg.matmul` |
| `../../extract_ptx.py` | 手写工具(两路共用) | 从 `gpu.binary` 抠出干净 PTX |
| `matmul.parallel.mlir` | 生成 ① | **`scf.parallel(m,n)` 套 `scf.for(k)`**（本路特征形态）|
| `matmul.gpu-launch.mlir` | 生成 ② | `gpu.launch`(m,n→blocks),体内 `affine.apply` 反算下标 + `scf.for`(k)|
| `matmul.gpu-module.mlir` | 生成 ③ | host 的 `gpu.launch_func` + `gpu.module`/`gpu.func` |
| `matmul.nvvm.mlir` | 生成 ④ | kernel 降到 NVVM:`nvvm.read.ptx.sreg.ctaid.x/.y` |
| `matmul.ptx` | 生成 ⑤ | PTX 虚拟 ISA(`.target sm_120`,`.maxntid 1,1,1`)|
| `matmul.sass` | 生成 ⑥ | 真 Blackwell 机器码(`EF_CUDA_SM120`)|

`make artifacts` 一把出全部;`make clean` 只留 `matmul.mlir`。

## 六层逐个看

### ① scf.parallel（`matmul.parallel.mlir`）—— 本路的特征形态

`--convert-linalg-to-parallel-loops`。m、n 合成一个 **`scf.parallel`**(并行),k 是内层 `scf.for`(归约):

```mlir
scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c4, %c16) step (%c1, %c1) {  // m,n 可并行
  scf.for %arg5 = %c0 to %c8 step %c1 {                                    // k 归约
    %0 = memref.load %arg0[%arg3, %arg5]    // A[m,k]
    %1 = memref.load %arg1[%arg5, %arg4]    // B[k,n]
    %2 = memref.load %arg2[%arg3, %arg4]    // C[m,n]
    %3 = arith.mulf %0, %1 : f32
    %4 = arith.addf %2, %3 : f32
    memref.store %4, %arg2[%arg3, %arg4]
  }
  scf.reduce
}
```

对比 `../../../matmul/parallel_loops/`(CPU)：**完全同一个 `scf.parallel` 形态**——只是 CPU 那边单线程降级摊平成顺序 CFG,这里接着喂给 GPU 映射。

### ② gpu.launch:并行维摊进 blocks（`matmul.gpu-launch.mlir`）

`--gpu-map-parallel-loops --convert-parallel-loops-to-gpu`。注意 launch 体里多了 `affine.apply`——
从 block id 反算原下标(这就是上面那个坑的来源):

```mlir
%0 = affine.apply #map(%c4)[%c0, %c1]    // grid.x = 4
%1 = affine.apply #map(%c16)[%c0, %c1]   // grid.y = 16
gpu.launch blocks(%bx,%by,%bz) in (%gx=%0, %gy=%1, %gz=1) threads(...) in (1,1,1) {
  %m = affine.apply #map1(%bx)[%c1,%c0]  // 由 block.x 反算 m
  %n = affine.apply #map1(%by)[%c1,%c0]  // 由 block.y 反算 n
  scf.for %k = 0 to 8 { ... }
  gpu.terminator
}
```

### ③ 抽 kernel（`matmul.gpu-module.mlir`）

`--lower-affine`(**关键:拆掉 ② 里的 `affine.apply`**)+ `--gpu-kernel-outlining`。host 留 `gpu.launch_func`,
计算进 `gpu.module`/`gpu.func`。此后 kernel 内已无 `affine`、无残留 cast。

### ④ kernel 降到 NVVM（`matmul.nvvm.mlir`）

`--convert-scf-to-cf --convert-gpu-to-nvvm --reconcile-unrealized-casts`。block 坐标现形,带 range 标注:

```mlir
%.. = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 4>  : i32   // block.x —— 就是 m
%.. = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 16> : i32   // block.y —— 就是 n
```

**和 affine 路最直观的差别:那条读 `ctaid.x`+`tid.x`(block+thread);这条读 `ctaid.x`+`ctaid.y`(两个 block 维)。**

### ⑤ PTX（`matmul.ptx`，89 行）

`--nvvm-attach-target=chip=sm_120 --gpu-module-to-binary=format=isa`,抠成文本。`.maxntid 1,1,1` 点明每 block 1 线程;k 是**带回边的循环**(没展开):

```ptx
.maxntid 1, 1, 1
    mov.u32  %r1, %ctaid.y;     // n
    mov.u32  %r2, %ctaid.x;     // m
$L__BB0_2:                       // k 循环（rolled）
    ld.global.b32 %r3, [%rd26]; ld.global.b32 %r4, [%rd25];
    mul.rn.f32 %r5, %r3, %r4;  add.rn.f32 %r6, %r6, %r5;
    st.global.b32 [%rd6], %r6;
    ...
    @%p2 bra $L__BB0_2;          // 回边
```

> **和 affine 路的一个有趣反差**:affine 路的 PTX 里 K=8 被**完全展开**(8 组 `mul.rn`/`add.rn`,无回边),
> 这条却是 **rolled 循环**(1 组 + 回边)。实测两边在 **NVVM 层是一样的**(都 1 条 `llvm.fmul` + rolled),
> 所以展开与否纯粹是 **LLVM NVPTX 后端**对两种 IR 形态的循环展开启发式不同,**与 scf/affine 这层选择无关**。

### ⑥ SASS（`matmul.sass`，169 行）

`ptxas -arch=sm_120` → `cuobjdump -sass`。真 Blackwell 标量指令(`EF_CUDA_SM120`,`FMUL`/`FADD` 在 k 循环里)。

## 怎么跑

```sh
make artifacts   # ①~⑥ 全出（产物入库）
make parallel    # 只到 scf.parallel 特征形态
make ptx         # 只到 PTX
make sass        # 到 SASS（需要 ptxas/cuobjdump）
make clean       # 只留 matmul.mlir
```

## 注意

- 同 affine 路:**最朴素**映射,没 shared memory、没分块、没 tensor core,也没在卡上真跑(只到编译期产物)。
- 「每 block 1 线程」在真机上其实**很浪费**(一个 warp 只用 1 条 lane)——但它是 `convert-parallel-loops-to-gpu`
  不带额外 mapping 配置时的默认行为,作为"官方路长什么样"的演示足够。要更像样的网格得自己配 mapping 属性或换 tiling。
- `sm_120` 是本机 Blackwell;**不跨代比**。
