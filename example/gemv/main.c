#define _POSIX_C_SOURCE 199309L
#include "dot.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* 双精度参考:点积用 double 累加,作为"正确答案" */
static double dot_ref(const float *a, const float *b, size_t n)
{
    double s = 0.0;
    for (size_t i = 0; i < n; i++)
        s += (double)a[i] * (double)b[i];
    return s;
}

static float frand(void) { return (float)rand() / (float)RAND_MAX - 0.5f; }

int main(void)
{
    srand(1);

    /* ---- 单个点积:扫不同长度,覆盖主循环 / 收尾 / 掩码尾巴 ---- */
    printf("== dot product ==\n");
    printf("%6s  %14s  %14s  %14s\n", "n", "scalar", "avx512", "ref(double)");
    const size_t lens[] = { 1, 7, 16, 17, 63, 64, 65, 1000, 4096, 100000 };
    for (size_t k = 0; k < sizeof(lens) / sizeof(lens[0]); k++) {
        size_t n = lens[k];
        float *a = malloc(n * sizeof *a), *b = malloc(n * sizeof *b);
        for (size_t i = 0; i < n; i++) { a[i] = frand(); b[i] = frand(); }

        float  s = dot_scalar(a, b, n);
        float  v = dot_avx512(a, b, n);
        double r = dot_ref(a, b, n);
        printf("%6zu  %14.6f  %14.6f  %14.6f   |Δavx-ref|=%.2e\n",
               n, s, v, r, fabs((double)v - r));
        free(a); free(b);
    }

    /* ---- GEMV:y = A·x,校验两种实现一致 ---- */
    printf("\n== gemv  (y = A * x, A is m x n) ==\n");
    size_t m = 37, n = 257;
    float *A = malloc(m * n * sizeof *A);
    float *x = malloc(n * sizeof *x);
    float *ys = malloc(m * sizeof *ys), *yv = malloc(m * sizeof *yv);
    for (size_t i = 0; i < m * n; i++) A[i] = frand();
    for (size_t i = 0; i < n; i++) x[i] = frand();

    gemv_scalar(A, x, ys, m, n);
    gemv_avx512(A, x, yv, m, n);

    double maxabs = 0, maxrel = 0;
    for (size_t i = 0; i < m; i++) {
        double ref = dot_ref(A + i * n, x, n);
        double ea = fabs((double)yv[i] - ref);
        double er = ea / (fabs(ref) + 1e-12);
        if (ea > maxabs) maxabs = ea;
        if (er > maxrel) maxrel = er;
    }
    printf("m=%zu n=%zu :  max|avx-ref|=%.2e   max rel=%.2e\n", m, n, maxabs, maxrel);
    printf("y[0]  scalar=%.6f  avx512=%.6f\n", ys[0], yv[0]);

    free(A); free(x); free(ys); free(yv);
    return 0;
}
