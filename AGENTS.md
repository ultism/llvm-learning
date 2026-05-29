# AGENTS.md — 仓库约定

供任何在本仓库工作的 agent / 协作者遵循的约定。改动代码前请先读完本文件。

## 仓库结构

```
.
├── example/         # 学习用的小例子（每个子目录自带 README + Makefile）
│   ├── gelu/        #   GELU + 在 x86 上向量化 erf
│   ├── gemm/        #   矩阵乘 / gather 的 IR、汇编与向量化 remark
│   └── gemv/        #   点积，对比严格 FP vs -ffast-math 的归约向量化
└── llvm-project/    # submodule → 上游 https://github.com/llvm/llvm-project
```

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
| `.c` / `.h` / `Makefile` / `README.md` | **追踪** | 源码与说明 |
| `.ll` / `.s`（LLVM IR / 汇编） | **追踪** | 是学习产物本身，文档里有引用，需要留存对比 |
| `.out`（可执行文件） | 忽略 | 编译产物，可 `make` 重建 |
| `.o` / `.a` / `.so` 等目标文件 | 忽略 | 同上 |

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

- 编译器为 `clang`，`CFLAGS` 用 `-O3 -march=native`，依赖机器支持 **AVX-512**（Zen 4/5、Skylake-X 及更新）。
- `gelu` 额外依赖 SLEEF（`-lsleef`，提供向量化 `erf`：`Sleef_erff16_u10`）。
- 工具链版本（clang 对 x86 向量 `erf` 的支持等）**以实测/读源码为准，不要凭记忆下结论**。

## submodule（llvm-project）注意事项

- 克隆本仓库后需初始化 submodule：
  ```sh
  git clone --recurse-submodules <repo>        # 或克隆后：
  git submodule update --init                  # llvm-project 体量巨大，拉取耗时
  ```
- `llvm-project` 指向上游某个 commit，本仓库只记录该 commit 指针（gitlink），**不在其中改代码、不把其内容提交进本仓库**。
- 本地的 llvm-project 是 **shallow clone**：没有完整 tag/历史，判断版本/日期请读源码，别依赖 `git log`。
