#include "dot.h"
#include <immintrin.h>

/*
 * AVX512 点积,手写归约。
 *
 * 用 4 个独立累加器展开主循环:FMA 有延迟(Zen5 上 ~4 周期)但吞吐高,
 * 单累加器会被延迟卡住(下一条 FMA 要等上一条结果)。4 路累加器让流水线
 * 填满,最后再把 4 个 __m512 合并、横向求和。这正是 -ffast-math 下编译器
 * 对标量循环自动做的事(只是它通常展开成 2~4 路)。
 */
float dot_avx512(const float *a, const float *b, size_t n)
{
    __m512 acc0 = _mm512_setzero_ps();
    __m512 acc1 = _mm512_setzero_ps();
    __m512 acc2 = _mm512_setzero_ps();
    __m512 acc3 = _mm512_setzero_ps();

    size_t i = 0;
    /* 主循环:每轮 64 个 float */
    for (; i + 64 <= n; i += 64) {
        acc0 = _mm512_fmadd_ps(_mm512_loadu_ps(a + i),      _mm512_loadu_ps(b + i),      acc0);
        acc1 = _mm512_fmadd_ps(_mm512_loadu_ps(a + i + 16), _mm512_loadu_ps(b + i + 16), acc1);
        acc2 = _mm512_fmadd_ps(_mm512_loadu_ps(a + i + 32), _mm512_loadu_ps(b + i + 32), acc2);
        acc3 = _mm512_fmadd_ps(_mm512_loadu_ps(a + i + 48), _mm512_loadu_ps(b + i + 48), acc3);
    }

    /* 合并 4 路累加器 */
    __m512 acc = _mm512_add_ps(_mm512_add_ps(acc0, acc1), _mm512_add_ps(acc2, acc3));

    /* 收尾:整 16 个一批 */
    for (; i + 16 <= n; i += 16)
        acc = _mm512_fmadd_ps(_mm512_loadu_ps(a + i), _mm512_loadu_ps(b + i), acc);

    /* 尾巴:< 16 个,用掩码加载,越界 lane 读 0 */
    size_t rem = n - i;
    if (rem) {
        __mmask16 m = (__mmask16)((1u << rem) - 1u);
        __m512 va = _mm512_maskz_loadu_ps(m, a + i);
        __m512 vb = _mm512_maskz_loadu_ps(m, b + i);
        acc = _mm512_fmadd_ps(va, vb, acc);
    }

    return _mm512_reduce_add_ps(acc); /* 横向求和:16 lane -> 1 标量 */
}

void gemv_avx512(const float *A, const float *x, float *y, size_t m, size_t n)
{
    for (size_t i = 0; i < m; i++)
        y[i] = dot_avx512(A + i * n, x, n);
}
