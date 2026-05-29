# 什么数学模式会生成"向量 GEP / gather" —— 一次实测

起因:LLVM 文档说 `getelementptr` 的参数含向量时返回**指针向量**(`<N x ptr>`),标量参数被广播。
想找个真能生成这种 IR 的例子。结论是:**只有"间接/聚集"访问才会**,常规跨步矩阵访问反而不会。

环境:AMD Zen5(AVX512),clang 15,`-O3 -march=native -ffast-math -mprefer-vector-width=512`。

## 三段对照(`make ir` / `make asm` / `make remarks` 复现)

| 核 | 内层循环 | 访问模式 | 编译器实际生成 |
|---|---|---|---|
| `gemm_ijk` | k | `B[k*N+j]` 随 k 跨步 N(取列)| ❌ **不 gather**:按 `N==1` 做循环版本化(那时列恰好连续 → 向量化),`N>1` 的真实矩阵**退化成标量** |
| `gemm_ikj` | j | `B[k*N+j]` 随 j 连续;`A[i*K+k]` 不变 | **broadcast**(`vbroadcastss`)+ 连续 load/store,**无 gather** |
| `gather_index` | i | `x[idx[i]]` 间接索引,地址不相邻 | ✅ **向量 GEP `<16 x ptr>` + `llvm.masked.gather` + `vgatherdps`** |

## 关键 IR:`gather_index` 里的向量 GEP

```llvm
%23 = load <16 x i32>, ptr %22                          ; idx[i..i+15] 连续 int load
%24 = sext <16 x i32> %23 to <16 x i64>                 ; 索引扩到 64 位
%25 = getelementptr inbounds float, ptr %0, <16 x i64> %24   ; ★ base 标量(广播) + index 向量 → <16 x ptr>
%26 = call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %25, i32 4, <16 x i1> <...>, <16 x float> undef)
```
汇编:`vgatherdps (%rdi,%zmm0,4), %zmm1 {%k1}`。

## 三个被实测纠正/确认的点

1. **直觉"跨步访问 → gather"只对了一半。** 编译器对规则跨步(如矩阵列)更倾向 *循环版本化 + 标量回退*,而不是 gather——gather 在成本模型里很贵。真正稳定触发 gather 的是**数据相关的间接索引** `x[idx[i]]`。
2. **`restrict` 是硬门槛。** `gather_index` 不加 `restrict` → `loop not vectorized: cannot identify array bounds`(无法证明 `x[idx[i]]` 不与 `y` 别名),直接标量化。加上才向量化出 gather。
3. **真实 GEMM 从不 gather。** 高性能 GEMM 靠分块(tiling)+ 打包(packing)把所有访问做成**连续 + 广播**(就是 `gemm_ikj` 那条路的极致版),刻意避开 gather/scatter。所以"两个 row-major 矩阵直接 ijk"既不会 gather,也不是该追求的写法。

> 一句话:**向量 GEP / gather 不是"非连续就会有",而是"编译器既无法重排成连续、又证明了安全(restrict)、还判定值得"时才出现——间接索引是它的典型场景。**
