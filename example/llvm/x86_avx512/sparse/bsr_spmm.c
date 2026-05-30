#include <stddef.h>
/* 块稀疏 BSR：对一个块行，累加 nnzb 个稠密块的贡献到 C(BS×N)。
   间接只在块级：col_idx[b] 一次标量查出 B 的块基址；块内是稠密连续小 GEMM。*/
void bsr_spmm(const float *restrict Avals, const int *restrict col_idx, int nnzb,
              const float *restrict B, float *restrict C, int N, int BS)
{
    for (int b = 0; b < nnzb; b++) {
        const float *Ablk = Avals + (size_t)b * BS * BS;
        const float *Bblk = B + (size_t)col_idx[b] * BS * N;   /* 块级间接：标量基址 */
        for (int ii = 0; ii < BS; ii++)
            for (int kk = 0; kk < BS; kk++) {
                float a = Ablk[ii*BS + kk];                    /* 块内不变量 → broadcast */
                for (int j = 0; j < N; j++)
                    C[ii*N + j] += a * Bblk[kk*N + j];         /* 块内连续 */
            }
    }
}
