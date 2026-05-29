# 在 x86(尤其 AMD)上向量化 erf —— 一篇踩坑笔记

> 起因:用 AVX512 实现 GELU,需要向量化的 `erf`。围绕"x86 上怎么拿到向量 erf、编译器能不能自动搞定"做了一圈验证。
> 环境:AMD Ryzen 7 9800X3D(Zen5,AVX512F/DQ),Ubuntu 22.04(glibc 2.35),clang 15 / 18.1.7 / 22.1.7,Intel oneAPI icx 2026.0,SLEEF 3.5.1。
> 本文只记"能不能/怎么做/为什么",不涉及性能基准。**标 ✅实测 的是真在本机跑过的结论。**

## 0. 背景:GELU 的精确形式离不开 erf

```
GELU(x) = x · Φ(x) = 0.5 · x · (1 + erf(x / √2))
```

`Φ` 是标准正态 CDF,`erf` 是误差函数。要把 GELU 向量化,核心就是**向量化 erf**(本文不走 tanh 近似那条)。

## 1. 关键事实:x86 没有原生 erf 指令

x86 AVX512 **没有**单条计算 erf 的机器指令(`exp` 同理;AVX512ER 的 `vexp2ps` 只在 Xeon Phi 上、且只算 2^x)。所以"向量 erf"必然来自:**手写多项式、或某个向量数学库**。Intel SVML 的 `_mm512_erf_ps` 是 intrinsic,不是单条指令。

> ⚠️ 我一开始误判成"x86/AMD 没法向量化 erf、那是 Intel SVML 的专利"——**错的**。下面这些路子都行。

## 2. 五条能拿到向量 erf 的路(✅ 全部实测)

| # | 方法 | 怎么做 | 跟 libm 的最大绝对误差 |
|---|---|---|---|
| 1 | **手搓多项式** | Abramowitz & Stegun 7.1.26 + 自写向量 `exp` | 4.77e-7 |
| 2 | **SLEEF intrinsic** | `Sleef_erff16_u10(__m512)`,`-lsleef` | 2.38e-7(1 ULP) |
| 3 | **glibc libmvec 符号** | 自己声明 `extern __m512 _ZGVeN16v_erff(__m512);` + `-lmvec` | 1.19e-7 |
| 4 | **Intel SVML intrinsic** | `_mm512_erf_ps(__m512)`,用 icx 编(自动链 libsvml) | 1.79e-7 |
| 5 | **AMDLibM 符号** | `amd_vrs16_erff`(自动向量化产出,见 §4),链 AMD libm 或自写 shim 转发 SLEEF | 1.26e-7 |

第 2 条是本项目 `gelu_avx512.c` 采用的方案:**不挑编译器版本、不依赖系统库、跨平台,最稳。**

`_ZGVeN16v_erff` 的命名(GNU 向量 ABI):`_ZGV` + `e`(AVX512;b/c/d=SSE/AVX/AVX2)+ `N`(无掩码)+ `16`(lane 数)+ `v`(向量传参)+ `_erff`。

## 3. 真正想要的是"自动向量化":写标量循环,编译器变 SIMD

理想是这样,业务代码保持干净:

```c
for (size_t i = 0; i < n; i++)
    out[i] = 0.5f*in[i]*(1.0f + erff(in[i]*0.70710678f));   // 纯标量,零 intrinsic
```

机制是 `-fveclib=<lib>`:给 LLVM 的循环向量化器一张**映射表**(源码 `llvm/include/llvm/Analysis/VecFuncs.def`,每个 lib 一段),把标量 `erff` 换成向量库调用并拓宽循环。触发还需要:
- `-ffast-math` / `-fno-math-errno`(去掉 libm 的 errno 副作用,否则不敢替换);
- `-mprefer-vector-width=512`(否则 x86 默认常停在 256 位)。

## 4. clang 各 veclib 对 erf 的支持(✅ 实测 + 读源码)

读 `VecFuncs.def` 和消费侧 `TargetLibraryInfo.cpp` 得到:

| `-fveclib=` | x86 表里有 erf? | 备注 |
|---|---|---|
| `libmvec` | ❌ | 表里只有 `expf`(到 N8/AVX2),**没 erf**。注意:glibc 的 `.so` 其实导出了 `_ZGVeN16v_erff`,但 **LLVM 的映射表没收录**,所以自动向量化用不上(只能像 §2 第 3 条那样手动调) |
| `SVML` | ❌ | 表里 `expf` 有 N4/N8/N16,但**没 erf** |
| `SLEEF` | ❌ | SLEEF 的 erf 条目全是 ARM token(`_ZGVnN4v`/`_ZGVsMxv`);`TargetLibraryInfo.cpp` 里 `SLEEFGNUABI` 的分发 **只有 aarch64/RISCV 分支,没有 x86_64**——在 x86 上 `-fveclib=SLEEF` 是空操作 |
| `AMDLIBM` | ✅ | **唯一**带 x86 erf 的:`amd_vrs16_erff`(FIXED(16)=AVX512),分发不挑架构 |

**✅ clang-22 实测**:
```
clang-22 -O3 -march=native -ffast-math -fveclib=AMDLIBM -mprefer-vector-width=512 \
         -emit-llvm -S gelu_scalar.c
→ remark: vectorized loop (vectorization width: 16)
→ IR: call <16 x float> @amd_vrs16_erff(...)   # 纯标量源码自动变 AVX512
```
要真跑得链接 AMD 的 libm(AOCL-LibM);或者**自写 shim** 让 `amd_vrs16_erff` 转发给 SLEEF —— `-fveclib` 只认符号名,谁实现都行(✅ 实测可行,误差 1.26e-7):
```c
__m512 amd_vrs16_erff(__m512 x){ return Sleef_erff16_u10(x); }
```

## 5. 版本时间线(✅ 全部用本机 clang 实测)

| clang | `-fveclib` 接受 `AMDLIBM`? | x86 erf 自动向量化 |
|---|---|---|
| 15.0.7 | ❌ invalid value | 不行 |
| 18.1.7 | ❌ invalid value | 不行 |
| 22.1.7 | ✅ | **行 → `amd_vrs16_erff`** |

注:`SLEEF`/`ArmPL` 这两个值在 clang **15/18/22 里都被拒**(对 x86 也无意义,见上)。AMDLIBM 落在 (18, 22] 之间某版引入。

## 6. Intel icx:最省事的"自动"路(✅ 实测)

Intel oneAPI 的 icx(LLVM 内核)**默认就用 SVML 向量化数学库调用**,不用 `-fveclib`、不用手动链接:

```
icx -O3 -march=native  : 标量 erff 循环 → U __svml_erff16_z0    ✅ 自动用上 SVML
clang-22 同代码         : → U erff                               ❌ 只能标量
```

- `_mm512_erf_ps` intrinsic 也可直接用 → 落到 `__svml_erff16_z0`,**libsvml 静态链入**(`ldd` 看不到依赖)。
- SVML 就是段 AVX512 代码,**在 AMD Zen 上照跑**(误差 1.79e-7)。

> 这一点纠正了我"SVML 不支持 erf"的说法:我只看了 **clang 的 `-fveclib=SVML` 映射表**(那确实没 erf),而 **SVML 库本身 + icx 是有 erf 的**。

### icx 的一个限制:不能 dump LLVM IR(✅ 实测)

```
icx -emit-llvm -S          → error: IR output is not supported.
icx -c -emit-llvm          → LLVM ERROR: Bitcode output disabled because
                             proprietary optimizations have been performed.
icx -S                     → ✅ 汇编正常(含 call __svml_erff16_z0)
```
Intel 在 IR 上跑了私有优化 pass,**故意禁掉 IR/bitcode 导出**保护 IP。想看 IR 用 clang;想看 icx 生成啥只能看汇编;想看其优化决策用 `-qopt-report`。

## 7. 结论

- **想要干净标量源 + 自动 SIMD**:icx 最顺(默认接 SVML,AMD 上能跑);clang 则要 `-fveclib=AMDLIBM`(clang 22+,且 AMD 库 / SLEEF shim)。
- **想要跨编译器、轻量、可移植**:直接写 intrinsic 调 **SLEEF `Sleef_erff16_u10`**(本项目的选择)。
- clang 的 `libmvec`/`SVML`/`SLEEF` 这三条 veclib 在 x86 上对 erf **都不通**,别白费劲。

## 8. 几个被实测推翻的假设(留作教训)

1. ❌「AMD/x86 没法向量化 erf,是 Intel SVML 专利」→ 至少 5 条路都行。
2. ❌「clang 16+ 用 `-fveclib=libmvec` 能映射 erf」→ LLVM 的 x86-libmvec 表从来没 erf。
3. ❌「SVML 表里有 erf」→ clang 的 SVML 映射表没有(但 SVML 库 / icx 有)。
4. ❌「clang 17+ 用 `-fveclib=SLEEF` 解决 x86」→ SLEEF 在 x86 无分发;且 clang 18/22 连 `SLEEF` 这个值都不收。
5. ❌ 多次把 AMDLIBM 的引入版本猜早 → 最后靠 clang-18/22 实测钉死。

> **教训**:工具链/库的版本行为别凭记忆下结论——编个探针、读源码、或直接试。

## 附:复现要点

```sh
# clang 自动向量化(需 clang 22+;真跑需 AMD libm 或 SLEEF shim)
clang-22 -O3 -march=native -ffast-math -fveclib=AMDLIBM -mprefer-vector-width=512 -emit-llvm -S gelu_scalar.c

# icx 自动用 SVML(Intel oneAPI)
source /opt/intel/oneapi/setvars.sh
icx -O3 -march=native gelu_svml_demo.c -lm -o gelu_svml_demo.out   # _mm512_erf_ps → __svml_erff16

# 查 veclib 映射表 / 分发逻辑(LLVM 源码)
#   llvm/include/llvm/Analysis/VecFuncs.def
#   llvm/lib/Analysis/TargetLibraryInfo.cpp
```
