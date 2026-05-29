/*
 * Scalar reference implementation of the exact GELU.
 *
 *   GELU(x) = 0.5 * x * (1 + erf(x / sqrt(2)))
 *
 * This leans on the C standard library's erff(), so it is as accurate as the
 * platform libm and serves as the "ground truth" the AVX-512 version is
 * checked against in main.c.
 */
#include "gelu.h"
#include <math.h>

/* 1 / sqrt(2) */
#define INV_SQRT2 0.70710678118654752440f

float gelu_scalar(float x)
{
    return 0.5f * x * (1.0f + erff(x * INV_SQRT2));
}

void gelu_scalar_array(const float *in, float *out, size_t n)
{
    for (size_t i = 0; i < n; ++i)
        out[i] = gelu_scalar(in[i]);
}
