#ifndef GELU_H
#define GELU_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * GELU (Gaussian Error Linear Unit)
 *
 *   GELU(x) = x * Phi(x)
 *           = x * 0.5 * (1 + erf(x / sqrt(2)))
 *
 * where Phi is the CDF of the standard normal distribution and erf is the
 * Gauss error function. This header exposes two implementations of the *exact*
 * (erf-based, not tanh-approximated) GELU:
 *
 *   - a scalar reference built on libm's erff()
 *   - an AVX-512 version that vectorises a polynomial approximation of erf
 */

/* ---- Scalar reference (exact, uses libm erff) ------------------------- */
float gelu_scalar(float x);
void  gelu_scalar_array(const float *in, float *out, size_t n);

/* ---- AVX-512 (polynomial erf, 16 floats per iteration) ---------------- */
void  gelu_avx512_array(const float *in, float *out, size_t n);

#ifdef __cplusplus
}
#endif

#endif /* GELU_H */
