#ifndef DOT_H
#define DOT_H

#include <stddef.h>

/* 点积:返回 sum_{i<n} a[i]*b[i] (无后处理) */
float dot_scalar(const float *a, const float *b, size_t n);
float dot_avx512(const float *a, const float *b, size_t n);

/* GEMV(行主序,无后处理):y[i] = dot(A[i,:], x),A 为 m×n */
void gemv_scalar(const float *A, const float *x, float *y, size_t m, size_t n);
void gemv_avx512(const float *A, const float *x, float *y, size_t m, size_t n);

#endif /* DOT_H */
