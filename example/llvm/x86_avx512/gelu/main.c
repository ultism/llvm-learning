/*
 * Demo / test harness for the GELU implementations.
 *
 *   - prints a small table of values across a representative input range
 *   - reports the max absolute & relative error of the AVX-512 version
 *     against the scalar libm reference over a dense sweep
 *   - runs a rough throughput benchmark of both
 *
 * Build:  make           (clang -O3 -march=native)
 * Run:    ./gelu_demo
 */
#define _POSIX_C_SOURCE 199309L   /* expose clock_gettime under -std=c11 */
#include "gelu.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

static double now_sec(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec * 1e-9;
}

int main(void)
{
    /* ---- 1. A readable table of sample points ------------------------ */
    const float pts[] = {-6.f, -3.f, -2.f, -1.f, -0.5f, 0.f,
                          0.5f, 1.f, 2.f, 3.f, 6.f};
    const int np = (int)(sizeof(pts) / sizeof(pts[0]));

    printf("        x      scalar(libm)        avx512        abs.err\n");
    printf("  ----------------------------------------------------------\n");
    for (int i = 0; i < np; ++i) {
        float s, v;
        gelu_scalar_array(&pts[i], &s, 1);
        gelu_avx512_array(&pts[i], &v, 1);
        printf("  %8.3f   %14.8f  %14.8f   %.2e\n",
               pts[i], s, v, fabsf(s - v));
    }

    /* ---- 2. Accuracy sweep over [-8, 8] ------------------------------ */
    const size_t N = 1u << 20;            /* ~1M points */
    float *in  = malloc(N * sizeof(float));
    float *ref = malloc(N * sizeof(float));
    float *got = malloc(N * sizeof(float));
    if (!in || !ref || !got) { perror("malloc"); return 1; }

    for (size_t i = 0; i < N; ++i)
        in[i] = -8.0f + 16.0f * (float)i / (float)(N - 1);

    gelu_scalar_array(in, ref, N);
    gelu_avx512_array(in, got, N);

    double max_abs = 0.0, max_rel = 0.0;
    for (size_t i = 0; i < N; ++i) {
        double abs_e = fabs((double)ref[i] - (double)got[i]);
        if (abs_e > max_abs) max_abs = abs_e;
        /* Relative error only where GELU is not near-zero; otherwise the
         * tiny denominator inflates it and absolute error is what matters. */
        double denom = fabs((double)ref[i]);
        if (denom > 0.1) {
            double rel_e = abs_e / denom;
            if (rel_e > max_rel) max_rel = rel_e;
        }
    }
    printf("\n  Accuracy over [-8, 8], %zu points:\n", N);
    printf("    max |scalar - avx512|             = %.3e\n", max_abs);
    printf("    max relative error (|GELU| > 0.1) = %.3e\n", max_rel);

    /* ---- 3. Throughput benchmark ------------------------------------- */
    const int reps = 200;
    volatile float sink = 0.f;

    double t0 = now_sec();
    for (int r = 0; r < reps; ++r) gelu_scalar_array(in, ref, N);
    double t_scalar = now_sec() - t0;
    sink += ref[N / 2];

    t0 = now_sec();
    for (int r = 0; r < reps; ++r) gelu_avx512_array(in, got, N);
    double t_avx = now_sec() - t0;
    sink += got[N / 2];

    double total = (double)N * reps;
    printf("\n  Throughput (%d reps x %zu elems):\n", reps, N);
    printf("    scalar : %6.1f ms   %6.2f Melem/s\n",
           t_scalar * 1e3, total / t_scalar / 1e6);
    printf("    avx512 : %6.1f ms   %6.2f Melem/s   (%.2fx)\n",
           t_avx * 1e3, total / t_avx / 1e6, t_scalar / t_avx);

    (void)sink;
    free(in); free(ref); free(got);
    return 0;
}
