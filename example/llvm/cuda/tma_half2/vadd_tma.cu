// vadd_tma.cu —— 用 TMA 把数据搬进 shared，再做 half2（fp16×2 打包）向量加。
//
// 两个新东西，全程只看本机 sm_120（RTX 5060 Ti，消费级 Blackwell）：
//
//   ① TMA（Tensor Memory Accelerator）做「读」：
//      一条硬件指令把一整块 global 异步搬进 shared，由**单个线程**发射（SASS 里的 ELECT），
//      完成与否用 mbarrier 跟踪。本机 sm_120 有 TMA 但**没有 multicast**——所以这里的
//      cp.async.bulk 是 unicast（PTX/IR 注释里就写着 `// 1a. unicast`）。
//      注意：TMA 是高度按代分化的特性（Hopper/Blackwell-DC/Blackwell-消费 各不同），
//      本例不做跨代对比，只认 sm_120。
//
//   ② half2（__half2 = 打包的 2 个 fp16）做「加」：
//      一条 HADD2 同时算两个 half。对照上个 vector_add 例子里**标量** fp16 的
//      `HADD2 R5, R2.H0_H0, R5.H0_H0`（只用低半道、另一道浪费）——这里是
//      `HADD2 R9, R6, R7`（两道全用），这才是 fp16 吞吐红利的兑现方式。
//
// 写回（c）用普通 STG —— 只有「读」用 TMA（按要求）。
//
// 三层产物（make ir/ptx/sass）都用 cuda::ptx 的薄封装产生：每个 TMA/mbarrier 操作
// 在 IR/PTX 里都是一条带 `// 序号` 注释的内联 asm，对着 PTX ISA 文档读最直观。

#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cuda_fp16.h>
#include <cuda/ptx>

namespace ptx = cuda::ptx;

constexpr int TILE = 256;                     // 每个 block 处理 256 个 half2 = 512 个 half

__global__ void vadd_h2_tma(const __half2* a, const __half2* b, __half2* c, int n_h2) {
    __shared__ alignas(16) __half2 sa[TILE];
    __shared__ alignas(16) __half2 sb[TILE];
    __shared__ alignas(8)  uint64_t bar;      // 裸 mbarrier：无构造函数，clang 也能编（出 .ll）

    int tile0 = blockIdx.x * TILE;            // 本 block 负责的 half2 起点
    constexpr int BYTES = TILE * sizeof(__half2);   // 每个数组一片 = 1024 B

    // --- 初始化 mbarrier，并让 async proxy 看见这次初始化 ---
    if (threadIdx.x == 0) {
        ptx::mbarrier_init(&bar, 1);                       // mbarrier.init.shared.b64
        ptx::fence_proxy_async(ptx::space_shared);         // fence.proxy.async.shared::cta
    }
    __syncthreads();

    // --- leader 线程：声明期望字节数，发起两次 TMA 读（global → shared）---
    if (threadIdx.x == 0) {
        ptx::mbarrier_arrive_expect_tx(ptx::sem_release, ptx::scope_cta,
                                       ptx::space_shared, &bar, 2 * BYTES);
        ptx::cp_async_bulk(ptx::space_cluster, ptx::space_global, sa, a + tile0, BYTES, &bar);
        ptx::cp_async_bulk(ptx::space_cluster, ptx::space_global, sb, b + tile0, BYTES, &bar);
    }

    // --- 所有线程自旋等这一相（phase 0）完成：到达数满足且期望字节全部落地 ---
    while (!ptx::mbarrier_try_wait_parity(&bar, 0)) {}
    __syncthreads();

    // --- shared 已就绪：打包 half2 逐元素加，普通 store 写回 ---
    for (int i = threadIdx.x; i < TILE && tile0 + i < n_h2; i += blockDim.x)
        c[tile0 + i] = __hadd2(sa[i], sb[i]);             // 一条 HADD2 算两个 fp16
}

// ----------------------------------------------------------------------------
// host 驱动：仅用于 `make run` 验正确性（n_h2 取 TILE 整数倍，避免尾块）。
// ----------------------------------------------------------------------------
int main() {
    const int n_h2    = TILE * 64;            // 16384 个 half2 = 32768 个 half
    const int threads = TILE;
    const int blocks  = n_h2 / TILE;

    size_t bytes = (size_t)n_h2 * sizeof(__half2);
    __half2 *ha = (__half2*)malloc(bytes), *hb = (__half2*)malloc(bytes), *hc = (__half2*)malloc(bytes);
    for (int i = 0; i < n_h2; i++) {                       // {1,1} + {2,2} = {3,3}
        ha[i] = __floats2half2_rn(1.0f, 1.0f);
        hb[i] = __floats2half2_rn(2.0f, 2.0f);
    }

    __half2 *da, *db, *dc;
    cudaMalloc(&da, bytes); cudaMalloc(&db, bytes); cudaMalloc(&dc, bytes);
    cudaMemcpy(da, ha, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy(db, hb, bytes, cudaMemcpyHostToDevice);

    vadd_h2_tma<<<blocks, threads>>>(da, db, dc, n_h2);
    cudaError_t e = cudaGetLastError();
    if (e) { printf("launch error: %s\n", cudaGetErrorString(e)); return 1; }
    cudaDeviceSynchronize();
    cudaMemcpy(hc, dc, bytes, cudaMemcpyDeviceToHost);

    int bad = 0;
    for (int i = 0; i < n_h2; i++) {
        float2 v = __half22float2(hc[i]);
        if (v.x != 3.0f || v.y != 3.0f) bad++;
    }
    float2 v0 = __half22float2(hc[0]);
    printf("h2+TMA (sm120): %-4s  c[0]={%.1f,%.1f}  mismatches=%d\n",
           bad ? "FAIL" : "OK", v0.x, v0.y, bad);

    cudaFree(da); cudaFree(db); cudaFree(dc); free(ha); free(hb); free(hc);
    return 0;
}
