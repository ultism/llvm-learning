module {
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
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %0, %arg10 = %c1_2, %arg11 = %c1_2) threads(%arg6, %arg7, %arg8) in (%arg12 = %1, %arg13 = %c1_2, %arg14 = %c1_2) {
      %2 = arith.addi %c0, %arg3 : index
      %3 = arith.addi %c0_0, %arg6 : index
      affine.for %arg15 = 0 to 8 {
        %4 = affine.load %arg0[%2, %arg15] : memref<4x8xf32>
        %5 = affine.load %arg1[%arg15, %3] : memref<8x16xf32>
        %6 = affine.load %arg2[%2, %3] : memref<4x16xf32>
        %7 = arith.mulf %4, %5 : f32
        %8 = arith.addf %6, %7 : f32
        affine.store %8, %arg2[%2, %3] : memref<4x16xf32>
      }
      gpu.terminator
    }
    return %arg2 : memref<4x16xf32>
  }
}

