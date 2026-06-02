# AGENTS.md — 仓库约定

供任何在本仓库工作的 agent / 协作者遵循的约定。改动代码前请先读完本文件。

## 仓库结构

```
.
├── example/                       # 学习用的小例子（每个子目录自带 README + Makefile）
│   ├── llvm/                      #   LLVM：从 C 出发往下看 IR/汇编，按目标后端分类
│   │   ├── x86_avx512/            #     基于 x86 AVX-512 的 LLVM 示例
│   │   │   ├── gelu/              #       GELU + 在 x86 上向量化 erf
│   │   │   ├── gemm/              #       矩阵乘 / gather 的 IR、汇编与向量化 remark
│   │   │   ├── gemv/              #       点积，对比严格 FP vs -ffast-math 的归约向量化
│   │   │   └── sparse/            #       稀疏 SpMV/SpMM（CSR/ELL/BSR）：gather 的粒度
│   │   └── cuda/                  #     NVPTX/CUDA 示例（三层产物：LLVM IR / PTX / SASS）
│   │       ├── vector_add/        #       逐元素向量加：对照 fp32/fp16/bf16 三层产物
│   │       └── tma_half2/         #       TMA 异步读 + half2 打包加（仅 sm_120，不跨代比）
│   └── mlir/                      #   MLIR：在 LLVM IR 之上的方言，逐层降到 .ll，按方言分类
│       ├── linalg/                #     linalg 方言
│       │   ├── matmul_hello_world/ #      hello world：一条最朴素链跑通（bufferize→scf 循环→LLVM dialect→.ll），逐层精讲
│       │   ├── matmul/             #      同一个源走 4 条 pass 路径降到 .ll（scf/affine/parallel 标量殊途同归，仅向量化改 IR）
│       │   │                       #        每条路径一个子文件夹，各存「特征中间形态 + 最终 .ll」
│       │   └── matmul_gpu/         #      同一个源走 GPU，按用不用 tensor core 分两条大路（sm_120，PTX/SASS）
│       │       ├── cuda_core/      #        标量(CUDA core)，按并行维怎么摊进网格再分两条子路 → 都出 FMUL/FADD
│       │       │   ├── affine/     #          convert-affine-for-to-gpu：m→block, n→thread（4 block×16 线程）
│       │       │   └── parallel/   #          官方 convert-parallel-loops-to-gpu：m,n→block（4×16 block×1 线程，每 block 1 线程）
│       │       └── tensor_core/    #        张量核：f16+vector.contract→subgroup_mma→nvvm.wmma → HMMA（1 warp 1 块 16×16）
│       └── vector/                #     vector 方言
│           └── fma/               #       vector.fma → fmuladd → 后端选 vfmadd（路 A；strict FP / 无 FMA 对比）
└── llvm-project/                  # submodule → 上游 https://github.com/llvm/llvm-project
```

> 例子按"编译器 → 子类"两级归档（`example/<compiler>/<bucket>/`）。LLVM 按**目标后端**分
> （`example/llvm/x86_avx512/`、`example/llvm/cuda/`；后续 ARM SVE、RISC-V V 各自平级新建）；
> MLIR 按**方言**分（`example/mlir/linalg/`；后续 gpu/vector/affine 等各自平级新建）。
>
> CUDA 例子的「三层中间产物」对应 x86 的 `.ll`/`.s`：
> `.ll`（clang LLVM IR）/ `.ptx`（nvcc 虚拟 ISA）/ `.sass`（cuobjdump 真卡机器码），均入库供对照；
> Makefile 目标为 `ir` / `ptx` / `sass`（或 `artifacts` 一把出）/ `run` / `clean`。

## 编译产物约定 ⭐（最重要）

**所有编译出来的可执行文件，文件名一律以 `.out` 结尾。**

Linux 的可执行文件默认没有后缀（不像 Windows 的 `.exe`），无法用 `*.xxx` 通配忽略。
因此本仓库**人为约定 `.out` 作为可执行文件后缀**，`.gitignore` 用一条 `*.out` 全部覆盖，
新增 demo 不需要再改 `.gitignore`。

- Makefile 里写 `BIN = <名字>.out`，例如 `BIN = gelu_demo.out`、`BIN = dot_demo.out`。
- 手动编译（如文档里的 `icx`/`clang` 命令）也要 `-o <名字>.out`。
- **不要**给可执行文件起无后缀的名字（如 `gelu_demo`、`demo`），否则会被 git 误追踪。

## 追踪 vs 忽略

| 类型 | 处理 | 原因 |
|------|------|------|
| `.c` / `.h` / `.cu` / `Makefile` / `README.md` | **追踪** | 源码与说明 |
| `.ll` / `.s` / `.ptx` / `.sass`（IR / 汇编 / PTX / SASS） | **追踪** | 是学习产物本身，文档里有引用，需要留存对比 |
| `.out`（可执行文件） | 忽略 | 编译产物，可 `make` 重建 |
| `.o` / `.a` / `.so` / `.cubin` 等目标文件 | 忽略 | 同上（`.cubin` 是 SASS 的二进制中间物） |

具体规则见 [.gitignore](.gitignore)。

## 各 example 常用 make 目标

```sh
make / make run   # 编译并运行（产出 <name>.out）
make asm          # dump 汇编（.s）
make ir           # dump LLVM IR（.ll），含 loop-vectorize remark
make clean        # 清理产物
```
（`gemm` 只有 `ir` / `asm` / `remarks`，不产可执行文件。）

## 构建环境提示

### 硬件 / 平台
- 平台：WSL2（Ubuntu 22.04），内核 5.15。
- CPU：AMD Ryzen 9800X3D（Zen5），支持 **AVX-512**。
- GPU：NVIDIA GeForce RTX 5060 Ti，16 GB；compute capability **12.0**（Blackwell，`sm_120`）。

### x86 / clang（AVX-512）
- 编译器为 `clang`，`CFLAGS` 用 `-O3 -march=native`，依赖机器支持 AVX-512（Zen 4/5、Skylake-X 及更新）。
- `gelu` 额外依赖 SLEEF（`-lsleef`，提供向量化 `erf`：`Sleef_erff16_u10`）。
- 可用 clang：默认 `clang` = 15.0.7，另有 `clang-18`、`clang-22`（来自 apt.llvm.org）。

### CUDA / NVPTX
- `nvcc` 12.8（V12.8.61），来自 conda：`/root/miniconda3/bin/nvcc`；driver 侧报 CUDA 13.2。
- CUDA toolkit 在 `/root/miniconda3`，头文件在 `/root/miniconda3/targets/x86_64-linux/include`。
- **编译 / 出 IR / 出 PTX 不需要本机 GPU 架构，只有真在卡上跑（cubin / SASS / launch）才需要 `sm_120`。**
  出 IR 时挑任意被 clang 认识的低 arch（如 `sm_90`）即可。
- 用 `clang` 编 CUDA 需显式指 CUDA 路径，否则报 `cuda.h not found`：
  `--cuda-path=/root/miniconda3 -I/root/miniconda3/targets/x86_64-linux/include`。

### MLIR（mlir-opt / mlir-translate 等）
- 本机有**两套** MLIR 工具，**版本不同**，按用途选：
  - **自编（首选，与源码同 commit）**：`llvm-project/build/bin/{mlir-opt,mlir-translate}`，
    **`23.0.0git` + assertions**——就是当前 submodule 源码编出来的。读产物、对 `mlir/` 源码行号
    与 pass 行为，**用这套**。
  - **apt（随手可用的对照）**：`mlir-opt-22` 等（`/usr/bin/mlir-opt-22` → `/usr/lib/llvm-22/bin/`），
    来自 `mlir-22-tools` 包，**`22.1.7`**，比源码**低一个大版本**。
- ⚠️ **submodule 是 LLVM 23（`23.0.0git`），不是 22**——别看见 `clang-22` 就当成 22（实测得来）。
- apt.llvm.org 确实打包 MLIR：`mlir-XX-tools` / `libmlir-XX-dev`（X=13/14/15/18/22/23）。
  若 `apt-cache search mlir` 为空，多半是索引旧了，`apt-get update` 后即出。
- 自编的 configure（后端 `X86;NVPTX`，Release + assertions，clang-22 + lld）：
  ```sh
  cmake -G Ninja -S llvm -B build \
    -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS=mlir \
    -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_C_COMPILER=clang-22 -DCMAKE_CXX_COMPILER=clang++-22 \
    -DLLVM_ENABLE_LLD=ON -DLLVM_OPTIMIZED_TABLEGEN=ON \
    -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF -DLLVM_INCLUDE_EXAMPLES=OFF
  ninja -C build mlir-opt mlir-translate llc  # llc 给 vector/fma 那类「.ll→x86 汇编」用；要 JIT 再 ninja mlir-runner
  ```
  build 目录在 `llvm-project/build`，被 LLVM 自带 `.gitignore` 忽略，**不污染父仓库**。

> 工具链版本与特性支持（clang 对 x86 向量 `erf`、对某 `sm_` 的支持等）**一律以实测 / 读源码为准，不要凭记忆下结论。**

## submodule（llvm-project）注意事项

- 克隆本仓库后需初始化 submodule：
  ```sh
  git clone --recurse-submodules <repo>        # 或克隆后：
  git submodule update --init                  # llvm-project 体量巨大，拉取耗时
  ```
- `llvm-project` 指向上游某个 commit，本仓库只记录该 commit 指针（gitlink），**不在其中改代码、不把其内容提交进本仓库**。
- 本地的 llvm-project 是 **shallow clone**：没有完整 tag/历史，判断版本/日期请读源码，别依赖 `git log`。
