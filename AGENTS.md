# AGENTS.md — 仓库约定

供任何在本仓库工作的 agent / 协作者遵循的约定。改动代码前请先读完本文件。

## 仓库结构

```
.
├── example/                       # 学习用的小例子（每个子目录自带 README + Makefile）
│   └── llvm/                      #   按编译器分类
│       ├── x86_avx512/            #     基于 x86 AVX-512 的 LLVM 示例
│       │   ├── gelu/              #       GELU + 在 x86 上向量化 erf
│       │   ├── gemm/              #       矩阵乘 / gather 的 IR、汇编与向量化 remark
│       │   ├── gemv/              #       点积，对比严格 FP vs -ffast-math 的归约向量化
│       │   └── sparse/            #       稀疏 SpMV/SpMM（CSR/ELL/BSR）：gather 的粒度
│       └── cuda/                  #     NVPTX/CUDA 示例（三层产物：LLVM IR / PTX / SASS）
│           ├── vector_add/        #       逐元素向量加：对照 fp32/fp16/bf16 三层产物
│           └── tma_half2/         #       TMA 异步读 + half2 打包加（仅 sm_120，不跨代比）
└── llvm-project/                  # submodule → 上游 https://github.com/llvm/llvm-project
```

> 例子按"编译器 → 目标后端"两级归档（`example/<compiler>/<backend>/`）。x86 AVX-512 在
> `example/llvm/x86_avx512/`，CUDA/NVPTX 在 `example/llvm/cuda/`；后续其它后端（如 ARM SVE、
> RISC-V V）各自新建平级目录。
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

> 工具链版本与特性支持（clang 对 x86 向量 `erf`、对某 `sm_` 的支持等）**一律以实测 / 读源码为准，不要凭记忆下结论。**

## submodule（llvm-project）注意事项

- 克隆本仓库后需初始化 submodule：
  ```sh
  git clone --recurse-submodules <repo>        # 或克隆后：
  git submodule update --init                  # llvm-project 体量巨大，拉取耗时
  ```
- `llvm-project` 指向上游某个 commit，本仓库只记录该 commit 指针（gitlink），**不在其中改代码、不把其内容提交进本仓库**。
- 本地的 llvm-project 是 **shallow clone**：没有完整 tag/历史，判断版本/日期请读源码，别依赖 `git log`。
