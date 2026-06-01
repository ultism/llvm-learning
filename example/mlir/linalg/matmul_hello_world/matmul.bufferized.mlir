module {
  func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>, %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
    linalg.matmul ins(%arg0, %arg1 : memref<4x8xf32>, memref<8x16xf32>) outs(%arg2 : memref<4x16xf32>)
    return %arg2 : memref<4x16xf32>
  }
}

