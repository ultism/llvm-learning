/*
 * AVX-512 implementation of the exact (erf-based) GELU, using SLEEF.
 *
 *   GELU(x) = 0.5 * x * (1 + erf(x / sqrt(2)))
 *
 * x86 has no single machine instruction for erf, but vectorised erf on
 * AVX-512 is readily available on any AVX-512 CPU (Intel *and* AMD Zen 4/5).
 * Here we use SLEEF's Sleef_erff16_u10 (16 floats wide, <= 1.0 ULP error)
 * instead of hand-rolling the polynomial, so the only thing we write by hand
 * is the cheap GELU wrapper around it.
 *
 * Build:  clang -O3 -march=native ... -lsleef
 *         (-march=native enables AVX-512F, which Sleef_erff16_u10 requires)
 */
#include "gelu.h"
#include <immintrin.h>
#include <sleef.h>

/* GELU(x) = 0.5 * x * (1 + erf(x / sqrt(2)))  over 16 floats. */
static inline __m512 gelu512_ps(__m512 x)
{
    const __m512 half      = _mm512_set1_ps(0.5f);
    const __m512 one       = _mm512_set1_ps(1.0f);
    const __m512 inv_sqrt2 = _mm512_set1_ps(0.70710678118654752440f);

    __m512 e = Sleef_erff16_u10(_mm512_mul_ps(x, inv_sqrt2)); /* SLEEF erf, 1 ULP */
    return _mm512_mul_ps(_mm512_mul_ps(half, x), _mm512_add_ps(one, e));
}

/*
 * GELU over an array of any length. Full 16-wide vectors are handled directly;
 * the trailing < 16 elements use a load/store mask so we never touch memory
 * past the end (no scalar tail loop needed).
 */
void gelu_avx512_array(const float *in, float *out, size_t n)
{
    size_t i = 0;
    for (; i + 16 <= n; i += 16) {
        __m512 x = _mm512_loadu_ps(in + i);
        _mm512_storeu_ps(out + i, gelu512_ps(x));
    }

    size_t rem = n - i;
    if (rem) {
        __mmask16 m = (__mmask16)((1u << rem) - 1u);
        __m512 x = _mm512_maskz_loadu_ps(m, in + i);
        _mm512_mask_storeu_ps(out + i, m, gelu512_ps(x));
    }
}
