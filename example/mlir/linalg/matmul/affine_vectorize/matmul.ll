; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13, ptr %14, ptr %15, i64 %16, i64 %17, i64 %18, i64 %19, i64 %20) {
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %7, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, ptr %8, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %9, 2
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %10, 3, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %12, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %11, 3, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %13, 4, 1
  %29 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %0, 0
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %29, ptr %1, 1
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, i64 %2, 2
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 %3, 3, 0
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, i64 %5, 4, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 %4, 3, 1
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 %6, 4, 1
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %14, 0
  %37 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, ptr %15, 1
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %37, i64 %16, 2
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, i64 %17, 3, 0
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, i64 %19, 4, 0
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 %18, 3, 1
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 %20, 4, 1
  br label %43

43:                                               ; preds = %100, %21
  %44 = phi i64 [ %101, %100 ], [ 0, %21 ]
  %45 = icmp slt i64 %44, 4
  br i1 %45, label %46, label %102

46:                                               ; preds = %43
  br label %47

47:                                               ; preds = %98, %46
  %48 = phi i64 [ %99, %98 ], [ 0, %46 ]
  %49 = icmp slt i64 %48, 16
  br i1 %49, label %50, label %100

50:                                               ; preds = %47
  br label %51

51:                                               ; preds = %54, %50
  %52 = phi i64 [ %97, %54 ], [ 0, %50 ]
  %53 = icmp slt i64 %52, 8
  br i1 %53, label %54, label %98

54:                                               ; preds = %51
  %55 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, 1
  %56 = mul i64 %44, 8
  %57 = add i64 %56, %52
  %58 = getelementptr float, ptr %55, i64 %57
  %59 = load <1 x float>, ptr %58, align 4
  %60 = extractelement <1 x float> %59, i64 0
  %61 = insertelement <8 x float> poison, float %60, i32 0
  %62 = shufflevector <8 x float> %61, <8 x float> poison, <8 x i32> zeroinitializer
  %63 = sub i64 16, %48
  %64 = call i64 @llvm.smin.i64(i64 %63, i64 2147483647)
  %65 = trunc i64 %64 to i32
  %66 = insertelement <8 x i32> poison, i32 %65, i32 0
  %67 = shufflevector <8 x i32> %66, <8 x i32> poison, <8 x i32> zeroinitializer
  %68 = icmp sgt <8 x i32> %67, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %69 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %70 = mul i64 %52, 16
  %71 = add i64 %70, %48
  %72 = getelementptr float, ptr %69, i64 %71
  %73 = call <8 x float> @llvm.masked.load.v8f32.p0(ptr align 4 %72, <8 x i1> %68, <8 x float> poison)
  %74 = sub i64 16, %48
  %75 = call i64 @llvm.smin.i64(i64 %74, i64 2147483647)
  %76 = trunc i64 %75 to i32
  %77 = insertelement <8 x i32> poison, i32 %76, i32 0
  %78 = shufflevector <8 x i32> %77, <8 x i32> poison, <8 x i32> zeroinitializer
  %79 = icmp sgt <8 x i32> %78, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, 1
  %81 = mul i64 %44, 16
  %82 = add i64 %81, %48
  %83 = getelementptr float, ptr %80, i64 %82
  %84 = call <8 x float> @llvm.masked.load.v8f32.p0(ptr align 4 %83, <8 x i1> %79, <8 x float> poison)
  %85 = fmul <8 x float> %62, %73
  %86 = fadd <8 x float> %84, %85
  %87 = sub i64 16, %48
  %88 = call i64 @llvm.smin.i64(i64 %87, i64 2147483647)
  %89 = trunc i64 %88 to i32
  %90 = insertelement <8 x i32> poison, i32 %89, i32 0
  %91 = shufflevector <8 x i32> %90, <8 x i32> poison, <8 x i32> zeroinitializer
  %92 = icmp sgt <8 x i32> %91, <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  %93 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, 1
  %94 = mul i64 %44, 16
  %95 = add i64 %94, %48
  %96 = getelementptr float, ptr %93, i64 %95
  call void @llvm.masked.store.v8f32.p0(<8 x float> %86, ptr align 4 %96, <8 x i1> %92)
  %97 = add i64 %52, 1
  br label %51

98:                                               ; preds = %51
  %99 = add i64 %48, 8
  br label %47

100:                                              ; preds = %47
  %101 = add i64 %44, 1
  br label %43

102:                                              ; preds = %43
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %42
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.smin.i64(i64, i64) #0

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: read)
declare <8 x float> @llvm.masked.load.v8f32.p0(ptr captures(none), <8 x i1>, <8 x float>) #1

; Function Attrs: nocallback nofree nosync nounwind willreturn memory(argmem: write)
declare void @llvm.masked.store.v8f32.p0(<8 x float>, ptr captures(none), <8 x i1>) #2

attributes #0 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #1 = { nocallback nofree nosync nounwind willreturn memory(argmem: read) }
attributes #2 = { nocallback nofree nosync nounwind willreturn memory(argmem: write) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
