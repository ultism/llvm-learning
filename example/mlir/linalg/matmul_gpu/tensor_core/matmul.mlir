// linalg.matmul 走 tensor core（WMMA）——和 cuda_core 同一个 op，但前提完全不同：
//
//   1) 数据类型必须是 tensor core 吃的 f16（cuda_core 是 f32 标量）；
//   2) 形状必须凑成 WMMA tile：这里 16x16x16（cuda_core 是随意的 4x8x16）；
//   3) 必须 warp 级协作：把计算包进 gpu.launch（1 个 block、32 线程 = 1 个 warp），
//      转换成 gpu.subgroup_mma 后 launch 体里只剩 warp 级算子，语义才对；
//   4) 直接在 memref 上做（不像 cuda_core 从 tensor 起步再 bufferize）。
//
// 这个文件只放「干净的 payload」；怎么把它向量化成 vector.contract 的调度在 schedule.mlir，
// 用 --transform-preload-library 外挂进来跑（这样本文件和各中间产物都不带 transform 噪声）。
func.func @matmul(%A: memref<16x16xf16>, %B: memref<16x16xf16>, %C: memref<16x16xf16>) {
  %c1  = arith.constant 1  : index
  %c32 = arith.constant 32 : index
  // 1 个 block、32 线程（= 1 个 warp）协作算这一整块 16x16 的 C
  gpu.launch blocks(%bx, %by, %bz) in (%gx = %c1, %gy = %c1, %gz = %c1)
             threads(%tx, %ty, %tz) in (%blx = %c32, %bly = %c1, %blz = %c1) {
    linalg.matmul ins(%A, %B : memref<16x16xf16>, memref<16x16xf16>)
                  outs(%C : memref<16x16xf16>)
    gpu.terminator
  }
  return
}
