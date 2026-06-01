module attributes {gpu.container_module} {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    %c1_0 = arith.constant 1 : index
    %c4_1 = arith.constant 4 : index
    %c16_2 = arith.constant 16 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c4_1, %c16_2, %c1_0) threads in (%c1_0, %c1_0, %c1_0)  args(%c1 : index, %c0 : index, %arg0 : memref<4x8xf32>, %arg1 : memref<8x16xf32>, %arg2 : memref<4x16xf32>, %c8 : index)
    return %arg2 : memref<4x16xf32>
  }
  gpu.module @matmul_kernel {
    gpu.func @matmul_kernel(%arg0: index, %arg1: index, %arg2: memref<4x8xf32>, %arg3: memref<8x16xf32>, %arg4: memref<4x16xf32>, %arg5: index) kernel attributes {known_block_size = array<i32: 1, 1, 1>, known_grid_size = array<i32: 4, 16, 1>} {
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
      %0 = arith.muli %block_id_x, %arg0 overflow<nsw> : index
      %1 = arith.addi %0, %arg1 : index
      %2 = arith.muli %block_id_y, %arg0 overflow<nsw> : index
      %3 = arith.addi %2, %arg1 : index
      scf.for %arg6 = %arg1 to %arg5 step %arg0 {
        %4 = memref.load %arg2[%1, %arg6] : memref<4x8xf32>
        %5 = memref.load %arg3[%arg6, %3] : memref<8x16xf32>
        %6 = memref.load %arg4[%1, %3] : memref<4x16xf32>
        %7 = arith.mulf %4, %5 : f32
        %8 = arith.addf %6, %7 : f32
        memref.store %8, %arg4[%1, %3] : memref<4x16xf32>
      }
      gpu.return
    }
  }
}

