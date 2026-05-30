#include <stddef.h>
/* 非结构化稀疏 SpMV:y = A*x，A 用 CSR。内层 x[col[k]] 逐元素间接 → 期望 gather */
void csr_spmv(const float *restrict val, const int *restrict col,
              const int *restrict rowptr, const float *restrict x,
              float *restrict y, int m)
{
    for (int i = 0; i < m; i++) {
        float s = 0.0f;
        for (int k = rowptr[i]; k < rowptr[i+1]; k++)
            s += val[k] * x[col[k]];          /* ← 间接访问 x */
        y[i] = s;
    }
}
