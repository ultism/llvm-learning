# matmul 走 GPU —— 同一个 linalg.matmul，两条不同的 GPU 下降路

把 `linalg.matmul` 降到 GPU，先按"用不用 tensor core"分两条大路;其中 `cuda_core` 内部再按
"并行维怎么摊进网格"分两条子路:

| 子文件夹 | 路线 | 线程模型 | 计算指令 | dtype/形状 |
|---|---|---|---|---|
| [`cuda_core/`](cuda_core/)（标量,两条子路） | linalg→循环→网格:[`affine/`](cuda_core/affine/) 用 `affine-for-to-gpu`、[`parallel/`](cuda_core/parallel/) 用官方 `convert-parallel-loops-to-gpu` | **1 线程算 1 个 `C[m,n]`**(affine:4 block×16 线程;parallel:4×16 block×1 线程) | `FMUL`+`FADD`(CUDA core) | f32 / 4×8×16 |
| [`tensor_core/`](tensor_core/) | 向量化 → `vector.contract` → `gpu.subgroup_mma` → nvvm.wmma | **1 warp(32 线程)算 1 块 16×16** | **`HMMA`**(tensor core) | f16 / 16×16×16(WMMA tile) |

两条都走到本机 Blackwell 的真产物:`cuda_core` 出标量 `FMUL/FADD`,`tensor_core` 出 `HMMA.16816`。
工具都是自编 `mlir-opt`(`23.0.0git`,NVPTX)+ conda 的 `ptxas`/`cuobjdump`(CUDA 12.8),目标 **`sm_120`**。

## 两条路的关系

`cuda_core` 是**默认、朴素**的降法:m、n 两层循环直接摊进网格,每个线程读 `blockIdx/threadIdx`
算自己那个标量 `C[m,n]`。它根本碰不到 tensor core——这正是"为什么没看到 mma"的答案。
它内部还分两条子路(`affine/` vs 官方 `parallel/`)——**同一个标量计算,两种把并行维塞进网格的方式**
(n 当 thread 还是当 block);细节和对比见 [`cuda_core/README.md`](cuda_core/README.md)。

`tensor_core` 是**专门奔着张量核去**的另一条路。tensor core 有硬性前提(f16、固定 tile、warp 级协作),
所以它**必须换数据类型、换形状、把计算包进一个 warp**,再经 `vector.contract → subgroup_mma → nvvm.wmma`
落到 `HMMA`。换句话说:

> **同一个 `linalg.matmul`,不改语义,只换 dtype/形状/调度——就能从 CUDA core 的标量 `FMUL/FADD` 切到 tensor core 的 `HMMA`。**

各自的逐层细节、产物清单、踩过的坑(尤其 tensor_core 那条 `multi_reduction → contract` 的 prepare patterns)
见两个子文件夹的 README。

## 公共件

- `extract_ptx.py` —— 两条路共用。`gpu-module-to-binary=isa` 把 PTX 嵌在 `gpu.binary` 字符串里(`\XX` 转义),
  这个脚本把它抠成干净的 `.ptx` 文本。

## 怎么跑

```sh
cd cuda_core/affine   && make artifacts   # 标量路·affine：m→block, n→thread → FMUL/FADD
cd cuda_core/parallel && make artifacts    # 标量路·parallel（官方）：m,n→block → FMUL/FADD
cd tensor_core        && make artifacts    # 张量核路：→ HMMA
```
（各子目录 `make clean` 只留手写源。）

## 注意 / 下一步

- 两条都是**编译期下降演示**,没接 CUDA runtime 在卡上真跑。
- `tensor_core` 只做了**单块 16×16×16**(一个 warp 一块)。真实大矩阵要在 m/n/k 上分块、多 warp、
  配 shared memory(`nvgpu` 还有 `mma.sync`/`ldmatrix`/异步拷贝那套)——可再开例子。
- GPU 特性按本机 `sm_120`(Blackwell)这代来,**不跨代比**。
