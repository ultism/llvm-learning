#map = affine_map<(d0, d1, d2) -> (d0, d2)>
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>
module {
  func.func @matmul(%arg0: memref<16x16xf16>, %arg1: memref<16x16xf16>, %arg2: memref<16x16xf16>) {
    %0 = ub.poison : f16
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c32 = arith.constant 32 : index
    gpu.launch blocks(%arg3, %arg4, %arg5) in (%arg9 = %c1, %arg10 = %c1, %arg11 = %c1) threads(%arg6, %arg7, %arg8) in (%arg12 = %c32, %arg13 = %c1, %arg14 = %c1) {
      %1 = vector.transfer_read %arg0[%c0, %c0], %0 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %2 = vector.transfer_read %arg1[%c0, %c0], %0 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %3 = vector.transfer_read %arg2[%c0, %c0], %0 {in_bounds = [true, true]} : memref<16x16xf16>, vector<16x16xf16>
      %4 = vector.contract {indexing_maps = [#map, #map1, #map2], iterator_types = ["parallel", "parallel", "reduction"], kind = #vector.kind<add>} %1, %2, %3 : vector<16x16xf16>, vector<16x16xf16> into vector<16x16xf16>
      vector.transfer_write %4, %arg2[%c0, %c0] {in_bounds = [true, true]} : vector<16x16xf16>, memref<16x16xf16>
      gpu.terminator
    }
    return
  }
}

