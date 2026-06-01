# matmul 走 GPU —— 同一个 linalg.matmul，这次降到 NVVM / PTX / SASS

前面 `matmul_hello_world/`、`matmul/` 都是把 `linalg.matmul` 降到 **CPU** 的 `.ll`。这个例子换目标:
**同一个手写源 `matmul.mlir`(从 hello_world 直接 cp),这次一路降到 GPU**——经 `gpu`→`nvvm` 方言,
最终出 **PTX(sm_120 虚拟 ISA)和 SASS(本机 Blackwell 真机器码)**,接回 `llvm/cuda/` 那条三层产物线。

> 工具仍是自编 `mlir-opt`(`23.0.0git`,后端含 **NVPTX**);PTX→SASS 用 conda 的 `ptxas`/`cuobjdump`(CUDA 12.8)。
> 目标 **`sm_120`**(本机 RTX 5060 Ti,Blackwell)。见仓库根 [AGENTS.md](../../../../AGENTS.md) 的「MLIR」「CUDA」小节。

## 一个核心转变:并行维不再是循环,而是「硬件网格坐标」

CPU 上 matmul 的 m、n 是**循环**(`matmul/` 里看得很清楚)。到 GPU,**m、n 这两层循环直接消失**,
摊进 launch 的网格里:每个线程靠读自己的 **blockIdx/threadIdx** 知道"我负责哪个 `C[m,n]`",
再各自顺序循环 k。这就是 CPU→GPU 的根本差别——**「遍历并行维的循环」换成「我是几号线程」**。

本例的映射(`--convert-affine-for-to-gpu`,`gpu-block-dims=1 gpu-thread-dims=1`):

| 维 | 在 GPU 上 | 网格 |
|---|---|---|
| m(第 1 层 affine.for)| **block.x**(blockIdx)| 4 个 block |
| n(第 2 层)| **thread.x**(threadIdx)| 每 block 16 线程 |
| k(第 3 层,归约)| 留作 kernel 内的**顺序循环** | — |

> 为什么用 `--convert-affine-for-to-gpu` 而不是 `parallel-loops` 那条:affine 循环本就是规整的完美嵌套,
> 这个 pass 直接把它映射成网格,**m→block、n→thread**(比 parallel 那条"两维全塞 block、每 block 1 线程"像样);
> 且降到 NVVM 时 kernel 内**不残留 `unrealized_conversion_cast`**,`gpu-module-to-binary` 能直接出 PTX。

## 路线与文件

```
matmul.mlir ──bufferize──▶ affine 循环 ──affine-for-to-gpu──▶ gpu.launch
   ──lower-affine + 抽 kernel──▶ gpu.module ──scf→cf + gpu→nvvm──▶ NVVM
   ──attach-target + module-to-binary=isa──▶ PTX ──ptxas/cuobjdump──▶ SASS
```

| 文件 | 来历 | 内容 |
|---|---|---|
| `matmul.mlir` | **手写(唯一源)** | tensor 版 `linalg.matmul`(与其它 matmul 例子同一个) |
| `extract_ptx.py` | 手写工具 | 从 `gpu.binary` 字符串里抠出干净 PTX(解 `\XX` 转义) |
| `matmul.gpu-launch.mlir` | 生成 ① | `gpu.launch`:m→block.x、n→thread.x,体内仍是 `affine.for`(k) |
| `matmul.gpu-module.mlir` | 生成 ② | host 的 `gpu.launch_func` + `gpu.module`/`gpu.func`(kernel 被抽出) |
| `matmul.nvvm.mlir` | 生成 ③ | kernel 降到 NVVM:`nvvm.read.ptx.sreg.ctaid.x/tid.x` |
| `matmul.ptx` | 生成 ④ | PTX 虚拟 ISA(`.target sm_120`) |
| `matmul.sass` | 生成 ⑤ | 真 Blackwell 机器码(`EF_CUDA_SM120`) |

`make artifacts` 一把出全部;`make clean` 只留 `matmul.mlir` / `extract_ptx.py`。

## 五层逐个看

### ① gpu.launch:循环变网格（`matmul.gpu-launch.mlir`）

`--convert-affine-for-to-gpu`。外两层 `affine.for`(m,n)被吃进 `gpu.launch` 的 blocks/threads 维,
k 留在体内:

```mlir
gpu.launch blocks(...) in (%arg9 = %0, ...) threads(...) in (%arg12 = %1, ...) {  // %0=4 个 block, %1=16 线程
  affine.for %arg15 = 0 to 8 {            // k 仍是顺序循环
    ... affine.load A/B/C ... mulf/addf ...
  }
  gpu.terminator
}
```

### ② 抽 kernel:host / device 切开（`matmul.gpu-module.mlir`）

`--lower-affine`(affine→scf/arith/memref)+ `--gpu-kernel-outlining`。launch 体被抽成独立 kernel:

```mlir
func.func @matmul(...) { ... gpu.launch_func @matmul_kernel::@matmul_kernel blocks in (...) threads in (...) args(...) }
gpu.module @matmul_kernel {                                  // device 侧
  gpu.func @matmul_kernel(...) kernel { ... }
}
```

host 只剩一句 `gpu.launch_func`(配网格维 + 传 memref 参数),真正的计算进了 `gpu.module`。

### ③ kernel 降到 NVVM:blockIdx/threadIdx 现形（`matmul.nvvm.mlir`）

`--convert-scf-to-cf --convert-gpu-to-nvvm --reconcile-unrealized-casts`。这步最能看出 GPU 味:

```mlir
%.. = nvvm.read.ptx.sreg.ctaid.x : i32   // blockIdx.x —— 就是 m
%.. = nvvm.read.ptx.sreg.tid.x   : i32   // threadIdx.x —— 就是 n
... llvm.fmul ... llvm.fadd ...          // 每个线程在 k 循环里做自己的乘加
```

**CPU 版要 `scf.for` 遍历 m、n;这里没有了——每个线程直接读 `ctaid.x`/`tid.x` 算出自己的 (m,n)。**

### ④ PTX:虚拟 ISA（`matmul.ptx`,104 行）

`--nvvm-attach-target=chip=sm_120 --gpu-module-to-binary=format=isa`,再用 `extract_ptx.py` 抠成干净文本:

```ptx
.version 8.7
.target sm_120
.visible .entry matmul_kernel(...)
    mov.u32  %r1, %ctaid.x;        // 读 blockIdx.x = m
    mov.u32  %r2, %tid.x;          // 读 threadIdx.x = n
    ... ld.global.b32 ...          // 读 A/B/C 元素
    mul.rn.f32 ... ;  add.rn.f32 ...   // K=8 被展开成 8 组乘加（未融合，因无 fast-math）
```

### ⑤ SASS:真机器码（`matmul.sass`,169 行）

`ptxas -arch=sm_120` → cubin → `cuobjdump -sass`。落到 Blackwell 真指令:

```
.headerflags  @"EF_CUDA_SM120 ..."
LDG.E ...        // 全局访存（17 条，k 展开后多次取 A/B）
FMUL R.., R.., R..    // 8 条
FADD R.., R.., R..    // 8 条
STG.E ...        // 写回 C（8 条）
```

## 怎么跑

```sh
make artifacts   # ①~⑤ 全出（产物入库）
make ptx         # 只到 PTX
make sass        # 到 SASS（需要 ptxas/cuobjdump）
make clean       # 只留 matmul.mlir / extract_ptx.py
```

## 注意 / 下一步

- 这是**最朴素**的映射:一个线程算一个 `C[m,n]`,k 顺序累加,**没用 shared memory、没分块、没 tensor core**。
  真正高性能的 GPU matmul 要 tile 到 shared memory、用 `nvgpu`/`mma`(tensor core)——可另开例子。
- 这里没做**host 侧运行**(没接 CUDA runtime / 没 `gpu-to-llvm` + JIT)。目标是把「linalg 怎么变成 GPU 代码」
  逐层看清,产物对齐 `llvm/cuda/` 的 PTX/SASS;真要在卡上跑是另一回事。
- `sm_120` 是本机 Blackwell;**不跨代比**(别拿 sm_90 之类对照),GPU 特性按本机这代来。
