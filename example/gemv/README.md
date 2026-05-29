# dot / GEMV —— 用点积学读 LLVM IR

目的:用一个**比超越函数干净得多**的核——浮点点积(GEMV 的内层,无后处理)——
来看清 LLVM IR 里最值得学的一件事:**浮点归约为什么默认不向量化,`-ffast-math` 到底改了什么。**

```
dot(a,b,n) = Σ a[i]*b[i]            (归约循环)
GEMV: y[i] = dot(A[i,:], x)          A 为 m×n,行主序,无 bias/激活
```

## 文件

| 文件 | 内容 |
|---|---|
| `dot.h` | 接口:`dot_scalar` / `dot_avx512` / `gemv_scalar` / `gemv_avx512` |
| `dot_scalar.c` | 朴素标量归约 `s += a[i]*b[i]` —— 看自动向量化 |
| `dot_avx512.c` | 手写 AVX512:4 累加器 + FMA + 掩码尾巴 + 横向归约 |
| `main.c` | 正确性测试(对 `double` 参考),含各种长度覆盖主循环/收尾/尾巴 |
| `Makefile` | `run` / `asm` / `ir` / `clean` |

## 跑

```sh
make run      # 正确性
make ir       # dump 三份 IR(见下)
make asm      # dump 汇编(Intel 语法)
```

## 核心一课:浮点归约 + `-ffast-math`(✅ 全部本机实测,clang 15 / Zen5)

### ① 默认严格 FP:归约**不**向量化

```sh
clang -O3 -march=native -mprefer-vector-width=512 -emit-llvm -S dot_scalar.c
```
```
remark: loop not vectorized: cannot prove it is safe to reorder
        floating-point operations; ... '-ffast-math'.
```

原因:`a+b+c+…` 用 float 做,**加法不满足结合律**——把串行求和拆成多路并行 SIMD 求和会得到不同的舍入结果,编译器不敢擅自重排。

IR 里循环体是**标量串行**的一条链(注意是 `f32`,不是 `<16 x float>`):
```llvm
%24 = tail call float @llvm.fmuladd.f32(float %21, float %23, float %18)
```
汇编是 `vfmadd…ss`(`ss` = scalar single,一次一个元素),即便 clang 把循环展开 4 次,
四条 FMA 仍是**同一条依赖链**(下一条等上一条的结果):
```asm
vfmadd132ss xmm1, xmm0, [rsi+4*rcx]        ; xmm1 = xmm1*mem + xmm0
vfmadd231ss xmm1, xmm2, [rsi+4*rcx+4]      ; xmm1 = xmm2*mem + xmm1   ← 依赖上一条
vfmadd132ss xmm2, xmm1, [rsi+4*rcx+8]      ; ...
```

> 注:这里已经有 FMA(`fmuladd`)了——因为 `-ffp-contract` 在 `-O3` 默认开,
> `a*b+c` 在**单条语句**内允许收缩成一条 FMA。这跟"向量化"是两件独立的事:
> **收缩**改的是 `a*b+c→fma`(精度只增不减,默认允许);**重排归约**改的是求和顺序(默认禁止)。

### ② 加 `-ffast-math`:重新结合被放行 → 向量化

```sh
clang -O3 -march=native -mprefer-vector-width=512 -ffast-math -emit-llvm -S dot_scalar.c
```
```
remark: vectorized loop (vectorization width: 16, interleaved count: 4)
```

`width 16` = 一个 zmm 装 16 个 float;`interleaved 4` = **4 个独立累加器**并行展开
(隐藏 FMA 延迟)。IR 里出现 4 个向量 phi 累加器和横向归约:
```llvm
%13 = phi <16 x float> [ zeroinitializer, %9 ], [ %37, %11 ]   ; 4 个这样的累加器
...
%33 = fmul fast <16 x float> %26, %18          ; 注意 IR 这里是分开的 fmul/fadd
%37 = fadd fast <16 x float> %33, %13
...
%46 = fadd fast <16 x float> %40, %45           ; 先把 4 个累加器树状合并
%47 = tail call fast float @llvm.vector.reduce.fadd.v16f32(float -0.0, <16 x float> %46)
```
后端指令选择阶段再把 `fmul fast`+`fadd fast` **融合回** `vfmadd231ps zmm`:
```asm
vfmadd231ps zmm0, zmm4, [rdi+4*rcx]      ; 4 个独立累加器 zmm0..zmm3
vfmadd231ps zmm1, zmm5, [rdi+4*rcx+64]
...
vaddps zmm0, zmm1, zmm0                   ; 树状合并 4 累加器
```

> 一个常被忽略的细节:**IR 层不一定是 `fmuladd`**。这里向量化器吐的是分开的
> `fmul`/`fadd`,FMA 融合发生在更后面(指令选择)。所以"IR 里没看到 fma"≠"最终没用 FMA"——要看汇编。

### ③ 手写 `dot_avx512.c` = 自动版的"人工复刻"

`make ir` 出的 `dot_avx512.ll` / `dot_avx512.s` 里能看到,我手写的结构和
`-ffast-math` 自动生成的**几乎逐条对应**:

| | `-ffast-math` 自动 | 手写 intrinsic |
|---|---|---|
| 累加器 | 4 × `<16 x float>` | 4 × `__m512` |
| 主循环宽度 | 64 float/轮 | 64 float/轮 |
| 主体指令 | `vfmadd231ps zmm` | `vfmadd231ps zmm` |
| 合并 | 树状 `vaddps` | 树状 `vaddps` |
| 横向求和 | `llvm.vector.reduce.fadd` | `_mm512_reduce_add_ps`(→ `vextract`+`vaddps` 树) |
| 尾巴 | 标量 epilogue | 掩码 `{k1}{z}` 加载 |

也就是说:**这个核根本不需要手写 intrinsic**,`-ffast-math` 一个开关就能拿到等价代码。
手写版的价值只在于:① 不想全局开 `-ffast-math` 时局部精确控制;② 看懂自动版在干什么。

## 读 IR 时盯这几个东西

- `phi <16 x float>` 的个数 → interleave/累加器路数
- `fmul fast` / `fadd fast` 上的 `fast`(或 `reassoc`/`contract`)标志 → 哪些重排被允许了
- `@llvm.vector.reduce.fadd.vNf32` → 横向归约,N 是宽度
- `@llvm.fmuladd.f32` → 前端收缩出的 FMA(跟向量化无关)
- remark `vectorized loop (width …, interleaved …)` / `loop not vectorized: … reorder …`

## 一个数值小彩蛋

`make run` 里 n 越大,**AVX512 反而比标量更接近 double 参考**——多累加器把求和拆成
多条短链,累积舍入误差比单条长链更小。这正是"浮点加法不结合"的另一面:重排不仅快,有时还更准。

## 环境

AMD Ryzen 7 9800X3D(Zen5,AVX512F/DQ),Ubuntu 22.04,clang 15(系统默认即可)。
本目录所有 `.ll` / `.s` 都是 `make ir` / `make asm` 生成的,可随时 `make clean` 重来。
