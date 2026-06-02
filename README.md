# learn —— 在真机上读编译器的中间产物

这个仓库是一组**编译器中间产物的学习例子**:从一段 C / CUDA / MLIR 出发,把它**一层层往下降**,
每一层的产物(LLVM IR、x86 汇编、PTX、SASS、各级 MLIR 方言)都 dump 出来**留在磁盘上对照着读**,
看"高层语义"是怎么一步步变成"机器指令"的。所有结论**以本机实测 / 读源码为准**,不凭记忆。

> 本机:WSL2 + AMD Zen5(AVX-512)+ NVIDIA RTX 5060 Ti(Blackwell,`sm_120`)。
> 工具链、版本、构建命令、文件追踪约定等**协作规范见 [AGENTS.md](AGENTS.md)**(改代码前请先读)。

## 例子怎么组织

按**「编译器 → 子类」两级**归档(`example/<compiler>/<bucket>/`):

- **LLVM** 按**目标后端**分:`x86_avx512/`(从 C 看 IR/汇编)、`cuda/`(NVPTX,看 LLVM IR / PTX / SASS 三层)。
- **MLIR** 按**方言**分:`linalg/`(逐层降到 `.ll` 或 GPU 产物)、`vector/`(通用向量 op 怎么落到 x86 向量指令)。

每个例子**自带 `README.md` + `Makefile`**,可独立 `make` 重建。源码(`.c/.cu/.mlir`)与学习产物
(`.ll/.s/.ptx/.sass`、各级 `.mlir`)都入库供对照;可执行文件统一以 **`.out`** 结尾并被忽略(详见 AGENTS.md)。

## 目录与内容

```
example/
├── llvm/                              # LLVM:从 C 出发往下看 IR/汇编，按目标后端分类
│   ├── x86_avx512/                    #   基于 x86 AVX-512(Zen5)
│   │   ├── gelu/                      #     GELU:标量 vs AVX-512(基于 erf)；在 x86 上向量化 erf(SLEEF)
│   │   ├── gemm/                      #     什么数学模式会生成「向量 GEP / gather」——一次实测(IR/汇编/remark)
│   │   ├── gemv/                      #     dot / GEMV:用点积学读 LLVM IR；严格 FP vs -ffast-math 的归约向量化
│   │   └── sparse/                    #     稀疏 SpMV/SpMM(CSR/ELL/BSR):什么时候 gather，关键看「间接的粒度」
│   └── cuda/                          #   NVPTX/CUDA:三层中间产物(LLVM IR / PTX / SASS)
│       ├── vector_add/                #     逐元素向量加：对照 fp32 / fp16 / bf16 三层产物
│       └── tma_half2/                 #     TMA 异步读 + half2 打包加：三层看 sm_120 的异步搬运(仅 sm_120，不跨代比)
└── mlir/                              # MLIR:在 LLVM IR 之上的方言，逐层降下来，按方言分类
    ├── linalg/                        #   linalg 方言
    │   ├── matmul_hello_world/        #     hello world:一个命名 op 怎么一层层降到 LLVM IR(最朴素链，逐层精讲)
    │   ├── matmul/                    #     同一个源走 4 条 pass 路径降到 .ll(一条路径一个子文件夹)
    │   │   ├── scf_loops/             #       --convert-linalg-to-loops(基线:三层 scf.for)
    │   │   ├── affine_loops/          #       --convert-linalg-to-affine-loops + --lower-affine(与 scf 字节相同)
    │   │   ├── parallel_loops/        #       --convert-linalg-to-parallel-loops(scf.parallel；与 scf 字节相同)
    │   │   └── affine_vectorize/      #       --affine-super-vectorize(唯一改了 .ll 的路径:<8 x float> SIMD)
    │   └── matmul_gpu/                #     同一个源走 GPU，按用不用 tensor core 分两条大路(sm_120，PTX/SASS)
    │       ├── cuda_core/             #       标量(CUDA core)，按并行维怎么摊进网格再分两条子路 → 都出 FMUL/FADD
    │       │   ├── affine/            #         convert-affine-for-to-gpu:m→block, n→thread(4 block×16 线程)
    │       │   └── parallel/          #         官方 convert-parallel-loops-to-gpu:m,n→block(4×16 block×1 线程)
    │       └── tensor_core/           #       张量核:f16 + vector.contract → subgroup_mma → nvvm.wmma → HMMA(1 warp 1 块 16×16)
    └── vector/                        #   vector 方言
        └── fma/                       #     vector.fma 怎么落到 x86:fmuladd → 后端选 vfmadd(路 A;含 strict FP / 无 FMA 对比)
```

### LLVM / x86 AVX-512

| 例子 | 看什么 |
|---|---|
| [`gelu/`](example/llvm/x86_avx512/gelu/) | GELU 的标量与 AVX-512(基于 `erf`)实现;重点是**在 x86 上怎么向量化 `erf`**(靠 SLEEF / `-fveclib`)。 |
| [`gemm/`](example/llvm/x86_avx512/gemm/) | 一次实测:**什么数学模式/访存会让编译器生成「向量 GEP / gather」**,只出 IR/汇编/向量化 remark,不跑可执行。 |
| [`gemv/`](example/llvm/x86_avx512/gemv/) | 用**点积 / GEMV** 学读 LLVM IR;对比**严格 FP vs `-ffast-math`** 下归约能不能向量化。 |
| [`sparse/`](example/llvm/x86_avx512/sparse/) | 稀疏 **SpMV/SpMM**(CSR/ELL/BSR):什么时候真出 `gather`、什么时候不出——**关键看「间接的粒度」**。 |

### LLVM / CUDA(NVPTX,三层产物)

CUDA 例子的「三层中间产物」对应 x86 的 `.ll`/`.s`:`.ll`(clang LLVM IR)/ `.ptx`(虚拟 ISA)/ `.sass`(真卡机器码),均入库。

| 例子 | 看什么 |
|---|---|
| [`vector_add/`](example/llvm/cuda/vector_add/) | 最简单的逐元素向量加,**对照 fp32 / fp16 / bf16** 在 LLVM IR / PTX / SASS 三层的差别。 |
| [`tma_half2/`](example/llvm/cuda/tma_half2/) | **TMA 异步读 + half2 打包加**,三层看 `sm_120` 的异步搬运(本机 Blackwell,**不跨代比**)。 |

### MLIR / linalg

同一个 `linalg.matmul`,既往 CPU 降到 `.ll`,也往 GPU 降到 PTX/SASS;核心教学点是 **MLIR 把「语义」和「调度」分开**——
换循环方言/映射 pass 不改语义也常不改最终代码,只有真正动了调度(向量化、上 tensor core)才改写产物。

| 例子 | 看什么 |
|---|---|
| [`matmul_hello_world/`](example/mlir/linalg/matmul_hello_world/) | 一个命名 op 怎么**一层层**降到 LLVM IR(bufferize → scf 循环 → LLVM dialect → `.ll`),逐层精讲。 |
| [`matmul/`](example/mlir/linalg/matmul/) | **同一个源走 4 条 pass 路径**降到 `.ll`,一条路一个子文件夹。结论:`scf`/`affine`/`parallel` 三条标量路 **`.ll` 字节相同**,只有 `affine_vectorize` 那条(SIMD)变了。 |
| [`matmul_gpu/`](example/mlir/linalg/matmul_gpu/) | **同一个源走 GPU**,先按用不用 tensor core 分两条大路;`cuda_core` 内再按「并行维当 block 还是 thread」分 `affine/` 与官方 `parallel/` 两子路(都出标量 `FMUL/FADD`),`tensor_core` 经 `vector.contract → subgroup_mma → nvvm.wmma` 出 **`HMMA`**。 |

### MLIR / vector

| 例子 | 看什么 |
|---|---|
| [`fma/`](example/mlir/vector/fma/) | `vector.fma` 怎么降到 x86:→ `llvm.intr.fmuladd` → **后端**按 `+fma` 选 `vfmadd`。对照 `mulf`+`addf`(严格 FP 不融)与无 FMA 硬件(连 `vector.fma` 也拆开)——说明**「融不融」由 MLIR 选哪个 op 决定**,不是后端自由发挥。这是 vector→x86 的「通用路(路 A)」,区别于 `x86` 方言那种专属 intrinsic 路。 |

## 怎么用

```sh
git clone --recurse-submodules <repo>      # 含 llvm-project 子模块(体量大)
cd <example 目录>                           # 每个例子自带 README + Makefile
make            # 或 make run / asm / ir / ptx / sass / artifacts / clean（按例子而定）
```

具体目标、工具链路径、构建环境与各类约定见 **[AGENTS.md](AGENTS.md)**。
`llvm-project/` 是指向上游的 submodule,本仓库只记录其 commit 指针,**不在其中改代码**。
