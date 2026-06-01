#map = affine_map<(d0)[s0, s1] -> ((d0 - s0) ceildiv s1)>
#map1 = affine_map<(d0)[s0, s1] -> (d0 * s0 + s1)>
module {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    %c1_0 = arith.constant 1 : index
    %0 = affine.apply #map(%c4)[%c0, %c1]
    %1 = affine.apply #map(%c16)[%c0, %c1]
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %0, %arg10 = %1, %arg11 = %c1_0) threads(%arg6, %arg7, %arg8) in (%arg12 = %c1_0, %arg13 = %c1_0, %arg14 = %c1_0) {
      %2 = affine.apply #map1(%arg3)[%c1, %c0]
      %3 = affine.apply #map1(%arg4)[%c1, %c0]
      scf.for %arg15 = %c0 to %c8 step %c1 {
        %4 = memref.load %arg0[%2, %arg15] : memref<4x8xf32>
        %5 = memref.load %arg1[%arg15, %3] : memref<8x16xf32>
        %6 = memref.load %arg2[%2, %3] : memref<4x16xf32>
        %7 = arith.mulf %4, %5 : f32
        %8 = arith.addf %6, %7 : f32
        memref.store %8, %arg2[%2, %3] : memref<4x16xf32>
      }
      gpu.terminator
    } {SCFToGPU_visited}
    return %arg2 : memref<4x16xf32>
  }
}

