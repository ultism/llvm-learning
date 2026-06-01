module attributes {gpu.container_module} {
  func.func @matmul(%arg0: memref<16x16xf16>, %arg1: memref<16x16xf16>, %arg2: memref<16x16xf16>) {
    %0 = ub.poison : f16
    %c0 = arith.constant 0 : index
    %c1 = arith.constant 1 : index
    %c32 = arith.constant 32 : index
    gpu.launch_func  @matmul_kernel::@matmul_kernel blocks in (%c1, %c1, %c1) threads in (%c32, %c1, %c1)  args(%arg0 : memref<16x16xf16>, %c0 : index, %0 : f16, %arg1 : memref<16x16xf16>, %arg2 : memref<16x16xf16>)
    return
  }
  gpu.module @matmul_kernel {
    llvm.func @matmul_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: i64, %arg8: f16, %arg9: !llvm.ptr, %arg10: !llvm.ptr, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: i64, %arg15: i64, %arg16: !llvm.ptr, %arg17: !llvm.ptr, %arg18: i64, %arg19: i64, %arg20: i64, %arg21: i64, %arg22: i64) attributes {gpu.kernel, gpu.known_block_size = array<i32: 32, 1, 1>, gpu.known_grid_size = array<i32: 1, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 32, 1, 1>} {
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
      %17 = llvm.insertvalue %arg0, %16[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.insertvalue %arg1, %17[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %19 = llvm.insertvalue %arg2, %18[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %20 = llvm.insertvalue %arg3, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %21 = llvm.insertvalue %arg5, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %22 = llvm.insertvalue %arg4, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %23 = llvm.insertvalue %arg6, %22[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %24 = llvm.extractvalue %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %25 = llvm.mlir.constant(16 : index) : i64
      %26 = llvm.mul %arg7, %25 : i64
      %27 = llvm.add %26, %arg7 : i64
      %28 = llvm.getelementptr %24[%27] : (!llvm.ptr, i64) -> !llvm.ptr, f16
      %29 = llvm.mlir.constant(16 : index) : i32
      %30 = nvvm.wmma.load %28, %29 {eltype = #nvvm.mma_type<f16>, frag = #nvvm.mma_frag<a>, k = 16 : i32, layout = #nvvm.mma_layout<row>, m = 16 : i32, n = 16 : i32} : (!llvm.ptr) -> !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)>
      %31 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %32 = llvm.mlir.constant(16 : index) : i64
      %33 = llvm.mul %arg7, %32 : i64
      %34 = llvm.add %33, %arg7 : i64
      %35 = llvm.getelementptr %31[%34] : (!llvm.ptr, i64) -> !llvm.ptr, f16
      %36 = llvm.mlir.constant(16 : index) : i32
      %37 = nvvm.wmma.load %35, %36 {eltype = #nvvm.mma_type<f16>, frag = #nvvm.mma_frag<b>, k = 16 : i32, layout = #nvvm.mma_layout<row>, m = 16 : i32, n = 16 : i32} : (!llvm.ptr) -> !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)>
      %38 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %39 = llvm.mlir.constant(16 : index) : i64
      %40 = llvm.mul %arg7, %39 : i64
      %41 = llvm.add %40, %arg7 : i64
      %42 = llvm.getelementptr %38[%41] : (!llvm.ptr, i64) -> !llvm.ptr, f16
      %43 = llvm.mlir.constant(16 : index) : i32
      %44 = nvvm.wmma.load %42, %43 {eltype = #nvvm.mma_type<f16>, frag = #nvvm.mma_frag<c>, k = 16 : i32, layout = #nvvm.mma_layout<row>, m = 16 : i32, n = 16 : i32} : (!llvm.ptr) -> !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)>
      %45 = llvm.extractvalue %30[0] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %46 = llvm.extractvalue %30[1] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %47 = llvm.extractvalue %30[2] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %48 = llvm.extractvalue %30[3] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %49 = llvm.extractvalue %30[4] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %50 = llvm.extractvalue %30[5] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %51 = llvm.extractvalue %30[6] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %52 = llvm.extractvalue %30[7] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %53 = llvm.extractvalue %37[0] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %54 = llvm.extractvalue %37[1] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %55 = llvm.extractvalue %37[2] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %56 = llvm.extractvalue %37[3] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %57 = llvm.extractvalue %37[4] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %58 = llvm.extractvalue %37[5] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %59 = llvm.extractvalue %37[6] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %60 = llvm.extractvalue %37[7] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %61 = llvm.extractvalue %44[0] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %62 = llvm.extractvalue %44[1] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %63 = llvm.extractvalue %44[2] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %64 = llvm.extractvalue %44[3] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %65 = nvvm.wmma.mma %45, %46, %47, %48, %49, %50, %51, %52, %53, %54, %55, %56, %57, %58, %59, %60, %61, %62, %63, %64 {eltypeA = #nvvm.mma_type<f16>, eltypeB = #nvvm.mma_type<f16>, k = 16 : i32, layoutA = #nvvm.mma_layout<row>, layoutB = #nvvm.mma_layout<row>, m = 16 : i32, n = 16 : i32} : (vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>) -> !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)>
      %66 = llvm.extractvalue %65[0] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %67 = llvm.extractvalue %65[1] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %68 = llvm.extractvalue %65[2] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %69 = llvm.extractvalue %65[3] : !llvm.struct<(vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>)> 
      %70 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %71 = llvm.mlir.constant(16 : index) : i64
      %72 = llvm.mul %arg7, %71 : i64
      %73 = llvm.add %72, %arg7 : i64
      %74 = llvm.getelementptr %70[%73] : (!llvm.ptr, i64) -> !llvm.ptr, f16
      %75 = llvm.mlir.constant(16 : index) : i32
      nvvm.wmma.store %74, %75, %66, %67, %68, %69 {eltype = #nvvm.mma_type<f16>, k = 16 : i32, layout = #nvvm.mma_layout<row>, m = 16 : i32, n = 16 : i32} : !llvm.ptr, vector<2xf16>, vector<2xf16>, vector<2xf16>, vector<2xf16>
      llvm.return
    }
  }
}

