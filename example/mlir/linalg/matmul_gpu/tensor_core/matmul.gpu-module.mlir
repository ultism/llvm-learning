#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
module attributes {gpu.container_module} {
  func.func @matmul(%arg0: memref<16x16xf16>, %arg1: memref<16x16xf16>, %arg2: memref<16x16xf16>) {
    %0 = ub.poison : f16
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c32 = arith.constant 32 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c1, %c1, %c1) threads in (%c32, %c1, %c1)  args(%arg0 : memref<16x16xf16>, %c0 : index, %0 : f16, %arg1 : memref<16x16xf16>, %arg2 : memref<16x16xf16>)
    return
  }
  gpu.module @matmul_kernel {
    gpu.func @matmul_kernel(%arg0: memref<16x16xf16>, %arg1: index, %arg2: f16, %arg3: memref<16x16xf16>, %arg4: memref<16x16xf16>) kernel attributes {known_block_size = array<i32: 32, 1, 1>, known_grid_size = array<i32: 1, 1, 1>} {
      %block_id_x = gpu.block_id x
      %block_id_y = gpu.block_id y
      %block_id_z = gpu.block_id z
      %thread_id_x = gpu.thread_id x
      %thread_id_y = gpu.thread_id y
      %thread_id_z = gpu.thread_id z
      %grid_dim_x = gpu.grid_dim x
      %grid_dim_y = gpu.grid_dim y
      %grid_dim_z = gpu.grid_dim z
      %block_dim_x = gpu.block_dim x
      %block_dim_y = gpu.block_dim y
      %block_dim_z = gpu.block_dim z
      %0 = gpu.subgroup_mma_load_matrix %arg0[%arg1, %arg1] {leadDimension = 16 : index} : memref<16x16xf16> -> !gpu.mma_matrix<16x16xf16, "AOp">
      %1 = vector.transfer_read %arg0[%arg1, %arg1], %arg2 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %2 = gpu.subgroup_mma_load_matrix %arg3[%arg1, %arg1] {leadDimension = 16 : index} : memref<16x16xf16> -> !gpu.mma_matrix<16x16xf16, "BOp">
      %3 = vector.transfer_read %arg3[%arg1, %arg1], %arg2 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %4 = gpu.subgroup_mma_load_matrix %arg4[%arg1, %arg1] {leadDimension = 16 : index} : memref<16x16xf16> -> !gpu.mma_matrix<16x16xf16, "COp">
      %5 = vector.transfer_read %arg4[%arg1, %arg1], %arg2 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %6 = gpu.subgroup_mma_compute %0, %2, %4 : !gpu.mma_matrix<16x16xf16, "AOp">, !gpu.mma_matrix<16x16xf16, "BOp"> -> !gpu.mma_matrix<16x16xf16, "COp">
      %7 = vector.contract {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %1, %3, %5 : vector<16x16xf16>, vector<16x16xf16> into vector<16x16xf16>
      gpu.subgroup_mma_store_matrix %6, %arg4[%arg1, %arg1] {leadDimension = 16 : index} : !gpu.mma_matrix<16x16xf16, "COp">, memref<16x16xf16>
      gpu.return
    }
  }
}

