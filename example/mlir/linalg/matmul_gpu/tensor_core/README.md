# tensor_core —— linalg.matmul 走 WMMA，一路到 `HMMA`

和隔壁 [`../cuda_core/`](../cuda_core/README.md) 是**同一个 `linalg.matmul`**,但这条路奔着 **tensor core** 去:
最终在 PTX 里出 `wmma.mma.sync`、在 SASS 里出 `HMMA`——真·张量核指令。

> 上一课结论是"没看到 mma,因为走的是标量、一线程一元素的朴素映射"。这条路就是补上那条:
> 用 transform 调度把 matmul 向量化成 `vector.contract`,再经 `gpu.subgroup_mma`→`nvvm.wmma` 落到 WMMA。

## 为什么不能直接复用 cuda_core 的源

tensor core 有硬性前提,逼着源就得换(这本身就是这条路最大的"不一样"):

| 前提 | tensor core 要的 | 所以这里 |
|---|---|---|
| 数据类型 | f16/bf16/tf32/int8 | **f16**(cuda_core 是 f32)|
| 形状 | 固定 WMMA tile | **16×16×16**(cuda_core 随意 4×8×16)|
| 并行粒度 | **warp 级**协作 | 包进 `gpu.launch`,**1 block × 32 线程 = 1 warp** 算一块 |
| 载体 | buffer | 直接 **memref**(不从 tensor 起步 bufferize)|

源拆成两个文件:`matmul.mlir`(干净 payload:gpu.launch 里一个 linalg.matmul)+ `schedule.mlir`
(transform 调度,用 `--transform-preload-library` 外挂进来,**这样产物里不带 transform 噪声**)。

## 关键一步:把 multi_reduction「抬」成 vector.contract

`transform.structured.vectorize` 默认只把 matmul 向量化到 **`vector.multi_reduction`**,
而 `convert-vector-to-gpu` 的 WMMA 转换只认 **`vector.contract`**。中间差的就是一组 **prepare patterns**:

```mlir
transform.apply_patterns.vector.reduction_to_contract   // ← multi_reduction → vector.contract（缺它整条链断在这）
transform.apply_patterns.vector.transfer_permutation_patterns
transform.apply_patterns.vector.lower_masked_transfers
```

漏了 `reduction_to_contract`,`convert-vector-to-gpu` 就一声不吭地什么都不转(我们就踩过这个坑)。

## 路线与文件

```
matmul.mlir(+schedule.mlir)
  ──transform 向量化+prepare──▶ vector.contract
  ──convert-vector-to-gpu──▶ gpu.subgroup_mma_*  ──gpu-kernel-outlining──▶ gpu.module
  ──gpu→nvvm──▶ nvvm.wmma.*  ──module-to-binary=isa──▶ PTX(wmma)  ──ptxas/cuobjdump──▶ SASS(HMMA)
```

| 文件 | 来历 | 内容 |
|---|---|---|
| `matmul.mlir` | **手写** | f16 16×16×16，linalg.matmul 包在 gpu.launch(1 warp) |
| `schedule.mlir` | **手写** | transform 调度(向量化 + prepare patterns) |
| `matmul.contract.mlir` | 生成 ① | `vector.contract`(16×16×16，f16) |
| `matmul.subgroup-mma.mlir` | 生成 ② | `gpu.subgroup_mma_load/compute/store` + `!gpu.mma_matrix<…,"AOp"/"BOp"/"COp">` |
| `matmul.gpu-module.mlir` | 生成 ③ | host `gpu.launch_func` + `gpu.module`/`gpu.func` |
| `matmul.nvvm.mlir` | 生成 ④ | `nvvm.wmma.load/mma/store` |
| `matmul.ptx` | 生成 ⑤ | `wmma.mma.sync.aligned…m16n16k16`(`.target sm_120`) |
| `matmul.sass` | 生成 ⑥ | `HMMA.16816.F16`(真 Blackwell) |

`make artifacts` 全出;`make clean` 只留 `matmul.mlir` / `schedule.mlir`(PTX 提取器在 `../extract_ptx.py`)。

## 六层逐个看

### ① vector.contract（`matmul.contract.mlir`）
向量化 + `reduction_to_contract`。matmul 变成一个 `vector.contract`(maps/iterator 就是 m,n 并行、k 归约),
操作数是 `vector<16x16xf16>`。这是"矩阵乘"在 vector 方言里的整块抽象,不再是逐元素循环。

### ② gpu.subgroup_mma（`matmul.subgroup-mma.mlir`）
`--convert-vector-to-gpu`。`vector.contract` 整块变成 WMMA 三件套 + 一个新类型 `!gpu.mma_matrix`:
```mlir
%a = gpu.subgroup_mma_load_matrix  ... : ... -> !gpu.mma_matrix<16x16xf16, "AOp">
%b = gpu.subgroup_mma_load_matrix  ... -> !gpu.mma_matrix<16x16xf16, "BOp">
%c = gpu.subgroup_mma_load_matrix  ... -> !gpu.mma_matrix<16x16xf16, "COp">
%r = gpu.subgroup_mma_compute %a, %b, %c   // 一个 op = 整块 16×16×16 的乘加
gpu.subgroup_mma_store_matrix %r, ...
```
`mma_matrix` 是**warp 持有的不透明片段(fragment)**——32 个线程各存一部分,你无法像普通向量那样下标访问。

### ③ 抽 kernel（`matmul.gpu-module.mlir`）
`--gpu-kernel-outlining`。同 cuda_core:host 留 `gpu.launch_func`,kernel 进 `gpu.module/gpu.func`。

### ④ nvvm.wmma（`matmul.nvvm.mlir`）
`--convert-gpu-to-nvvm`。`gpu.subgroup_mma_*` → `nvvm.wmma.load`(3)/`nvvm.wmma.mma`(1)/`nvvm.wmma.store`(1)。

### ⑤ PTX（`matmul.ptx`，61 行）
`nvvm-attach-target=sm_120` + `gpu-module-to-binary=isa`,抠成文本。核心就那几条:
```ptx
wmma.load.a.sync.aligned.row.m16n16k16.f16 ...
wmma.load.b.sync.aligned.row.m16n16k16.f16 ...
wmma.load.c.sync.aligned.row.m16n16k16.f16 ...
wmma.mma.sync.aligned.row.row.m16n16k16.f16.f16 ...   // 整块 16×16×16 一条指令
wmma.store.d.sync.aligned.row.m16n16k16.f16 ...
```

### ⑥ SASS（`matmul.sass`，137 行）
`ptxas -arch=sm_120` → `cuobjdump -sass`。真 Blackwell 张量核指令:
```
HMMA.16816.F16 ...    // 硬件 tensor core 的乘加（m16n8k16 拆分）
```

## 和 cuda_core 的根本对比

| | cuda_core（标量）| tensor_core（WMMA）|
|---|---|---|
| 线程模型 | 1 线程算 1 个 `C[m,n]` | **1 warp(32 线程)协作算 1 块 16×16** |
| 计算指令 | `FMUL`+`FADD`(CUDA core) | **`HMMA`**(tensor core)|
| dtype/形状 | f32 / 任意 | f16 / 16×16×16(WMMA tile)|
| 怎么来的 | affine 循环映射成网格 | vector.contract → subgroup_mma |

一句话:**同一个 `linalg.matmul`,换 dtype/形状/调度,就从 CUDA core 的标量 `FMUL/FADD` 切到 tensor core 的 `HMMA`。** 这就是"另一条路"。

## 注意
- 仍是**编译期下降演示**,没在卡上真跑(没接 CUDA runtime)。
- 只做了**单块 16×16×16**(一个 warp 一块)。真实大矩阵要在 m/n/k 上分块、多 warp、配 shared memory——又是另一层调度。
- `sm_120` 是本机 Blackwell;不跨代比。
