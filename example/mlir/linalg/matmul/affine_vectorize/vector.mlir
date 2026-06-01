#map = affine_map<(d0, d1) -> (0)>
module {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    affine.for %arg3 = 0 to 4 {
      affine.for %arg4 = 0 to 16 step 8 {
        affine.for %arg5 = 0 to 8 {
          %0 = ub.poison : f32
          %1 = vector.transfer_read %arg0[%arg3, %arg5], %0 {permutation_map = #map} : memref<4x8xf32>, vector<8xf32>
          %2 = ub.poison : f32
          %3 = vector.transfer_read %arg1[%arg5, %arg4], %2 : memref<8x16xf32>, vector<8xf32>
          %4 = ub.poison : f32
          %5 = vector.transfer_read %arg2[%arg3, %arg4], %4 : memref<4x16xf32>, vector<8xf32>
          %6 = arith.mulf %1, %3 : vector<8xf32>
          %7 = arith.addf %5, %6 : vector<8xf32>
          vector.transfer_write %7, %arg2[%arg3, %arg4] : vector<8xf32>, memref<4x16xf32>
        }
      }
    }
    return %arg2 : memref<4x16xf32>
  }
}

