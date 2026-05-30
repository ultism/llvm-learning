#include <stddef.h>
/*
 * 列主序 ELLPACK SpMV：每行补齐到 ncols 个非零，列主序存放
 *   vals[c*nrows + r], col[c*nrows + r]
 * 跨行向量化：一条 lane 管一行 r。vals/col 随 r 连续，只有 x 需要 gather，
 * 且没有 per-row 横向归约（每个 r 各自累加到 y[r]）。
 */
void ell_spmv(const float *restrict vals, const int *restrict col,
              int nrows, int ncols,
              const float *restrict x, float *restrict y)
{
    for (int r = 0; r < nrows; r++) y[r] = 0.0f;
    for (int c = 0; c < ncols; c++)
        for (int r = 0; r < nrows; r++) {
            size_t o = (size_t)c * nrows + r;
            y[r] += vals[o] * x[col[o]];      /* vals/col 连续；x 间接 → gather */
        }
}
