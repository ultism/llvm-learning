# cuda_core —— linalg.matmul 走 GPU 的「标量(CUDA core)」路（两条子路）

> GPU 两条大路之一(顶层总览见 [`../README.md`](../README.md);张量核那条见 [`../tensor_core/`](../tensor_core/README.md))。
> **本目录是"不碰 tensor core、落到 CUDA core 标量 `FMUL`/`FADD`"的路,内部又分两条子路:把并行维摊进网格的方式不同。**

`../../matmul_hello_world/`、`../../matmul/` 是把 `linalg.matmul` 降到 **CPU** 的 `.ll`。这里换目标降到 **GPU**——
同一个手写源 `matmul.mlir`(tensor 版,f32,4×8×16),经 `gpu`→`nvvm`,出 **PTX(sm_120 虚拟 ISA)+ SASS(本机 Blackwell 真机器码)**,
接回 `llvm/cuda/` 的三层产物线。两条子路用**字节相同的源**,只是"linalg→循环→网格"这一段走法不同。

## 两条子路

| 子文件夹 | 分叉 pass | 把 m、n 摊成 | 线程模型 | 计算指令 |
|---|---|---|---|---|
| [`affine/`](affine/README.md) | `--convert-affine-for-to-gpu` | m→**block.x**、n→**thread.x** | **4 block × 16 线程** | `FMUL`+`FADD` |
| [`parallel/`](parallel/README.md) | `--gpu-map-parallel-loops` + `--convert-parallel-loops-to-gpu`(**官方**) | m→**block.x**、n→**block.y** | **4×16 block × 1 线程** | `FMUL`+`FADD` |

两条都对、都落到 CUDA core 的标量乘加,真产物都是 `sm_120` 的 PTX/SASS。**唯一的实质差别是网格:n 该当 thread 还是当 block。**

## 关键对照:同一个 matmul,两种把"并行维"塞进 GPU 网格的方式

GPU 没有"遍历 m、n 的循环"——并行维要么变 **block**,要么变 **thread**。两条子路就是这件事的两种答案:

- **`affine/`**:`convert-affine-for-to-gpu` 按"第 1 层循环→block 维、第 2 层→thread 维"映射,
  于是 **m 当 block、n 当 thread**(4 个 block,每 block 16 线程)。规整完美嵌套循环的便捷映射。
- **`parallel/`**:`convert-parallel-loops-to-gpu` 是 MLIR **官方/规范**的 parallel→GPU 通路,
  默认把 `scf.parallel` 的**每一维都变成一维 block**,于是 **m、n 都当 block**(4×16 个 block,每 block 1 线程)。

> 两边在 NVVM 层结构一致(都是 1 条 `llvm.fmul` + rolled 的 k 循环),所以**选 scf 还是 affine 不改变标量计算本身**;
> 它只决定"并行维落成什么网格坐标"。这和 CPU 侧 `../../matmul/` 的结论同源:**换循环方言/映射 pass 改的是组织方式,不是算的内容。**
> (有个后端层面的小差异:affine 路的 PTX 把 K=8 展开了、parallel 路没展开——那是 LLVM NVPTX 后端的循环展开启发式,不在 MLIR 这层。细节见两子目录 README。)

## 一段历史:parallel 路曾失败,问题出在 pass 顺序

`parallel/` 这条最早试过、当场崩在 `gpu-module-to-binary`(`unrealized_conversion_cast (i64)->index` 残留)。
当时以为路线错了,转去用了 `affine/`。**复盘:不是路线错,是 `--lower-affine` 漏在抽 kernel 之前**——
`convert-parallel-loops-to-gpu` 会在 kernel 体里插 `affine.apply` 反算下标,不先拆就漏到 NVVM 折不掉。
补上顺序后官方路一样跑通。详见 [`parallel/README.md`](parallel/README.md)。

## 怎么跑

```sh
cd affine   && make artifacts   # m→block, n→thread（4 block × 16 线程）
cd parallel && make artifacts    # m,n→block（官方，4×16 block × 1 线程）
# 各子目录 make clean 只留手写源 matmul.mlir；PTX 提取器在 ../extract_ptx.py（两路共用）
```

## 注意

- 两条都是**最朴素**映射:一个线程算一个 `C[m,n]`,k 顺序累加,没 shared memory、没分块、没 tensor core,
  也没在卡上真跑(只到编译期 PTX/SASS)。要 tensor core 看 [`../tensor_core/`](../tensor_core/README.md)。
- `sm_120` 是本机 Blackwell;**不跨代比**(别拿 sm_90 之类对照)。
