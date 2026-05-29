#include "dot.h"

/*
 * 标量点积:一个最朴素的归约循环。
 *
 * 关键点(学 IR 的核心):浮点加法不满足结合律,所以编译器默认
 * **不能**把这个串行归约重排成多路 SIMD 求和——重排会改变结果。
 * 因此 -O3 单独看到这个循环时,它要么完全不向量化,要么只能做
 * "有序归约"(serial,收益有限)。加上 -ffast-math / -freassociate
 * 后,编译器才被允许重新结合,从而拆成多个累加器 + FMA + 横向归约。
 */
float dot_scalar(const float *a, const float *b, size_t n)
{
    float s = 0.0f;
    for (size_t i = 0; i < n; i++)
        s += a[i] * b[i];
    return s;
}

void gemv_scalar(const float *A, const float *x, float *y, size_t m, size_t n)
{
    for (size_t i = 0; i < m; i++)
        y[i] = dot_scalar(A + i * n, x, n);
}
