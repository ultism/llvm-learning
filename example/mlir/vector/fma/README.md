# vector.fma 降到 x86 —— MLIR 通用 op 怎么落到 AVX-512 向量指令（路 A）

读 `--convert-vector-to-llvm` 源码时引出的一个问题:MLIR 里**没有** `x86.fma` 这种方言 op
(x86 方言只收 `mask.compress`/`rsqrt`/AMX 这类**没有通用等价物**的指令,见
[`../../../llvm/x86_avx512/`](../../../llvm/x86_avx512/) 的姊妹方向和 `lib/Dialect/X86/`)。
那 FMA 是怎么出来的?——它走的是**通用路(路 A)**:通用 `vector` op → 通用 LLVM IR → **x86 后端**
自己选 `vfmadd`。这个例子就把这条链一层层 dump 出来,顺便回答一个更细的问题:
**"要不要融合成 FMA",到底是哪一层拍板的。**

> 工具:自编 `23.0.0git` 的 `mlir-opt` / `mlir-translate` / `llc`(X86 后端);目标 `-mcpu=znver5`(本机 Zen5)。

## 源:两个数学等价、但「融合性」表达不同的函数

`fma.mlir` 里:

```mlir
func.func @fused(...)    { %0 = vector.fma %a, %b, %c : vector<16xf32> ; return %0 }
func.func @separate(...) { %0 = arith.mulf %a, %b ; %1 = arith.addf %0, %c ; return %1 }
```

两者都算 `a*b+c`,但 `@fused` 用一个 **`vector.fma`**(结构上就是"一个融合乘加"),
`@separate` 用**两个独立**的 `mulf`+`addf`。`vector<16xf32>` = 512 bit = 一个 zmm。

## 一层层降下来(产物都入库)

```
fma.mlir ──①convert-vector/arith/func-to-llvm──▶ fma.llvm.mlir (LLVM 方言)
         ──②mlir-translate --mlir-to-llvmir────▶ fma.ll       (LLVM IR)
         ──③llc -mcpu=znver5───────────────────▶ fma.fma.s    (x86 汇编, 有 FMA)
         ──③llc -mcpu=znver5 -mattr=-fma───────▶ fma.nofma.s  (x86 汇编, 无 FMA)
```

### ① LLVM 方言(`fma.llvm.mlir`)—— `vector.fma` 变成谁

```mlir
@fused:    %0 = llvm.intr.fmuladd(%a, %b, %c) : ...    // ← 注意是 fmuladd，不是 fma
@separate: %0 = llvm.fmul %a, %b ;  %1 = llvm.fadd %0, %c
```

**关键点:`vector.fma` 降下来是 `llvm.intr.fmuladd`,不是 `llvm.intr.fma`。** 两者语义不同:
- `@llvm.fma` = **强制**单次舍入的真融合,后端必须当一条 FMA(没硬件就软件模拟,绝不拆)。
- `@llvm.fmuladd` = **"允许"融合**:后端"有 FMA 且划算就融,否则老实 mul+add"。
  融不融、是不是单次舍入,**交给后端按目标决定**。

所以 `fmuladd` 这个节点字面意思就是:**"我摆好了一个可融合的乘加,要不要真融你后端看着办。"**
这正是"MLIR 这层只负责摆出适合 FMA 的形状,硬件指令在后端才拍板"。

### ② LLVM IR(`fma.ll`)

```llvm
@fused:    %4 = call <16 x float> @llvm.fmuladd.v16f32(<16 x float> %0, %1, %2)
@separate: %4 = fmul <16 x float> %0, %1
           %5 = fadd <16 x float> %4, %2
```

到这里仍是**中立的 LLVM IR**:`@fused` 一个 `fmuladd` 节点,`@separate` 两个普通浮点运算。还没有任何 x86 指令。

### ③ x86 汇编 —— 后端在这里才选指令

**`fma.fma.s`(本机 znver5,有 FMA,512 位 zmm):**

```asm
fused:      vfmadd213ps %zmm2, %zmm1, %zmm0      # 一条融合乘加
separate:   vmulps      %zmm1, %zmm0, %zmm0      # 乘
            vaddps      %zmm2, %zmm0, %zmm0      # 再加（两条）
```

> **核心对照:同一台机器、同样 512 位、FMA 完全可用、严格 FP——唯一的差别是 MLIR 里用了哪个 op。**
> `vector.fma`(→`fmuladd`)融成一条 `vfmadd`;`mulf`+`addf` 后端**不敢**自动融(会改舍入),老实出两条。
> 也就是说:**"融不融"是在 MLIR 选 op 那一刻就决定了的结构,不是后端的自由发挥。**

**`fma.nofma.s`(`-mattr=-fma`,假装硬件没 FMA 单元):**

```asm
fused:      vmulps %ymm... ; vaddps %ymm... (×2)   # 连 @fused 也只能拆成 mul+add
```

> 没有 FMA 单元时,`fmuladd` 的"允许融合"就落空,后端只能拆成普通乘加——印证了 `fmuladd` 的"可融合但不强制"。
> 顺带一个 x86 冷知识:**AVX-512 在特性层级上依赖 FMA**,`-mattr=-fma` 会连带把 AVX-512 降级到 AVX2,
> 所以宽度从 512 位 zmm 掉到 256 位 ymm(512 位被拆成两个 256 位算)。现实里**不存在"有 AVX-512 却没 FMA"的 CPU**。

## 这条链每层"决定"了什么

| 层 | 谁 | 决定 |
|---|---|---|
| MLIR op 选择 | `vector.fma` vs `mulf`+`addf` | **要不要融合**(结构层面定死) |
| `--convert-vector-to-llvm` | 机械 1:1 | `vector.fma`→`llvm.intr.fmuladd`,不做选择 |
| **x86 后端 (`llc`)** | 指令选择 | **用哪条机器指令**:有 FMA→`vfmadd`,无 FMA→`vmul`+`vadd` |

## 和 `gemv/` 的 strict vs `-ffast-math` 是同一条线

C 里两个分开的 `a*b` 再 `+c`,后端默认**不敢**融(改舍入),要 `-ffp-contract=fast` / `-ffast-math` 才融
(见 [`../../../llvm/x86_avx512/gemv/`](../../../llvm/x86_avx512/gemv/))。而 MLIR 的 `vector.fma`→`fmuladd`
是**结构化地、不依赖 fast-math** 地表达"这里允许 contract"——所以严格 FP 下 `@separate` 融不了、`@fused` 能融。
**同一个"要不要融"的问题:C 靠 fast-math 标志,MLIR 靠选 `vector.fma`/`fma`/`fmuladd` 这个 op 来表达。**

## 怎么跑

```sh
make artifacts   # ①~③ 全出（产物入库）
make ir          # 只到 LLVM 方言（看 fmuladd）
make llvmir      # 到 LLVM IR
make asm         # 到 x86 汇编（fma.s + nofma.s）
make clean       # 只留 fma.mlir
```

## 注意

- 这是**纯编译期下降演示**,不在卡/CPU 上真跑。
- `-mcpu=znver5` 是本机 Zen5;换别的有 FMA 的 x86(haswell 起、skylake-avx512 等)`@fused` 一样出 `vfmadd`,
  只是 Skylake-X 系有 256 位降频调优、默认可能拆成 ymm,宽度细节因 CPU 而异——FMA 与否的结论不变。
