# vector_add —— 用最简单的向量加，对照 fp32 / fp16 / bf16 的三层中间产物

CUDA 学习的第一课。核简单到不能再简单——**一个线程算一个元素**（"一个 CUDA core 加一次"），
没有归约、没有共享内存、没有循环。正因为干净，才能把注意力全放在一件事上：

> **同一句 `c[i] = a[i] + b[i]`，把类型在 `float` / `__half` / `__nv_bfloat16` 之间切换，
> 在编译产物的三层里分别变成了什么。**

三层 = x86 那套 `.ll`/`.s` 在 GPU 上的对应：

| 层 | 谁产的 | 本例文件 | 是什么 |
|---|---|---|---|
| ① LLVM IR | `clang -x cuda` | `vadd.ll` | 平台无关的中间表示（device 端 `nvptx64` 模块） |
| ② PTX | `nvcc -ptx` | `vadd.ptx` | NVIDIA 的**虚拟** ISA（前向兼容，driver 再 JIT） |
| ③ SASS | `nvcc -cubin` + `cuobjdump -sass` | `vadd.sass` | **真卡**机器码（本机 `sm_120` = RTX 5060 Ti / Blackwell） |

## 文件

| 文件 | 内容 |
|---|---|
| `vadd.cu` | 三个 kernel：`vadd_f32` / `vadd_f16` / `vadd_bf16`，加一个 host main 验正确性 |
| `vadd.ll` / `vadd.ptx` / `vadd.sass` | 三层产物（`make artifacts` 生成，已入库供对照） |
| `Makefile` | `run` / `ir` / `ptx` / `sass` / `artifacts` / `clean` |

## 跑

```sh
make run        # 编译并在 GPU 上验：三个核都应 OK，c[0]=3.0
make artifacts  # 一把出 vadd.ll / vadd.ptx / vadd.sass
```

> 编译/出 IR/出 PTX 不挑卡（用 `sm_90` 即可）；**只有真在卡上跑、出 cubin/SASS 才需要本机 `sm_120`。**
> 见仓库根 `AGENTS.md`。

---

## 核心一课：fp32 全程原生，fp16/bf16 的 `+` 其实是头文件里塞的内联汇编

### ① fp32：`fadd → add.f32 → FADD`，一路都是编译器原生的浮点加

`vadd.ll`（clang IR）里就是一条干净的 `fadd`：
```llvm
%16 = load float, ptr %15, align 4           ; vadd.ll:24
%17 = load float, ptr %14, align 4           ; vadd.ll:25
%18 = fadd contract float %16, %17           ; vadd.ll:26   ← 原生 IR 指令
```
`vadd.ptx`：
```ptx
ld.global.f32  %f1, [%rd8];                   ; vadd.ptx:44   ← typed 32-bit load
ld.global.f32  %f2, [%rd6];                   ; vadd.ptx:45
add.f32        %f3, %f2, %f1;                 ; vadd.ptx:46   ← 原生 PTX 加
```
`vadd.sass`（真卡 `sm_120`，函数体在 L143 起）：
```sass
LDG.E   R2, desc[UR4][R2.64]                  ; vadd.sass:171  ← 32-bit 全局加载
LDG.E   R5, desc[UR4][R4.64]                  ; vadd.sass:175
FADD    R9, R2, R5                            ; vadd.sass:179  ← 原生 FP32 加法器
```

### ② fp16：`__half` 的 `+` **不是**原生指令，是 `cuda_fp16.h` 里写死的内联 PTX

同一句 `a[i] + b[i]`，类型换成 `__half` 后，`vadd.ll` 里**没有 `fadd half`**，而是一条内联汇编调用：
```llvm
%struct.__half = type { i16 }                 ; vadd.ll:6    ← __half 只是包了个 i16 的壳
...
%15 = load i16, ptr %13, align 2              ; vadd.ll:48   ← 当 i16 加载（不是 typed half）
%16 = load i16, ptr %14, align 2              ; vadd.ll:49
%17 = tail call i16 asm "{add.f16 $0,$1,$2;\0A}", "=h,h,h"(i16 %15, i16 %16)   ; vadd.ll:50
```
到 PTX，那段 asm 被**逐字照搬**进来（连花括号都在）：
```ptx
ld.global.u16  %rs2, [%rd6];                  ; vadd.ptx:83   ← 无类型 16-bit load
ld.global.u16  %rs3, [%rd8];                  ; vadd.ptx:86
{add.f16 %rs1,%rs2,%rs3;                      ; vadd.ptx:88   ← 就是上面那行内联 asm
```

**为什么？** `__half` 的 `operator+`（以及 `__hadd`）是 NVIDIA 在 `cuda_fp16.h` 里用内联 PTX
`asm("{add.f16 ...}")` 手写实现的，half 一律用 16-bit 整型寄存器（IR 的 `i16` / PTX 的 `%rs`）当
**不透明载荷**搬运。编译器前端并不把 `__half +` 降级成原生 `fadd`。

一个能印证这点的细节：**这段 `{add.f16}` 在 clang IR 和 nvcc PTX 里长得一模一样**——因为它来自头文件，
不随编译器变。fp32 的 `fadd`/`add.f32` 才是编译器各自生成的。

### ③ bf16：同样是内联 asm，而且**连选哪段 asm 都看 `__CUDA_ARCH__`**

`__nv_bfloat16`（8 位指数 / 7 位尾数，等于截断的 fp32）走的是和 fp16 一模一样的套路——
`vadd.ll` 里也是 `i16` 壳 + 内联 asm，只是指令名变成 `add.bf16`：
```llvm
%struct.__nv_bfloat16 = type { i16 }          ; vadd.ll:7
...
%15 = load i16, ptr %13, align 2              ; vadd.ll:73
%17 = tail call i16 asm "{ add.bf16 $0,$1,$2; }\0A", "=h,h,h"(i16 %15, i16 %16)  ; vadd.ll:75
```
```ptx
{ add.bf16 %rs1,%rs2,%rs3; }                  ; vadd.ptx:132
```

但 bf16 比 fp16 更进一步：**头文件按 `__CUDA_ARCH__` 给出不同的内联 asm**（本机 `nvcc -ptx` 实测）——
因为原生 bf16 算术是 Ampere（sm_80）才有的，比 fp16 的 sm_53 晚：

| 出 PTX 的 arch | `a + b` 实际生成 | 说明 |
|---|---|---|
| `sm_90`（本例） | `{ add.bf16 %rs1,%rs2,%rs3; }` | 干净的原生 bf16 加 |
| `sm_80` | `{.reg .b16 c; mov.b16 c, 0x3f80U; fma.rn.bf16 %rs1,%rs2,c,%rs3;}` | Ampere 有 `fma.rn.bf16` 没独立 add，用 `a*1.0+b` 凑（`0x3f80`=bf16 的 1.0） |
| `sm_75`（Turing） | 一串 `cvt` + `add.s16 …,1` 位运算 | **没有** bf16 硬件，转 fp32 加完再手动舍入回 bf16（软件模拟） |

> 这把第②课加深了一层：fp16/bf16 的 `+` 不只是「头文件内联 asm」，**连选哪段 asm 都是头文件按目标架构 `#if __CUDA_ARCH__` 决策的**。
> 想确认某 arch 到底有没有硬件支持，最直接的办法就是 `nvcc -ptx -arch=sm_XX` dump 出来看（别凭记忆）。

### ④ 真卡 SASS：fp16/bf16 共用 `HADD2`（half2 单元），只用低半道

三个核的加法在 `sm_120` 上并排放：
```sass
HADD2.BF16_V2 R5, R2.H0_H0, R5.H0_H0          ; vadd.sass:41   (bf16)
HADD2         R5, R2.H0_H0, R5.H0_H0          ; vadd.sass:110  (fp16)
FADD          R9, R2, R5                      ; vadd.sass:179  (fp32)
```
看点：
- fp16 与 bf16 **共用同一条 `HADD2` opcode**（half2 成对加法），bf16 只是多个 `.BF16_V2` 修饰符选数据类型——
  两条的首字编码甚至都是 `0x2000…7230`，类型位在控制字里。half2 数据通路是共享的。
- 两者都带 `R2.H0_H0`：只取/用低 16-bit 那一道算，高道浪费——因为真 GPU **没有标量 16-bit 加法器**，
  加一个 half/bf16 也得借 half2 单元。
- 加载/存储相应是 `LDG.E.U16` / `STG.E.U16`（16-bit），fp32 是 `LDG.E` / `STG.E`（32-bit）。

> **这就是 16-bit 浮点的关键认知**：单个 half/bf16 逐元素加，并不会比 fp32 快——加法器半空转、
> 16-bit load 也吃不满访存事务。红利要等到**打包成 `half2`/`__nv_bfloat162`**、一条 `HADD2` 真的同时
> 算两个元素（`.H0_H0` → 两道都用）时才兑现。本例故意只算一个，正是为了把这件事暴露出来。

---

## 三层对照速查

| | fp32 | fp16（`__half`） | bf16（`__nv_bfloat16`） |
|---|---|---|---|
| IR 加法 | `fadd contract float`（原生） | `call i16 asm "{add.f16 …}"` | `call i16 asm "{ add.bf16 …}"` |
| IR 加载 | `load float, align 4` | `load i16, align 2`（`={i16}`） | `load i16, align 2`（`={i16}`） |
| PTX 加法 | `add.f32` | `{add.f16 …}` | `{ add.bf16 …}`（随 arch 变，见上） |
| PTX 加载 | `ld.global.f32`（typed） | `ld.global.u16` | `ld.global.u16` |
| SASS 加法 | `FADD R9, R2, R5` | `HADD2 …H0_H0` | `HADD2.BF16_V2 …H0_H0` |
| SASS 加载 | `LDG.E`（32-bit） | `LDG.E.U16`（16-bit） | `LDG.E.U16`（16-bit） |
| 地址步长 | `IMAD.WIDE …, 0x4`（4 B/元素） | `IMAD.WIDE …, 0x2`（2 B/元素） | `IMAD.WIDE …, 0x2`（2 B/元素） |

## 三个核完全相同的部分（线程模型）

`blockIdx.x * blockDim.x + threadIdx.x` 在三层里的样子，三个核一字不差：

```llvm
%5 = tail call i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()   ; blockIdx.x
%6 = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()    ; blockDim.x
%8 = tail call i32 @llvm.nvvm.read.ptx.sreg.tid.x()     ; threadIdx.x
```
对应 SASS 的特殊寄存器读取 + 整型乘加：
```sass
S2R   R0, SR_TID.X            ; vadd.sass:9    threadIdx.x
S2UR  UR4, SR_CTAID.X         ; vadd.sass:11   blockIdx.x
IMAD  R9, R9, UR4, R0         ; vadd.sass:17   blockDim*blockIdx + threadIdx
```

> 小坑：`cuobjdump` 里函数顺序可能和源码相反——本例 `vadd.sass` 依次是
> `vadd_bf16`（L5）、`vadd_f16`（L74）、`vadd_f32`（L143）。按符号名找，别按出现顺序。

## 读这些产物时盯什么

- IR 里加法是 `fadd` 还是 `call … asm "…"` → 区分「编译器原生」与「头文件内联汇编」。
- 16-bit 类型的载体：IR 的 `i16` / PTX 的 `%rs` / load 是 `.u16` 而非 `.f16` → 它被当作不透明 16-bit。
- 同一段内联 asm 是否随 `-arch` 变（bf16 在 sm_75/80/90 三种写法）→ 头文件用 `__CUDA_ARCH__` 分支。
- SASS 的 `HADD2`(`.BF16_V2`) + `.H0_H0` → 标量 16-bit 浮点跑在 half2 单元、只用一半 → 要打包才划算。
- `IMAD.WIDE` 的立即数步长（`0x4` vs `0x2`）→ 元素字节宽度，顺带看访存粒度。
- `LDG.E` vs `LDG.E.U16` / `add.f32` vs `add.f16`/`add.bf16` → 一眼区分三条数据通路。

## 环境

nvcc 12.8（conda，`/root/miniconda3`），clang-22（出 IR），真卡 RTX 5060 Ti（`sm_120`，Blackwell）。
本目录所有 `.ll`/`.ptx`/`.sass` 都是 `make artifacts` 生成的，可随时 `make clean` 重来。
