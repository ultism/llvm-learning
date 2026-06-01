module {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    affine.for %arg3 = 0 to 4 {
      affine.for %arg4 = 0 to 16 {
        affine.for %arg5 = 0 to 8 {
          %0 = affine.load %arg0[%arg3, %arg5] : memref<4x8xf32>
          %1 = affine.load %arg1[%arg5, %arg4] : memref<8x16xf32>
          %2 = affine.load %arg2[%arg3, %arg4] : memref<4x16xf32>
          %3 = arith.mulf %0, %1 : f32
          %4 = arith.addf %2, %3 : f32
          affine.store %4, %arg2[%arg3, %arg4] : memref<4x16xf32>
        }
      }
    }
    return %arg2 : memref<4x16xf32>
  }
}

