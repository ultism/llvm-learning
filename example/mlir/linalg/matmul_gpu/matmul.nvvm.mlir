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
    llvm.func @matmul_kernel(%arg0: i64, %arg1: i64, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: i64, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: !llvm.ptr, %arg17: !llvm.ptr, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64) attributes {gpu.kernel, nvvm.kernel} {
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
      %24 = llvm.mlir.constant(1 : index) : i64
      %25 = llvm.mlir.constant(8 : index) : i64
      %26 = llvm.mlir.constant(0 : index) : i64
      %27 = nvvm.read.ptx.sreg.ctaid.x : i32
      %28 = llvm.sext %27 : i32 to i64
      %29 = nvvm.read.ptx.sreg.tid.x : i32
      %30 = llvm.sext %29 : i32 to i64
      %31 = llvm.add %arg0, %28 : i64
      %32 = llvm.add %arg1, %30 : i64
      llvm.br ^bb1(%26 : i64)
    ^bb1(%33: i64):  // 2 preds: ^bb0, ^bb2
      %34 = llvm.icmp "slt" %33, %25 : i64
      llvm.cond_br %34, ^bb2, ^bb3
    ^bb2:  // pred: ^bb1
      %35 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %36 = llvm.mlir.constant(8 : index) : i64
      %37 = llvm.mul %31, %36 overflow<nsw, nuw> : i64
      %38 = llvm.add %37, %33 overflow<nsw, nuw> : i64
      %39 = llvm.getelementptr inbounds|nuw %35[%38] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %40 = llvm.load %39 : !llvm.ptr -> f32
      %41 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %42 = llvm.mlir.constant(16 : index) : i64
      %43 = llvm.mul %33, %42 overflow<nsw, nuw> : i64
      %44 = llvm.add %43, %32 overflow<nsw, nuw> : i64
      %45 = llvm.getelementptr inbounds|nuw %41[%44] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %46 = llvm.load %45 : !llvm.ptr -> f32
      %47 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %48 = llvm.mlir.constant(16 : index) : i64
      %49 = llvm.mul %31, %48 overflow<nsw, nuw> : i64
      %50 = llvm.add %49, %32 overflow<nsw, nuw> : i64
      %51 = llvm.getelementptr inbounds|nuw %47[%50] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %52 = llvm.load %51 : !llvm.ptr -> f32
      %53 = llvm.fmul %40, %46 : f32
      %54 = llvm.fadd %52, %53 : f32
      %55 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %56 = llvm.mlir.constant(16 : index) : i64
      %57 = llvm.mul %31, %56 overflow<nsw, nuw> : i64
      %58 = llvm.add %57, %32 overflow<nsw, nuw> : i64
      %59 = llvm.getelementptr inbounds|nuw %55[%58] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %54, %59 : f32, !llvm.ptr
      %60 = llvm.add %33, %24 : i64
      llvm.br ^bb1(%60 : i64)
    ^bb3:  // pred: ^bb1
      llvm.return
    }
  }
}

