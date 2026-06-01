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
    llvm.func @matmul_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: !llvm.ptr, %arg17: !llvm.ptr, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64, %arg23: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 1, 1, 1>, gpu.known_grid_size = array<i32: 4, 16, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 1, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg16, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg17, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.insertvalue %arg18, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %4 = llvm.insertvalue %arg19, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.insertvalue %arg21, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %6 = llvm.insertvalue %arg20, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.insertvalue %arg22, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %9 = llvm.insertvalue %arg9, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %10 = llvm.insertvalue %arg10, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %11 = llvm.insertvalue %arg11, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %12 = llvm.insertvalue %arg12, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %13 = llvm.insertvalue %arg14, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %14 = llvm.insertvalue %arg13, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %15 = llvm.insertvalue %arg15, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %16 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %17 = llvm.insertvalue %arg2, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.insertvalue %arg3, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %19 = llvm.insertvalue %arg4, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %20 = llvm.insertvalue %arg5, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %21 = llvm.insertvalue %arg7, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %22 = llvm.insertvalue %arg6, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %23 = llvm.insertvalue %arg8, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %24 = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 4> : i32
      %25 = llvm.sext %24 : i32 to i64
      %26 = nvvm.read.ptx.sreg.ctaid.y range <i32, 0, 16> : i32
      %27 = llvm.sext %26 : i32 to i64
      %28 = llvm.mul %25, %arg0 overflow<nsw> : i64
      %29 = llvm.add %28, %arg1 : i64
      %30 = llvm.mul %27, %arg0 overflow<nsw> : i64
      %31 = llvm.add %30, %arg1 : i64
      llvm.br ^bb1(%arg1 : i64)
    ^bb1(%32: i64):  // 2 preds: ^bb0, ^bb2
      %33 = llvm.icmp "slt" %32, %arg23 : i64
      llvm.cond_br %33, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %34 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %35 = llvm.mlir.constant(8 : index) : i64
      %36 = llvm.mul %29, %35 overflow<nsw, nuw> : i64
      %37 = llvm.add %36, %32 overflow<nsw, nuw> : i64
      %38 = llvm.getelementptr inbounds|nuw %34[%37] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %39 = llvm.load %38 : !llvm.ptr -> f32
      %40 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %41 = llvm.mlir.constant(16 : index) : i64
      %42 = llvm.mul %32, %41 overflow<nsw, nuw> : i64
      %43 = llvm.add %42, %31 overflow<nsw, nuw> : i64
      %44 = llvm.getelementptr inbounds|nuw %40[%43] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %45 = llvm.load %44 : !llvm.ptr -> f32
      %46 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %47 = llvm.mlir.constant(16 : index) : i64
      %48 = llvm.mul %29, %47 overflow<nsw, nuw> : i64
      %49 = llvm.add %48, %31 overflow<nsw, nuw> : i64
      %50 = llvm.getelementptr inbounds|nuw %46[%49] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %51 = llvm.load %50 : !llvm.ptr -> f32
      %52 = llvm.fmul %39, %45 : f32
      %53 = llvm.fadd %51, %52 : f32
      %54 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %55 = llvm.mlir.constant(16 : index) : i64
      %56 = llvm.mul %29, %55 overflow<nsw, nuw> : i64
      %57 = llvm.add %56, %31 overflow<nsw, nuw> : i64
      %58 = llvm.getelementptr inbounds|nuw %54[%57] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %53, %58 : f32, !llvm.ptr
      %59 = llvm.add %32, %arg0 : i64
      llvm.br ^bb1(%59 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
}

