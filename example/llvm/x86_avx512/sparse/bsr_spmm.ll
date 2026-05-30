; ModuleID = 'bsr_spmm.c'
source_filename = "bsr_spmm.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @bsr_spmm(ptr noalias nocapture noundef readonly %0, ptr noalias nocapture noundef readonly %1, i32 noundef %2, ptr noalias nocapture noundef readonly %3, ptr noalias nocapture noundef %4, i32 noundef %5, i32 noundef %6) local_unnamed_addr #0 {
  %8 = icmp sgt i32 %2, 0
  br i1 %8, label %9, label %130

9:                                                ; preds = %7
  %10 = sext i32 %6 to i64
  %11 = mul nsw i64 %10, %10
  %12 = sext i32 %5 to i64
  %13 = mul nsw i64 %10, %12
  %14 = icmp sgt i32 %6, 0
  %15 = icmp sgt i32 %5, 0
  %16 = and i1 %14, %15
  br i1 %16, label %17, label %130

17:                                               ; preds = %9
  %18 = zext i32 %2 to i64
  %19 = zext i32 %6 to i64
  %20 = zext i32 %5 to i64
  %21 = icmp ult i32 %5, 8
  %22 = icmp ult i32 %5, 64
  %23 = and i64 %20, 4294967232
  %24 = icmp eq i64 %23, %20
  %25 = and i64 %20, 56
  %26 = icmp eq i64 %25, 0
  %27 = and i64 %20, 4294967288
  %28 = icmp eq i64 %27, %20
  br label %29

29:                                               ; preds = %17, %127
  %30 = phi i64 [ 0, %17 ], [ %128, %127 ]
  %31 = mul i64 %11, %30
  %32 = getelementptr inbounds float, ptr %0, i64 %31
  %33 = getelementptr inbounds i32, ptr %1, i64 %30
  %34 = load i32, ptr %33, align 4, !tbaa !5
  %35 = sext i32 %34 to i64
  %36 = mul i64 %13, %35
  %37 = getelementptr inbounds float, ptr %3, i64 %36
  br label %38

38:                                               ; preds = %124, %29
  %39 = phi i64 [ %125, %124 ], [ 0, %29 ]
  %40 = mul nsw i64 %39, %10
  %41 = mul nsw i64 %39, %12
  br label %42

42:                                               ; preds = %121, %38
  %43 = phi i64 [ %122, %121 ], [ 0, %38 ]
  %44 = add nsw i64 %43, %40
  %45 = getelementptr inbounds float, ptr %32, i64 %44
  %46 = load float, ptr %45, align 4, !tbaa !9
  %47 = mul nsw i64 %43, %12
  br i1 %21, label %107, label %48

48:                                               ; preds = %42
  br i1 %22, label %90, label %49

49:                                               ; preds = %48
  %50 = insertelement <16 x float> poison, float %46, i64 0
  %51 = shufflevector <16 x float> %50, <16 x float> poison, <16 x i32> zeroinitializer
  %52 = insertelement <16 x float> poison, float %46, i64 0
  %53 = shufflevector <16 x float> %52, <16 x float> poison, <16 x i32> zeroinitializer
  %54 = insertelement <16 x float> poison, float %46, i64 0
  %55 = shufflevector <16 x float> %54, <16 x float> poison, <16 x i32> zeroinitializer
  %56 = insertelement <16 x float> poison, float %46, i64 0
  %57 = shufflevector <16 x float> %56, <16 x float> poison, <16 x i32> zeroinitializer
  br label %58

58:                                               ; preds = %58, %49
  %59 = phi i64 [ 0, %49 ], [ %86, %58 ]
  %60 = add nsw i64 %59, %47
  %61 = getelementptr inbounds float, ptr %37, i64 %60
  %62 = load <16 x float>, ptr %61, align 4, !tbaa !9
  %63 = getelementptr inbounds float, ptr %61, i64 16
  %64 = load <16 x float>, ptr %63, align 4, !tbaa !9
  %65 = getelementptr inbounds float, ptr %61, i64 32
  %66 = load <16 x float>, ptr %65, align 4, !tbaa !9
  %67 = getelementptr inbounds float, ptr %61, i64 48
  %68 = load <16 x float>, ptr %67, align 4, !tbaa !9
  %69 = fmul fast <16 x float> %62, %51
  %70 = fmul fast <16 x float> %64, %53
  %71 = fmul fast <16 x float> %66, %55
  %72 = fmul fast <16 x float> %68, %57
  %73 = add nsw i64 %59, %41
  %74 = getelementptr inbounds float, ptr %4, i64 %73
  %75 = load <16 x float>, ptr %74, align 4, !tbaa !9
  %76 = getelementptr inbounds float, ptr %74, i64 16
  %77 = load <16 x float>, ptr %76, align 4, !tbaa !9
  %78 = getelementptr inbounds float, ptr %74, i64 32
  %79 = load <16 x float>, ptr %78, align 4, !tbaa !9
  %80 = getelementptr inbounds float, ptr %74, i64 48
  %81 = load <16 x float>, ptr %80, align 4, !tbaa !9
  %82 = fadd fast <16 x float> %75, %69
  %83 = fadd fast <16 x float> %77, %70
  %84 = fadd fast <16 x float> %79, %71
  %85 = fadd fast <16 x float> %81, %72
  store <16 x float> %82, ptr %74, align 4, !tbaa !9
  store <16 x float> %83, ptr %76, align 4, !tbaa !9
  store <16 x float> %84, ptr %78, align 4, !tbaa !9
  store <16 x float> %85, ptr %80, align 4, !tbaa !9
  %86 = add nuw i64 %59, 64
  %87 = icmp eq i64 %86, %23
  br i1 %87, label %88, label %58, !llvm.loop !11

88:                                               ; preds = %58
  br i1 %24, label %121, label %89

89:                                               ; preds = %88
  br i1 %26, label %107, label %90

90:                                               ; preds = %48, %89
  %91 = phi i64 [ %23, %89 ], [ 0, %48 ]
  %92 = insertelement <8 x float> poison, float %46, i64 0
  %93 = shufflevector <8 x float> %92, <8 x float> poison, <8 x i32> zeroinitializer
  br label %94

94:                                               ; preds = %94, %90
  %95 = phi i64 [ %91, %90 ], [ %104, %94 ]
  %96 = add nsw i64 %95, %47
  %97 = getelementptr inbounds float, ptr %37, i64 %96
  %98 = load <8 x float>, ptr %97, align 4, !tbaa !9
  %99 = fmul fast <8 x float> %98, %93
  %100 = add nsw i64 %95, %41
  %101 = getelementptr inbounds float, ptr %4, i64 %100
  %102 = load <8 x float>, ptr %101, align 4, !tbaa !9
  %103 = fadd fast <8 x float> %102, %99
  store <8 x float> %103, ptr %101, align 4, !tbaa !9
  %104 = add nuw i64 %95, 8
  %105 = icmp eq i64 %104, %27
  br i1 %105, label %106, label %94, !llvm.loop !14

106:                                              ; preds = %94
  br i1 %28, label %121, label %107

107:                                              ; preds = %42, %89, %106
  %108 = phi i64 [ 0, %42 ], [ %23, %89 ], [ %27, %106 ]
  br label %109

109:                                              ; preds = %107, %109
  %110 = phi i64 [ %119, %109 ], [ %108, %107 ]
  %111 = add nsw i64 %110, %47
  %112 = getelementptr inbounds float, ptr %37, i64 %111
  %113 = load float, ptr %112, align 4, !tbaa !9
  %114 = fmul fast float %113, %46
  %115 = add nsw i64 %110, %41
  %116 = getelementptr inbounds float, ptr %4, i64 %115
  %117 = load float, ptr %116, align 4, !tbaa !9
  %118 = fadd fast float %117, %114
  store float %118, ptr %116, align 4, !tbaa !9
  %119 = add nuw nsw i64 %110, 1
  %120 = icmp eq i64 %119, %20
  br i1 %120, label %121, label %109, !llvm.loop !16

121:                                              ; preds = %109, %106, %88
  %122 = add nuw nsw i64 %43, 1
  %123 = icmp eq i64 %122, %19
  br i1 %123, label %124, label %42, !llvm.loop !17

124:                                              ; preds = %121
  %125 = add nuw nsw i64 %39, 1
  %126 = icmp eq i64 %125, %19
  br i1 %126, label %127, label %38, !llvm.loop !18

127:                                              ; preds = %124
  %128 = add nuw nsw i64 %30, 1
  %129 = icmp eq i64 %128, %18
  br i1 %129, label %130, label %29, !llvm.loop !19

130:                                              ; preds = %127, %9, %7
  ret void
}

attributes #0 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }

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
!16 = distinct !{!16, !12, !15, !13}
!17 = distinct !{!17, !12}
!18 = distinct !{!18, !12}
!19 = distinct !{!19, !12}
