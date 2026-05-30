; ModuleID = 'gemm.c'
source_filename = "gemm.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @gemm_ijk(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, ptr nocapture noundef writeonly %2, i64 noundef %3, i64 noundef %4, i64 noundef %5) local_unnamed_addr #0 {
  %7 = icmp eq i64 %3, 0
  %8 = icmp eq i64 %5, 0
  %9 = or i1 %7, %8
  br i1 %9, label %150, label %10

10:                                               ; preds = %6
  %11 = icmp eq i64 %4, 0
  br i1 %11, label %26, label %12

12:                                               ; preds = %10
  %13 = icmp ugt i64 %4, 7
  %14 = icmp eq i64 %5, 1
  %15 = and i1 %13, %14
  %16 = icmp ult i64 %4, 64
  %17 = and i64 %4, -64
  %18 = icmp eq i64 %17, %4
  %19 = and i64 %4, 56
  %20 = icmp eq i64 %19, 0
  %21 = and i64 %4, -8
  %22 = icmp eq i64 %21, %4
  %23 = and i64 %4, 1
  %24 = icmp eq i64 %23, 0
  %25 = sub i64 0, %4
  br label %29

26:                                               ; preds = %10
  %27 = mul i64 %5, %3
  %28 = shl i64 %27, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %2, i8 0, i64 %28, i1 false), !tbaa !5
  br label %150

29:                                               ; preds = %12, %147
  %30 = phi i64 [ %148, %147 ], [ 0, %12 ]
  %31 = mul i64 %30, %4
  %32 = mul i64 %30, %5
  br label %33

33:                                               ; preds = %141, %29
  %34 = phi i64 [ 0, %29 ], [ %145, %141 ]
  br i1 %15, label %35, label %97

35:                                               ; preds = %33
  br i1 %16, label %77, label %36

36:                                               ; preds = %35, %36
  %37 = phi i64 [ %69, %36 ], [ 0, %35 ]
  %38 = phi <16 x float> [ %65, %36 ], [ zeroinitializer, %35 ]
  %39 = phi <16 x float> [ %66, %36 ], [ zeroinitializer, %35 ]
  %40 = phi <16 x float> [ %67, %36 ], [ zeroinitializer, %35 ]
  %41 = phi <16 x float> [ %68, %36 ], [ zeroinitializer, %35 ]
  %42 = add i64 %37, %31
  %43 = getelementptr inbounds float, ptr %0, i64 %42
  %44 = load <16 x float>, ptr %43, align 4, !tbaa !5
  %45 = getelementptr inbounds float, ptr %43, i64 16
  %46 = load <16 x float>, ptr %45, align 4, !tbaa !5
  %47 = getelementptr inbounds float, ptr %43, i64 32
  %48 = load <16 x float>, ptr %47, align 4, !tbaa !5
  %49 = getelementptr inbounds float, ptr %43, i64 48
  %50 = load <16 x float>, ptr %49, align 4, !tbaa !5
  %51 = mul i64 %37, %5
  %52 = add i64 %51, %34
  %53 = getelementptr inbounds float, ptr %1, i64 %52
  %54 = load <16 x float>, ptr %53, align 4, !tbaa !5
  %55 = getelementptr inbounds float, ptr %53, i64 16
  %56 = load <16 x float>, ptr %55, align 4, !tbaa !5
  %57 = getelementptr inbounds float, ptr %53, i64 32
  %58 = load <16 x float>, ptr %57, align 4, !tbaa !5
  %59 = getelementptr inbounds float, ptr %53, i64 48
  %60 = load <16 x float>, ptr %59, align 4, !tbaa !5
  %61 = fmul fast <16 x float> %54, %44
  %62 = fmul fast <16 x float> %56, %46
  %63 = fmul fast <16 x float> %58, %48
  %64 = fmul fast <16 x float> %60, %50
  %65 = fadd fast <16 x float> %61, %38
  %66 = fadd fast <16 x float> %62, %39
  %67 = fadd fast <16 x float> %63, %40
  %68 = fadd fast <16 x float> %64, %41
  %69 = add nuw i64 %37, 64
  %70 = icmp eq i64 %69, %17
  br i1 %70, label %71, label %36, !llvm.loop !9

71:                                               ; preds = %36
  %72 = fadd fast <16 x float> %66, %65
  %73 = fadd fast <16 x float> %67, %72
  %74 = fadd fast <16 x float> %68, %73
  %75 = tail call fast float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %74)
  br i1 %18, label %141, label %76

76:                                               ; preds = %71
  br i1 %20, label %97, label %77

77:                                               ; preds = %35, %76
  %78 = phi float [ 0.000000e+00, %35 ], [ %75, %76 ]
  %79 = phi i64 [ 0, %35 ], [ %17, %76 ]
  %80 = insertelement <8 x float> <float poison, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %78, i64 0
  br label %81

81:                                               ; preds = %81, %77
  %82 = phi i64 [ %79, %77 ], [ %93, %81 ]
  %83 = phi <8 x float> [ %80, %77 ], [ %92, %81 ]
  %84 = add i64 %82, %31
  %85 = getelementptr inbounds float, ptr %0, i64 %84
  %86 = load <8 x float>, ptr %85, align 4, !tbaa !5
  %87 = mul i64 %82, %5
  %88 = add i64 %87, %34
  %89 = getelementptr inbounds float, ptr %1, i64 %88
  %90 = load <8 x float>, ptr %89, align 4, !tbaa !5
  %91 = fmul fast <8 x float> %90, %86
  %92 = fadd fast <8 x float> %91, %83
  %93 = add nuw i64 %82, 8
  %94 = icmp eq i64 %93, %21
  br i1 %94, label %95, label %81, !llvm.loop !12

95:                                               ; preds = %81
  %96 = tail call fast float @llvm.vector.reduce.fadd.v8f32(float -0.000000e+00, <8 x float> %92)
  br i1 %22, label %141, label %97

97:                                               ; preds = %33, %76, %95
  %98 = phi i64 [ 0, %33 ], [ %17, %76 ], [ %21, %95 ]
  %99 = phi float [ 0.000000e+00, %33 ], [ %75, %76 ], [ %96, %95 ]
  %100 = xor i64 %98, -1
  br i1 %24, label %112, label %101

101:                                              ; preds = %97
  %102 = add i64 %98, %31
  %103 = getelementptr inbounds float, ptr %0, i64 %102
  %104 = load float, ptr %103, align 4, !tbaa !5
  %105 = mul i64 %98, %5
  %106 = add i64 %105, %34
  %107 = getelementptr inbounds float, ptr %1, i64 %106
  %108 = load float, ptr %107, align 4, !tbaa !5
  %109 = fmul fast float %108, %104
  %110 = fadd fast float %109, %99
  %111 = or i64 %98, 1
  br label %112

112:                                              ; preds = %101, %97
  %113 = phi float [ undef, %97 ], [ %110, %101 ]
  %114 = phi i64 [ %98, %97 ], [ %111, %101 ]
  %115 = phi float [ %99, %97 ], [ %110, %101 ]
  %116 = icmp eq i64 %100, %25
  br i1 %116, label %141, label %117

117:                                              ; preds = %112, %117
  %118 = phi i64 [ %139, %117 ], [ %114, %112 ]
  %119 = phi float [ %138, %117 ], [ %115, %112 ]
  %120 = add i64 %118, %31
  %121 = getelementptr inbounds float, ptr %0, i64 %120
  %122 = load float, ptr %121, align 4, !tbaa !5
  %123 = mul i64 %118, %5
  %124 = add i64 %123, %34
  %125 = getelementptr inbounds float, ptr %1, i64 %124
  %126 = load float, ptr %125, align 4, !tbaa !5
  %127 = fmul fast float %126, %122
  %128 = fadd fast float %127, %119
  %129 = add nuw i64 %118, 1
  %130 = add i64 %129, %31
  %131 = getelementptr inbounds float, ptr %0, i64 %130
  %132 = load float, ptr %131, align 4, !tbaa !5
  %133 = mul i64 %129, %5
  %134 = add i64 %133, %34
  %135 = getelementptr inbounds float, ptr %1, i64 %134
  %136 = load float, ptr %135, align 4, !tbaa !5
  %137 = fmul fast float %136, %132
  %138 = fadd fast float %137, %128
  %139 = add nuw i64 %118, 2
  %140 = icmp eq i64 %139, %4
  br i1 %140, label %141, label %117, !llvm.loop !14

141:                                              ; preds = %112, %117, %95, %71
  %142 = phi float [ %75, %71 ], [ %96, %95 ], [ %113, %112 ], [ %138, %117 ]
  %143 = add i64 %34, %32
  %144 = getelementptr inbounds float, ptr %2, i64 %143
  store float %142, ptr %144, align 4, !tbaa !5
  %145 = add nuw i64 %34, 1
  %146 = icmp eq i64 %145, %5
  br i1 %146, label %147, label %33, !llvm.loop !15

147:                                              ; preds = %141
  %148 = add nuw i64 %30, 1
  %149 = icmp eq i64 %148, %3
  br i1 %149, label %150, label %29, !llvm.loop !16

150:                                              ; preds = %147, %26, %6
  ret void
}

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @gemm_ikj(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, ptr nocapture noundef %2, i64 noundef %3, i64 noundef %4, i64 noundef %5) local_unnamed_addr #0 {
  %7 = icmp eq i64 %3, 0
  br i1 %7, label %157, label %8

8:                                                ; preds = %6
  %9 = icmp eq i64 %5, 0
  %10 = icmp eq i64 %4, 0
  br i1 %10, label %153, label %11

11:                                               ; preds = %8
  br i1 %9, label %157, label %12

12:                                               ; preds = %11
  %13 = shl i64 %5, 2
  %14 = shl i64 %5, 2
  %15 = shl i64 %5, 2
  %16 = icmp ult i64 %5, 8
  %17 = icmp ult i64 %5, 64
  %18 = and i64 %5, -64
  %19 = icmp eq i64 %18, %5
  %20 = and i64 %5, 56
  %21 = icmp eq i64 %20, 0
  %22 = and i64 %5, -8
  %23 = icmp eq i64 %22, %5
  %24 = and i64 %5, 1
  %25 = icmp eq i64 %24, 0
  %26 = sub i64 0, %5
  br label %27

27:                                               ; preds = %150, %12
  %28 = phi i64 [ %151, %150 ], [ 0, %12 ]
  %29 = mul i64 %14, %28
  %30 = getelementptr i8, ptr %2, i64 %29
  %31 = add i64 %14, %29
  %32 = getelementptr i8, ptr %2, i64 %31
  %33 = mul i64 %13, %28
  %34 = getelementptr i8, ptr %2, i64 %33
  tail call void @llvm.memset.p0.i64(ptr align 4 %34, i8 0, i64 %13, i1 false), !tbaa !5
  %35 = mul i64 %28, %4
  %36 = mul i64 %28, %5
  br label %37

37:                                               ; preds = %147, %27
  %38 = phi i64 [ 0, %27 ], [ %148, %147 ]
  %39 = add i64 %38, %35
  %40 = getelementptr inbounds float, ptr %0, i64 %39
  %41 = load float, ptr %40, align 4, !tbaa !5
  %42 = mul i64 %38, %5
  br i1 %16, label %110, label %43

43:                                               ; preds = %37
  %44 = mul i64 %15, %38
  %45 = add i64 %14, %44
  %46 = getelementptr i8, ptr %1, i64 %45
  %47 = getelementptr i8, ptr %1, i64 %44
  %48 = icmp ult ptr %30, %46
  %49 = icmp ult ptr %47, %32
  %50 = and i1 %48, %49
  br i1 %50, label %110, label %51

51:                                               ; preds = %43
  br i1 %17, label %93, label %52

52:                                               ; preds = %51
  %53 = insertelement <16 x float> poison, float %41, i64 0
  %54 = shufflevector <16 x float> %53, <16 x float> poison, <16 x i32> zeroinitializer
  %55 = insertelement <16 x float> poison, float %41, i64 0
  %56 = shufflevector <16 x float> %55, <16 x float> poison, <16 x i32> zeroinitializer
  %57 = insertelement <16 x float> poison, float %41, i64 0
  %58 = shufflevector <16 x float> %57, <16 x float> poison, <16 x i32> zeroinitializer
  %59 = insertelement <16 x float> poison, float %41, i64 0
  %60 = shufflevector <16 x float> %59, <16 x float> poison, <16 x i32> zeroinitializer
  br label %61

61:                                               ; preds = %61, %52
  %62 = phi i64 [ 0, %52 ], [ %89, %61 ]
  %63 = add i64 %62, %42
  %64 = getelementptr inbounds float, ptr %1, i64 %63
  %65 = load <16 x float>, ptr %64, align 4, !tbaa !5, !alias.scope !17
  %66 = getelementptr inbounds float, ptr %64, i64 16
  %67 = load <16 x float>, ptr %66, align 4, !tbaa !5, !alias.scope !17
  %68 = getelementptr inbounds float, ptr %64, i64 32
  %69 = load <16 x float>, ptr %68, align 4, !tbaa !5, !alias.scope !17
  %70 = getelementptr inbounds float, ptr %64, i64 48
  %71 = load <16 x float>, ptr %70, align 4, !tbaa !5, !alias.scope !17
  %72 = fmul fast <16 x float> %65, %54
  %73 = fmul fast <16 x float> %67, %56
  %74 = fmul fast <16 x float> %69, %58
  %75 = fmul fast <16 x float> %71, %60
  %76 = add i64 %62, %36
  %77 = getelementptr inbounds float, ptr %2, i64 %76
  %78 = load <16 x float>, ptr %77, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  %79 = getelementptr inbounds float, ptr %77, i64 16
  %80 = load <16 x float>, ptr %79, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  %81 = getelementptr inbounds float, ptr %77, i64 32
  %82 = load <16 x float>, ptr %81, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  %83 = getelementptr inbounds float, ptr %77, i64 48
  %84 = load <16 x float>, ptr %83, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  %85 = fadd fast <16 x float> %78, %72
  %86 = fadd fast <16 x float> %80, %73
  %87 = fadd fast <16 x float> %82, %74
  %88 = fadd fast <16 x float> %84, %75
  store <16 x float> %85, ptr %77, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  store <16 x float> %86, ptr %79, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  store <16 x float> %87, ptr %81, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  store <16 x float> %88, ptr %83, align 4, !tbaa !5, !alias.scope !20, !noalias !17
  %89 = add nuw i64 %62, 64
  %90 = icmp eq i64 %89, %18
  br i1 %90, label %91, label %61, !llvm.loop !22

91:                                               ; preds = %61
  br i1 %19, label %147, label %92

92:                                               ; preds = %91
  br i1 %21, label %110, label %93

93:                                               ; preds = %51, %92
  %94 = phi i64 [ %18, %92 ], [ 0, %51 ]
  %95 = insertelement <8 x float> poison, float %41, i64 0
  %96 = shufflevector <8 x float> %95, <8 x float> poison, <8 x i32> zeroinitializer
  br label %97

97:                                               ; preds = %97, %93
  %98 = phi i64 [ %94, %93 ], [ %107, %97 ]
  %99 = add i64 %98, %42
  %100 = getelementptr inbounds float, ptr %1, i64 %99
  %101 = load <8 x float>, ptr %100, align 4, !tbaa !5, !alias.scope !23
  %102 = fmul fast <8 x float> %101, %96
  %103 = add i64 %98, %36
  %104 = getelementptr inbounds float, ptr %2, i64 %103
  %105 = load <8 x float>, ptr %104, align 4, !tbaa !5, !alias.scope !26, !noalias !23
  %106 = fadd fast <8 x float> %105, %102
  store <8 x float> %106, ptr %104, align 4, !tbaa !5, !alias.scope !26, !noalias !23
  %107 = add nuw i64 %98, 8
  %108 = icmp eq i64 %107, %22
  br i1 %108, label %109, label %97, !llvm.loop !28

109:                                              ; preds = %97
  br i1 %23, label %147, label %110

110:                                              ; preds = %43, %37, %92, %109
  %111 = phi i64 [ 0, %37 ], [ 0, %43 ], [ %18, %92 ], [ %22, %109 ]
  %112 = xor i64 %111, -1
  br i1 %25, label %123, label %113

113:                                              ; preds = %110
  %114 = add i64 %111, %42
  %115 = getelementptr inbounds float, ptr %1, i64 %114
  %116 = load float, ptr %115, align 4, !tbaa !5
  %117 = fmul fast float %116, %41
  %118 = add i64 %111, %36
  %119 = getelementptr inbounds float, ptr %2, i64 %118
  %120 = load float, ptr %119, align 4, !tbaa !5
  %121 = fadd fast float %120, %117
  store float %121, ptr %119, align 4, !tbaa !5
  %122 = or i64 %111, 1
  br label %123

123:                                              ; preds = %113, %110
  %124 = phi i64 [ %111, %110 ], [ %122, %113 ]
  %125 = icmp eq i64 %112, %26
  br i1 %125, label %147, label %126

126:                                              ; preds = %123, %126
  %127 = phi i64 [ %145, %126 ], [ %124, %123 ]
  %128 = add i64 %127, %42
  %129 = getelementptr inbounds float, ptr %1, i64 %128
  %130 = load float, ptr %129, align 4, !tbaa !5
  %131 = fmul fast float %130, %41
  %132 = add i64 %127, %36
  %133 = getelementptr inbounds float, ptr %2, i64 %132
  %134 = load float, ptr %133, align 4, !tbaa !5
  %135 = fadd fast float %134, %131
  store float %135, ptr %133, align 4, !tbaa !5
  %136 = add nuw i64 %127, 1
  %137 = add i64 %136, %42
  %138 = getelementptr inbounds float, ptr %1, i64 %137
  %139 = load float, ptr %138, align 4, !tbaa !5
  %140 = fmul fast float %139, %41
  %141 = add i64 %136, %36
  %142 = getelementptr inbounds float, ptr %2, i64 %141
  %143 = load float, ptr %142, align 4, !tbaa !5
  %144 = fadd fast float %143, %140
  store float %144, ptr %142, align 4, !tbaa !5
  %145 = add nuw i64 %127, 2
  %146 = icmp eq i64 %145, %5
  br i1 %146, label %147, label %126, !llvm.loop !29

147:                                              ; preds = %123, %126, %109, %91
  %148 = add nuw i64 %38, 1
  %149 = icmp eq i64 %148, %4
  br i1 %149, label %150, label %37, !llvm.loop !30

150:                                              ; preds = %147
  %151 = add nuw i64 %28, 1
  %152 = icmp eq i64 %151, %3
  br i1 %152, label %157, label %27, !llvm.loop !31

153:                                              ; preds = %8
  br i1 %9, label %157, label %154

154:                                              ; preds = %153
  %155 = mul i64 %5, %3
  %156 = shl i64 %155, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %2, i8 0, i64 %156, i1 false), !tbaa !5
  br label %157

157:                                              ; preds = %150, %153, %11, %154, %6
  ret void
}

; Function Attrs: argmemonly nocallback nofree nounwind willreturn writeonly
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v16f32(float, <16 x float>) #2

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v8f32(float, <8 x float>) #2

attributes #0 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly nocallback nofree nounwind willreturn writeonly }
attributes #2 = { nocallback nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 15.0.7"}
!5 = !{!6, !6, i64 0}
!6 = !{!"float", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = distinct !{!9, !10, !11}
!10 = !{!"llvm.loop.mustprogress"}
!11 = !{!"llvm.loop.isvectorized", i32 1}
!12 = distinct !{!12, !10, !11, !13}
!13 = !{!"llvm.loop.unroll.runtime.disable"}
!14 = distinct !{!14, !10, !11}
!15 = distinct !{!15, !10}
!16 = distinct !{!16, !10}
!17 = !{!18}
!18 = distinct !{!18, !19}
!19 = distinct !{!19, !"LVerDomain"}
!20 = !{!21}
!21 = distinct !{!21, !19}
!22 = distinct !{!22, !10, !11}
!23 = !{!24}
!24 = distinct !{!24, !25}
!25 = distinct !{!25, !"LVerDomain"}
!26 = !{!27}
!27 = distinct !{!27, !25}
!28 = distinct !{!28, !10, !11, !13}
!29 = distinct !{!29, !10, !11}
!30 = distinct !{!30, !10}
!31 = distinct !{!31, !10}
