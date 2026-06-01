module {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    %c0 = arith.constant 0 : index
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c4, %c16) step (%c1, %c1) {
      scf.for %arg5 = %c0 to %c8 step %c1 {
        %0 = memref.load %arg0[%arg3, %arg5] : memref<4x8xf32>
        %1 = memref.load %arg1[%arg5, %arg4] : memref<8x16xf32>
        %2 = memref.load %arg2[%arg3, %arg4] : memref<4x16xf32>
        %3 = arith.mulf %0, %1 : f32
        %4 = arith.addf %2, %3 : f32
        memref.store %4, %arg2[%arg3, %arg4] : memref<4x16xf32>
      }
      scf.reduce 
    }
    return %arg2 : memref<4x16xf32>
  }
}

