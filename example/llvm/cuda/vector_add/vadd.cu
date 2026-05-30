// vadd.cu —— 最简单的逐元素向量加：一个线程算一个元素（"一个 CUDA core 加一次"）。
//
// 目的：用最干净的核（无归约、无分支、无后处理），对照 fp32 / fp16 / bf16 三种类型
// 在三层中间产物里到底差在哪：
//     clang LLVM IR (.ll)  →  nvcc PTX (.ptx)  →  真卡 SASS (.sass, sm_120)
//
// 看点（全部本机实测，推导见 README）：
//   · fp32 的 '+' 一路都是「原生」：fadd  →  add.f32  →  FADD
//   · fp16 的 '+' 不是编译器原生指令，而是 cuda_fp16.h 头文件里写死的内联 PTX 汇编：
//       IR  : tail call i16 asm "{add.f16 $0,$1,$2;}"   （half 全程当 i16 搬）
//       PTX : {add.f16 %rs1,%rs2,%rs3;}                  （逐字照搬那段 asm）
//       SASS: HADD2 R5, R2.H0_H0, R5.H0_H0              （只加一个 half，却跑在 half2 单元的低半道）
//   · bf16 的 '+' 同样是 cuda_bf16.h 的内联 asm，而且**连选哪段 asm 都看 __CUDA_ARCH__**：
//       sm_90+ : {add.bf16 …}   ；sm_80 : 用 fma.rn.bf16(a,1.0,b) 凑 ；sm_75-: 转 fp32 软件模拟
//       SASS(sm_120): HADD2.BF16_V2 …   （与 fp16 共用 half2 单元，靠指令修饰符区分类型）

#include <cstdio>
#include <cstdlib>
#include <cuda_fp16.h>
#include <cuda_bf16.h>

// ---- fp32：c[i] = a[i] + b[i] ----
__global__ void vadd_f32(const float* a, const float* b, float* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;   // ctaid.x*ntid.x + tid.x → 全局线程号
    if (i < n)                                        // grid 向上取整，末块有多余线程，越界保护
        c[i] = a[i] + b[i];
}

// ---- fp16：完全相同的逻辑，类型换成 __half ----
__global__ void vadd_f16(const __half* a, const __half* b, __half* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
        c[i] = a[i] + b[i];                           // __half 的 operator+ → 内联 PTX {add.f16}
}

// ---- bf16：再换成 __nv_bfloat16（同 16-bit，但 8 位指数 / 7 位尾数，等于截断的 fp32）----
__global__ void vadd_bf16(const __nv_bfloat16* a, const __nv_bfloat16* b, __nv_bfloat16* c, int n) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < n)
        c[i] = a[i] + b[i];                           // operator+ → 内联 PTX {add.bf16}（sm_90+）
}

// ----------------------------------------------------------------------------
// 下面是 host 驱动：把数据塞上卡、跑核、拷回来验。
// （出 IR/PTX/SASS 只看上面两个 __global__；host 部分仅用于 `make run` 验正确性。）
// ----------------------------------------------------------------------------

#define CUDA_CHECK(call) do {                                                   \
    cudaError_t _e = (call);                                                    \
    if (_e != cudaSuccess) {                                                    \
        fprintf(stderr, "CUDA error %s:%d: %s\n", __FILE__, __LINE__,          \
                cudaGetErrorString(_e));                                        \
        exit(1);                                                                \
    }                                                                          \
} while (0)

int main() {
    const int n       = 1 << 20;                 // 1M 元素
    const int threads = 256;
    const int blocks  = (n + threads - 1) / threads;

    // ---------------- fp32 ----------------
    {
        size_t bytes = (size_t)n * sizeof(float);
        float *ha = (float*)malloc(bytes), *hb = (float*)malloc(bytes), *hc = (float*)malloc(bytes);
        for (int i = 0; i < n; i++) { ha[i] = 1.0f; hb[i] = 2.0f; }   // 1 + 2 = 3

        float *da, *db, *dc;
        CUDA_CHECK(cudaMalloc(&da, bytes));
        CUDA_CHECK(cudaMalloc(&db, bytes));
        CUDA_CHECK(cudaMalloc(&dc, bytes));
        CUDA_CHECK(cudaMemcpy(da, ha, bytes, cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(db, hb, bytes, cudaMemcpyHostToDevice));

        vadd_f32<<<blocks, threads>>>(da, db, dc, n);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaMemcpy(hc, dc, bytes, cudaMemcpyDeviceToHost));

        int bad = 0;
        for (int i = 0; i < n; i++) if (hc[i] != 3.0f) bad++;
        printf("fp32 vadd: %-4s  c[0]=%.1f  mismatches=%d\n", bad ? "FAIL" : "OK", hc[0], bad);

        cudaFree(da); cudaFree(db); cudaFree(dc); free(ha); free(hb); free(hc);
    }

    // ---------------- fp16 ----------------
    {
        size_t bytes = (size_t)n * sizeof(__half);
        __half *ha = (__half*)malloc(bytes), *hb = (__half*)malloc(bytes), *hc = (__half*)malloc(bytes);
        for (int i = 0; i < n; i++) { ha[i] = __float2half(1.0f); hb[i] = __float2half(2.0f); }

        __half *da, *db, *dc;
        CUDA_CHECK(cudaMalloc(&da, bytes));
        CUDA_CHECK(cudaMalloc(&db, bytes));
        CUDA_CHECK(cudaMalloc(&dc, bytes));
        CUDA_CHECK(cudaMemcpy(da, ha, bytes, cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(db, hb, bytes, cudaMemcpyHostToDevice));

        vadd_f16<<<blocks, threads>>>(da, db, dc, n);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaMemcpy(hc, dc, bytes, cudaMemcpyDeviceToHost));

        int bad = 0;
        for (int i = 0; i < n; i++) if (__half2float(hc[i]) != 3.0f) bad++;   // 3.0 在 fp16 里可精确表示
        printf("fp16 vadd: %-4s  c[0]=%.1f  mismatches=%d\n",
               bad ? "FAIL" : "OK", __half2float(hc[0]), bad);

        cudaFree(da); cudaFree(db); cudaFree(dc); free(ha); free(hb); free(hc);
    }

    // ---------------- bf16 ----------------
    {
        size_t bytes = (size_t)n * sizeof(__nv_bfloat16);
        __nv_bfloat16 *ha = (__nv_bfloat16*)malloc(bytes), *hb = (__nv_bfloat16*)malloc(bytes),
                      *hc = (__nv_bfloat16*)malloc(bytes);
        for (int i = 0; i < n; i++) { ha[i] = __float2bfloat16(1.0f); hb[i] = __float2bfloat16(2.0f); }

        __nv_bfloat16 *da, *db, *dc;
        CUDA_CHECK(cudaMalloc(&da, bytes));
        CUDA_CHECK(cudaMalloc(&db, bytes));
        CUDA_CHECK(cudaMalloc(&dc, bytes));
        CUDA_CHECK(cudaMemcpy(da, ha, bytes, cudaMemcpyHostToDevice));
        CUDA_CHECK(cudaMemcpy(db, hb, bytes, cudaMemcpyHostToDevice));

        vadd_bf16<<<blocks, threads>>>(da, db, dc, n);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaMemcpy(hc, dc, bytes, cudaMemcpyDeviceToHost));

        int bad = 0;
        for (int i = 0; i < n; i++) if (__bfloat162float(hc[i]) != 3.0f) bad++;   // 3.0 在 bf16 里也可精确表示
        printf("bf16 vadd: %-4s  c[0]=%.1f  mismatches=%d\n",
               bad ? "FAIL" : "OK", __bfloat162float(hc[0]), bad);

        cudaFree(da); cudaFree(db); cudaFree(dc); free(ha); free(hb); free(hc);
    }

    return 0;
}
