; ModuleID = 'csr_spmv.c'
source_filename = "csr_spmv.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @csr_spmv(ptr noalias nocapture noundef readonly %0, ptr noalias nocapture noundef readonly %1, ptr noalias nocapture noundef readonly %2, ptr noalias nocapture noundef readonly %3, ptr noalias nocapture noundef writeonly %4, i32 noundef %5) local_unnamed_addr #0 {
  %7 = icmp sgt i32 %5, 0
  br i1 %7, label %8, label %11

8:                                                ; preds = %6
  %9 = zext i32 %5 to i64
  %10 = load i32, ptr %2, align 4, !tbaa !5
  br label %12

11:                                               ; preds = %110, %6
  ret void

12:                                               ; preds = %8, %110
  %13 = phi i32 [ %10, %8 ], [ %17, %110 ]
  %14 = phi i64 [ 0, %8 ], [ %15, %110 ]
  %15 = add nuw nsw i64 %14, 1
  %16 = getelementptr inbounds i32, ptr %2, i64 %15
  %17 = load i32, ptr %16, align 4, !tbaa !5
  %18 = icmp slt i32 %13, %17
  br i1 %18, label %19, label %110

19:                                               ; preds = %12
  %20 = sext i32 %13 to i64
  %21 = sext i32 %17 to i64
  %22 = sub nsw i64 %21, %20
  %23 = icmp ult i64 %22, 8
  br i1 %23, label %107, label %24

24:                                               ; preds = %19
  %25 = icmp ult i64 %22, 64
  br i1 %25, label %83, label %26

26:                                               ; preds = %24
  %27 = and i64 %22, -64
  br label %28

28:                                               ; preds = %28, %26
  %29 = phi i64 [ 0, %26 ], [ %71, %28 ]
  %30 = phi <16 x float> [ zeroinitializer, %26 ], [ %67, %28 ]
  %31 = phi <16 x float> [ zeroinitializer, %26 ], [ %68, %28 ]
  %32 = phi <16 x float> [ zeroinitializer, %26 ], [ %69, %28 ]
  %33 = phi <16 x float> [ zeroinitializer, %26 ], [ %70, %28 ]
  %34 = add i64 %29, %20
  %35 = getelementptr inbounds float, ptr %0, i64 %34
  %36 = load <16 x float>, ptr %35, align 4, !tbaa !9
  %37 = getelementptr inbounds float, ptr %35, i64 16
  %38 = load <16 x float>, ptr %37, align 4, !tbaa !9
  %39 = getelementptr inbounds float, ptr %35, i64 32
  %40 = load <16 x float>, ptr %39, align 4, !tbaa !9
  %41 = getelementptr inbounds float, ptr %35, i64 48
  %42 = load <16 x float>, ptr %41, align 4, !tbaa !9
  %43 = getelementptr inbounds i32, ptr %1, i64 %34
  %44 = load <16 x i32>, ptr %43, align 4, !tbaa !5
  %45 = getelementptr inbounds i32, ptr %43, i64 16
  %46 = load <16 x i32>, ptr %45, align 4, !tbaa !5
  %47 = getelementptr inbounds i32, ptr %43, i64 32
  %48 = load <16 x i32>, ptr %47, align 4, !tbaa !5
  %49 = getelementptr inbounds i32, ptr %43, i64 48
  %50 = load <16 x i32>, ptr %49, align 4, !tbaa !5
  %51 = sext <16 x i32> %44 to <16 x i64>
  %52 = sext <16 x i32> %46 to <16 x i64>
  %53 = sext <16 x i32> %48 to <16 x i64>
  %54 = sext <16 x i32> %50 to <16 x i64>
  %55 = getelementptr inbounds float, ptr %3, <16 x i64> %51
  %56 = getelementptr inbounds float, ptr %3, <16 x i64> %52
  %57 = getelementptr inbounds float, ptr %3, <16 x i64> %53
  %58 = getelementptr inbounds float, ptr %3, <16 x i64> %54
  %59 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %55, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %60 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %56, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %61 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %57, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %62 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %58, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %63 = fmul fast <16 x float> %59, %36
  %64 = fmul fast <16 x float> %60, %38
  %65 = fmul fast <16 x float> %61, %40
  %66 = fmul fast <16 x float> %62, %42
  %67 = fadd fast <16 x float> %63, %30
  %68 = fadd fast <16 x float> %64, %31
  %69 = fadd fast <16 x float> %65, %32
  %70 = fadd fast <16 x float> %66, %33
  %71 = add nuw i64 %29, 64
  %72 = icmp eq i64 %71, %27
  br i1 %72, label %73, label %28, !llvm.loop !11

73:                                               ; preds = %28
  %74 = fadd fast <16 x float> %68, %67
  %75 = fadd fast <16 x float> %69, %74
  %76 = fadd fast <16 x float> %70, %75
  %77 = tail call fast float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %76)
  %78 = icmp eq i64 %22, %27
  br i1 %78, label %110, label %79

79:                                               ; preds = %73
  %80 = add nsw i64 %27, %20
  %81 = and i64 %22, 56
  %82 = icmp eq i64 %81, 0
  br i1 %82, label %107, label %83

83:                                               ; preds = %24, %79
  %84 = phi float [ 0.000000e+00, %24 ], [ %77, %79 ]
  %85 = phi i64 [ 0, %24 ], [ %27, %79 ]
  %86 = and i64 %22, -8
  %87 = add nsw i64 %86, %20
  %88 = insertelement <8 x float> <float poison, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %84, i64 0
  br label %89

89:                                               ; preds = %89, %83
  %90 = phi i64 [ %85, %83 ], [ %102, %89 ]
  %91 = phi <8 x float> [ %88, %83 ], [ %101, %89 ]
  %92 = add i64 %90, %20
  %93 = getelementptr inbounds float, ptr %0, i64 %92
  %94 = load <8 x float>, ptr %93, align 4, !tbaa !9
  %95 = getelementptr inbounds i32, ptr %1, i64 %92
  %96 = load <8 x i32>, ptr %95, align 4, !tbaa !5
  %97 = sext <8 x i32> %96 to <8 x i64>
  %98 = getelementptr inbounds float, ptr %3, <8 x i64> %97
  %99 = tail call <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr> %98, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x float> undef), !tbaa !9
  %100 = fmul fast <8 x float> %99, %94
  %101 = fadd fast <8 x float> %100, %91
  %102 = add nuw i64 %90, 8
  %103 = icmp eq i64 %102, %86
  br i1 %103, label %104, label %89, !llvm.loop !14

104:                                              ; preds = %89
  %105 = tail call fast float @llvm.vector.reduce.fadd.v8f32(float -0.000000e+00, <8 x float> %101)
  %106 = icmp eq i64 %22, %86
  br i1 %106, label %110, label %107

107:                                              ; preds = %19, %79, %104
  %108 = phi i64 [ %20, %19 ], [ %80, %79 ], [ %87, %104 ]
  %109 = phi float [ 0.000000e+00, %19 ], [ %77, %79 ], [ %105, %104 ]
  br label %114

110:                                              ; preds = %114, %73, %104, %12
  %111 = phi float [ 0.000000e+00, %12 ], [ %77, %73 ], [ %105, %104 ], [ %125, %114 ]
  %112 = getelementptr inbounds float, ptr %4, i64 %14
  store float %111, ptr %112, align 4, !tbaa !9
  %113 = icmp eq i64 %15, %9
  br i1 %113, label %11, label %12, !llvm.loop !16

114:                                              ; preds = %107, %114
  %115 = phi i64 [ %126, %114 ], [ %108, %107 ]
  %116 = phi float [ %125, %114 ], [ %109, %107 ]
  %117 = getelementptr inbounds float, ptr %0, i64 %115
  %118 = load float, ptr %117, align 4, !tbaa !9
  %119 = getelementptr inbounds i32, ptr %1, i64 %115
  %120 = load i32, ptr %119, align 4, !tbaa !5
  %121 = sext i32 %120 to i64
  %122 = getelementptr inbounds float, ptr %3, i64 %121
  %123 = load float, ptr %122, align 4, !tbaa !9
  %124 = fmul fast float %123, %118
  %125 = fadd fast float %124, %116
  %126 = add nsw i64 %115, 1
  %127 = icmp eq i64 %126, %21
  br i1 %127, label %110, label %114, !llvm.loop !17
}

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr>, i32 immarg, <16 x i1>, <16 x float>) #1

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v16f32(float, <16 x float>) #2

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr>, i32 immarg, <8 x i1>, <8 x float>) #1

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v8f32(float, <8 x float>) #2

attributes #0 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #1 = { nocallback nofree nosync nounwind readonly willreturn }
attributes #2 = { nocallback nofree nosync nounwind readnone willreturn }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 7, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{!"Ubuntu clang version 15.0.7"}
!5 = !{!6, !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!10, !10, i64 0}
!10 = !{!"float", !7, i64 0}
!11 = distinct !{!11, !12, !13}
!12 = !{!"llvm.loop.mustprogress"}
!13 = !{!"llvm.loop.isvectorized", i32 1}
!14 = distinct !{!14, !12, !13, !15}
!15 = !{!"llvm.loop.unroll.runtime.disable"}
!16 = distinct !{!16, !12}
!17 = distinct !{!17, !12, !15, !13}
