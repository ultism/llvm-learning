# 稀疏 GEMM:什么时候 gather,什么时候不 —— 关键看"间接的粒度"

实测对比两种稀疏(Zen5/AVX512,clang 15,`-O3 -march=native -ffast-math -mprefer-vector-width=512`)。

| 核 | 稀疏形式 | 间接发生在 | 编译器生成 |
|---|---|---|---|
| `csr_spmv` | 非结构化(CSR,**朴素逐行**)| **每个元素** `x[col[k]]` | ✅ 向量 GEP `<16 x ptr>` + `masked.gather` + `vgatherdps`,**且每行一次横向归约** |
| `bsr_spmm` | 块稀疏(BSR)| **每个块** `col_idx[b]`(一次标量基址)| ❌ 无 gather;块内稠密连续 → `vbroadcastss` + 连续 load/fma |
| `ell_spmv` | 非结构化但**重排成列主序 ELL** | **每个元素** `x[col[o]]` | gather 仍在,但 `vals`/`col` **连续 `vmovups`**,**无 per-row 横向归约**(跨行向量化)|

证据:
```
csr_spmv:  getelementptr inbounds float, ptr %3, <16 x i64> %51   ; x 的逐 lane 地址
           vgatherdps zmm9 {k1}, zmmword ptr [rcx + 4*zmm5]
bsr_spmm:  (无 vector GEP / 无 masked.gather)
           vbroadcastss zmm1, xmm0                                 ; 块内 a 广播
```

## 结论:block-sparse 恰恰是为"避开 gather"而设计的

> gather 出现与否,取决于**间接索引的粒度**:
> - **逐元素间接**(非结构化 CSR/COO):每条 lane 一个独立地址 → 必须 gather,慢。
> - **块级间接**(BSR):`col_idx[b]` 只用一次算出块基址(标量指针算术),**块内全是稠密连续访问**,能用 `vfmadd` + `broadcast` 跑满 SIMD。

这正是块稀疏在硬件上更快的原因——它用"块结构"换回了稠密微核的局部性,刻意不落到 gather。

## 一个边界条件

块要**足够大**(`BS ≥ 向量宽度`且连续存储)才有这个好处:块内连续访问才能摊薄那次块级间接。
若块退化到 1×1,就等价于非结构化稀疏,又回到 gather。所以"块稀疏不 gather"的前提是块够大。

## 真实 SpMV 不用朴素 CSR(`csr_spmv` vs `ell_spmv`)

`csr_spmv.c` 是教科书朴素版:逐行、行内对 k 归约。行长不定 → 向量化要靠 gather + **每行一次 `reduce.fadd`** + 短行的标量尾巴,效率差。

高性能库会**预先重排成规则结构 + 索引表**,把"每行一个归约"换成"**一条 lane 管一行**":

- **ELLPACK**(`ell_spmv.c`):每行补齐到最长行,列主序存(`vals[c*nrows+r]`)。内层跨行 `r`:`vals`/`col` 连续 `vmovups`,只有 `x` gather,**没有横向归约**(每个 r 各自累加进 `y[r]`)。
- **SELL-C-σ**:ELL 的 SIMD 版,按向量宽切片 + 窗口内按行长排序减少 padding。CPU 上向量化 SpMV 的事实标准。
- **CSR5**:CSR 上加 `tile_ptr`/`tile_desc` 辅助表,2D tile + **segmented sum** 归约,负载均衡。

实测对照(`make ir` 后 grep):

| | `csr_spmv`(朴素逐行)| `ell_spmv`(列主序 ELL,跨行)|
|---|---|---|
| 向量化方向 | 行内对 k 归约 | 跨行,lane=行 |
| `vals`/`col` | 跨步/标量 | 连续 `vmovups` |
| `x` | gather | gather(躲不掉)|
| `vector.reduce.fadd` | 有 | **0** |

要点:gather(x 的间接)躲不掉,但**把不规则性挪到预处理(建 ELL/SELL/CSR5 表),热循环就变成等宽、无分支、连续流式 + 单一 gather**——这才是 SpMV 实际的样子。
