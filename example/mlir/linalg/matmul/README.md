# matmul —— 同一个源，走不同 pass 路径降到 LLVM IR

`matmul_hello_world/` 走的是**一条**最朴素的下降链(named op → bufferize → scf 循环 → LLVM dialect → `.ll`),
把每一层讲透。这个例子换个角度:**手写源还是那一个 `matmul.mlir`(从 hello_world 直接 cp 来),
但故意走几条不同的 pass 路径降到 LLVM IR,看「选哪条路」对中间形态和最终 `.ll` 各有什么影响**。

> 一条 pass 路径 = 一个子文件夹。每个子文件夹从 `../matmul.mlir` 出发,自带 Makefile + README,
> 产物有两个:**特征中间形态**(`*.mlir`,这一层最能看出路径差别)和**最终 `matmul.ll`**。
> 工具仍是自编 `mlir-opt`/`mlir-translate`(`23.0.0git`,与 submodule 同源,见根 [AGENTS.md](../../../../AGENTS.md))。

## 共同的前半段

四条路径**开头都一样**:先 `--one-shot-bufferize` 把 tensor 换成 memref(这步、以及为什么 memref 是
「生成」的,在 [`../matmul_hello_world/`](../matmul_hello_world/README.md) 里已讲透)。**分叉发生在「linalg 怎么变成循环」这一步**,
之后再各自收尾(`memref → descriptor`、`func/arith/cf → llvm`、翻译成 `.ll`)。

## 四条路径

| 子文件夹 | 分叉用的 pass | 特征中间形态 | 最终 `.ll` |
|---|---|---|---|
| [`scf_loops/`](scf_loops/) | `--convert-linalg-to-loops` | 三层 `scf.for`(k 在最内归约) | 标量 `fmul/fadd float`,89 行 |
| [`affine_loops/`](affine_loops/) | `--convert-linalg-to-affine-loops` + `--lower-affine` | 三层 `affine.for`(下标是 affine_map) | **与 scf 字节相同** |
| [`parallel_loops/`](parallel_loops/) | `--convert-linalg-to-parallel-loops` | `scf.parallel(m,n)` 套 `scf.for(k)` | **与 scf 字节相同** |
| [`affine_vectorize/`](affine_vectorize/) | `--convert-linalg-to-affine-loops` + `--affine-super-vectorize` | `vector<8xf32>` + `vector.transfer_read/write` | **`<8 x float>` SIMD,123 行** |

## 最重要的一条结论:三条标量路径的 `.ll` 完全一样

实测 `diff`:`scf_loops`、`affine_loops`、`parallel_loops` 三者的 `matmul.ll` **逐字节相同**(都是 89 行)。

为什么?**它们只是「在哪个方言里表达循环」不同,循环结构本身是同一个**——三层标量嵌套、k 做归约。
一旦都降到 `cf` 基本块(`affine.for` 经 `--lower-affine` 拆成 arith+scf;`scf.parallel` 单线程降级被
`--convert-scf-to-cf` 摊成顺序 CFG),抽象差别就被抹平,LLVM IR 自然收敛到同一份。

这恰恰说明:

- **选不同的循环方言,不会凭空改变生成的机器级代码**——`scf` vs `affine` vs `parallel` 的区别在于
  「后续还能在这层做什么变换」(affine 有多面体分析、parallel 能接 OpenMP/GPU),而不是直接产出不同的 `.ll`。
- **真正改变最终指令的是「调度」**——比如向量化。只有 `affine_vectorize` 那条的 `.ll` 变了样:
  N 维按 `step 8` 切,算子升成 `vector<8xf32>`,落到 LLVM IR 就是 `fmul/fadd <8 x float>`、
  A 的 `insertelement`+`shufflevector` 广播、B/C 的 `@llvm.masked.load/store.v8f32`。

> 一句话:**pass 路径决定你「在哪一层、还能做哪些变换」;只有真正动了调度(向量化/分块)的变换,才会改写最终 `.ll`。**
> 这正是 MLIR 把「语义(matmul)」和「调度(怎么跑)」分开的意义——换循环方言不改语义也不改代码,换调度才改代码。

## 怎么跑

```sh
make all      # 顶层：把 4 个子文件夹的产物都生成出来
make clean    # 清掉所有子文件夹的生成物
# 或进单个子目录：cd scf_loops && make all
```

每个子目录的 README 只补「这条路径相对 scf 基线差在哪、中间形态长什么样」。逐层精讲见
[`../matmul_hello_world/`](../matmul_hello_world/README.md)。

## 还能加什么路径

这版的自编 `mlir-opt` 里,linalg 层的 `--linalg-tile` / `--linalg-vectorize` 已不是独立 pass(挪进 transform 方言了)。
能再玩的同类对比:`--affine-loop-tile`(在 affine 层分块)、`--linalg-block-pack-matmul`(matmul 专用的 block 重排)、
`--convert-scf-to-openmp`(parallel 那条接 OpenMP 真并行)——每个都可再开一个子文件夹,套同样的「特征中间形态 + 最终 .ll」格式。
