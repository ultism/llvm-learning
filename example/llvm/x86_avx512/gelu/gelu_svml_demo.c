/*
 * GELU via Intel SVML's vectorised erf (_mm512_erf_ps).
 *
 * SVML's erf has no native instruction and isn't in clang's -fveclib=SVML
 * auto-vectorisation table, but Intel's icx exposes the _mm512_erf_ps
 * intrinsic directly (it lowers to a __svml_erff16 call in libsvml). SVML is
 * just AVX-512 code, so this runs fine on AMD Zen as well as Intel.
 *
 * Build (Intel oneAPI):
 *   source /opt/intel/oneapi/setvars.sh
 *   icx -O3 -xHost gelu_svml_demo.c -lm -o gelu_svml_demo   # libsvml auto-linked
 */
#include <immintrin.h>
#include <stdio.h>
#include <math.h>
#include <stddef.h>

/* GELU(x) = 0.5 * x * (1 + erf(x / sqrt(2)))  over 16 floats. */
static inline __m512 gelu512_svml(__m512 x)
{
    const __m512 half      = _mm512_set1_ps(0.5f);
    const __m512 one       = _mm512_set1_ps(1.0f);
    const __m512 inv_sqrt2 = _mm512_set1_ps(0.70710678118654752440f);

    __m512 e = _mm512_erf_ps(_mm512_mul_ps(x, inv_sqrt2)); /* Intel SVML erf */
    return _mm512_mul_ps(_mm512_mul_ps(half, x), _mm512_add_ps(one, e));
}

void gelu_svml_array(const float *in, float *out, size_t n)
{
    size_t i = 0;
    for (; i + 16 <= n; i += 16)
        _mm512_storeu_ps(out + i, gelu512_svml(_mm512_loadu_ps(in + i)));

    size_t rem = n - i;
    if (rem) {
        __mmask16 m = (__mmask16)((1u << rem) - 1u);
        _mm512_mask_storeu_ps(out + i, m, gelu512_svml(_mm512_maskz_loadu_ps(m, in + i)));
    }
}

int main(void)
{
    enum { N = 20 };
    float in[N], got[N];
    for (int i = 0; i < N; ++i) in[i] = -4.0f + 0.42f * (float)i;

    gelu_svml_array(in, got, N);

    double maxerr = 0;
    for (int i = 0; i < N; ++i) {
        double ref = 0.5 * in[i] * (1.0 + erf((double)in[i] * 0.70710678118654752440));
        double e = fabs(ref - got[i]);
        if (e > maxerr) maxerr = e;
    }
    printf("SVML _mm512_erf_ps GELU vs libm:  max abs err = %.3e\n", maxerr);
    printf("sample  GELU(%.2f) = %.6f\n", in[14], got[14]);
    return 0;
}
