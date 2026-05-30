#include <stddef.h>

/* C[M*N] = A[M*K] * B[K*N], 全部 row-major。 */

/* ijk:内层 k。B[k*N+j] 随 k 跨步 N → 期望 gather(向量 GEP) */
void gemm_ijk(const float *A, const float *B, float *C,
              size_t M, size_t K, size_t N)
{
    for (size_t i = 0; i < M; i++)
        for (size_t j = 0; j < N; j++) {
            float acc = 0.0f;
            for (size_t k = 0; k < K; k++)
                acc += A[i*K + k] * B[k*N + j];
            C[i*N + j] = acc;
        }
}

/* ikj:内层 j。B[k*N+j] 随 j 连续;A[i*K+k] 在 j 内不变 → 期望 broadcast,无 gather */
void gemm_ikj(const float *A, const float *B, float *C,
              size_t M, size_t K, size_t N)
{
    for (size_t i = 0; i < M; i++) {
        for (size_t j = 0; j < N; j++) C[i*N + j] = 0.0f;
        for (size_t k = 0; k < K; k++) {
            float a = A[i*K + k];
            for (size_t j = 0; j < N; j++)
                C[i*N + j] += a * B[k*N + j];
        }
    }
}
