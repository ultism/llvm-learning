module attributes {gpu.container_module} {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %0 = arith.subi %c4, %c0 : index
    %c1 = arith.constant 1 : index
    %c0_0 = arith.constant 0 : index
    %c16 = arith.constant 16 : index
    %1 = arith.subi %c16, %c0_0 : index
    %c1_1 = arith.constant 1 : index
    %c1_2 = arith.constant 1 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%0, %c1_2, %c1_2) threads in (%1, %c1_2, %c1_2)  args(%c0 : index, %c0_0 : index, %arg0 : memref<4x8xf32>, %arg1 : memref<8x16xf32>, %arg2 : memref<4x16xf32>)
    return %arg2 : memref<4x16xf32>
  }
  gpu.module @matmul_kernel {
    gpu.func @matmul_kernel(%arg0: index, %arg1: index, %arg2: memref<4x8xf32>, %arg3: memref<8x16xf32>, %arg4: memref<4x16xf32>) kernel {
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
      %0 = arith.addi %arg0, %block_id_x : index
      %1 = arith.addi %arg1, %thread_id_x : index
      %c0 = arith.constant 0 : index
      %c8 = arith.constant 8 : index
      %c1 = arith.constant 1 : index
      scf.for %arg5 = %c0 to %c8 step %c1 {
        %2 = memref.load %arg2[%0, %arg5] : memref<4x8xf32>
        %3 = memref.load %arg3[%arg5, %1] : memref<8x16xf32>
        %4 = memref.load %arg4[%0, %1] : memref<4x16xf32>
        %5 = arith.mulf %2, %3 : f32
        %6 = arith.addf %4, %5 : f32
        memref.store %6, %arg4[%0, %1] : memref<4x16xf32>
      }
      gpu.return
    }
  }
}

