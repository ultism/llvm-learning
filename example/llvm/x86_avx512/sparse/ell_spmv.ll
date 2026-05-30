; ModuleID = 'ell_spmv.c'
source_filename = "ell_spmv.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @ell_spmv(ptr noalias nocapture noundef readonly %0, ptr noalias nocapture noundef readonly %1, i32 noundef %2, i32 noundef %3, ptr noalias nocapture noundef readonly %4, ptr noalias nocapture noundef %5) local_unnamed_addr #0 {
  %7 = icmp sgt i32 %2, 0
  br i1 %7, label %8, label %125

8:                                                ; preds = %6
  %9 = zext i32 %2 to i64
  %10 = shl nuw nsw i64 %9, 2
  tail call void @llvm.memset.p0.i64(ptr align 4 %5, i8 0, i64 %10, i1 false), !tbaa !5
  %11 = icmp sgt i32 %3, 0
  br i1 %11, label %12, label %125

12:                                               ; preds = %8
  %13 = sext i32 %2 to i64
  %14 = zext i32 %3 to i64
  %15 = zext i32 %2 to i64
  %16 = and i64 %15, 4294967280
  %17 = add nsw i64 %16, -16
  %18 = lshr exact i64 %17, 4
  %19 = add nuw nsw i64 %18, 1
  %20 = icmp ult i32 %2, 8
  %21 = icmp ult i32 %2, 16
  %22 = and i64 %15, 4294967280
  %23 = and i64 %19, 1
  %24 = icmp eq i64 %17, 0
  %25 = and i64 %19, 2305843009213693950
  %26 = icmp eq i64 %23, 0
  %27 = icmp eq i64 %22, %15
  %28 = and i64 %15, 8
  %29 = icmp eq i64 %28, 0
  %30 = and i64 %15, 4294967288
  %31 = icmp eq i64 %30, %15
  br label %32

32:                                               ; preds = %12, %122
  %33 = phi i64 [ 0, %12 ], [ %123, %122 ]
  %34 = mul nsw i64 %33, %13
  br i1 %20, label %104, label %35

35:                                               ; preds = %32
  br i1 %21, label %85, label %36

36:                                               ; preds = %35
  br i1 %24, label %68, label %37

37:                                               ; preds = %36, %37
  %38 = phi i64 [ %65, %37 ], [ 0, %36 ]
  %39 = phi i64 [ %66, %37 ], [ 0, %36 ]
  %40 = add nsw i64 %34, %38
  %41 = getelementptr inbounds float, ptr %0, i64 %40
  %42 = load <16 x float>, ptr %41, align 4, !tbaa !5
  %43 = getelementptr inbounds i32, ptr %1, i64 %40
  %44 = load <16 x i32>, ptr %43, align 4, !tbaa !9
  %45 = sext <16 x i32> %44 to <16 x i64>
  %46 = getelementptr inbounds float, ptr %4, <16 x i64> %45
  %47 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %46, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !5
  %48 = fmul fast <16 x float> %47, %42
  %49 = getelementptr inbounds float, ptr %5, i64 %38
  %50 = load <16 x float>, ptr %49, align 4, !tbaa !5
  %51 = fadd fast <16 x float> %50, %48
  store <16 x float> %51, ptr %49, align 4, !tbaa !5
  %52 = or i64 %38, 16
  %53 = add nsw i64 %34, %52
  %54 = getelementptr inbounds float, ptr %0, i64 %53
  %55 = load <16 x float>, ptr %54, align 4, !tbaa !5
  %56 = getelementptr inbounds i32, ptr %1, i64 %53
  %57 = load <16 x i32>, ptr %56, align 4, !tbaa !9
  %58 = sext <16 x i32> %57 to <16 x i64>
  %59 = getelementptr inbounds float, ptr %4, <16 x i64> %58
  %60 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %59, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !5
  %61 = fmul fast <16 x float> %60, %55
  %62 = getelementptr inbounds float, ptr %5, i64 %52
  %63 = load <16 x float>, ptr %62, align 4, !tbaa !5
  %64 = fadd fast <16 x float> %63, %61
  store <16 x float> %64, ptr %62, align 4, !tbaa !5
  %65 = add nuw i64 %38, 32
  %66 = add i64 %39, 2
  %67 = icmp eq i64 %66, %25
  br i1 %67, label %68, label %37, !llvm.loop !11

68:                                               ; preds = %37, %36
  %69 = phi i64 [ 0, %36 ], [ %65, %37 ]
  br i1 %26, label %83, label %70

70:                                               ; preds = %68
  %71 = add nsw i64 %34, %69
  %72 = getelementptr inbounds float, ptr %0, i64 %71
  %73 = load <16 x float>, ptr %72, align 4, !tbaa !5
  %74 = getelementptr inbounds i32, ptr %1, i64 %71
  %75 = load <16 x i32>, ptr %74, align 4, !tbaa !9
  %76 = sext <16 x i32> %75 to <16 x i64>
  %77 = getelementptr inbounds float, ptr %4, <16 x i64> %76
  %78 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %77, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !5
  %79 = fmul fast <16 x float> %78, %73
  %80 = getelementptr inbounds float, ptr %5, i64 %69
  %81 = load <16 x float>, ptr %80, align 4, !tbaa !5
  %82 = fadd fast <16 x float> %81, %79
  store <16 x float> %82, ptr %80, align 4, !tbaa !5
  br label %83

83:                                               ; preds = %68, %70
  br i1 %27, label %122, label %84

84:                                               ; preds = %83
  br i1 %29, label %104, label %85

85:                                               ; preds = %35, %84
  %86 = phi i64 [ %22, %84 ], [ 0, %35 ]
  br label %87

87:                                               ; preds = %87, %85
  %88 = phi i64 [ %86, %85 ], [ %101, %87 ]
  %89 = add nsw i64 %34, %88
  %90 = getelementptr inbounds float, ptr %0, i64 %89
  %91 = load <8 x float>, ptr %90, align 4, !tbaa !5
  %92 = getelementptr inbounds i32, ptr %1, i64 %89
  %93 = load <8 x i32>, ptr %92, align 4, !tbaa !9
  %94 = sext <8 x i32> %93 to <8 x i64>
  %95 = getelementptr inbounds float, ptr %4, <8 x i64> %94
  %96 = tail call <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr> %95, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x float> undef), !tbaa !5
  %97 = fmul fast <8 x float> %96, %91
  %98 = getelementptr inbounds float, ptr %5, i64 %88
  %99 = load <8 x float>, ptr %98, align 4, !tbaa !5
  %100 = fadd fast <8 x float> %99, %97
  store <8 x float> %100, ptr %98, align 4, !tbaa !5
  %101 = add nuw i64 %88, 8
  %102 = icmp eq i64 %101, %30
  br i1 %102, label %103, label %87, !llvm.loop !14

103:                                              ; preds = %87
  br i1 %31, label %122, label %104

104:                                              ; preds = %32, %84, %103
  %105 = phi i64 [ 0, %32 ], [ %22, %84 ], [ %30, %103 ]
  br label %106

106:                                              ; preds = %104, %106
  %107 = phi i64 [ %120, %106 ], [ %105, %104 ]
  %108 = add nsw i64 %34, %107
  %109 = getelementptr inbounds float, ptr %0, i64 %108
  %110 = load float, ptr %109, align 4, !tbaa !5
  %111 = getelementptr inbounds i32, ptr %1, i64 %108
  %112 = load i32, ptr %111, align 4, !tbaa !9
  %113 = sext i32 %112 to i64
  %114 = getelementptr inbounds float, ptr %4, i64 %113
  %115 = load float, ptr %114, align 4, !tbaa !5
  %116 = fmul fast float %115, %110
  %117 = getelementptr inbounds float, ptr %5, i64 %107
  %118 = load float, ptr %117, align 4, !tbaa !5
  %119 = fadd fast float %118, %116
  store float %119, ptr %117, align 4, !tbaa !5
  %120 = add nuw nsw i64 %107, 1
  %121 = icmp eq i64 %120, %15
  br i1 %121, label %122, label %106, !llvm.loop !16

122:                                              ; preds = %106, %103, %83
  %123 = add nuw nsw i64 %33, 1
  %124 = icmp eq i64 %123, %14
  br i1 %124, label %125, label %32, !llvm.loop !17

125:                                              ; preds = %122, %6, %8
  ret void
}

; Function Attrs: argmemonly nocallback nofree nounwind willreturn writeonly
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr>, i32 immarg, <16 x i1>, <16 x float>) #2

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr>, i32 immarg, <8 x i1>, <8 x float>) #2

attributes #0 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly nocallback nofree nounwind willreturn writeonly }
attributes #2 = { nocallback nofree nosync nounwind readonly willreturn }

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
!9 = !{!10, !10, i64 0}
!10 = !{!"int", !7, i64 0}
!11 = distinct !{!11, !12, !13}
!12 = !{!"llvm.loop.mustprogress"}
!13 = !{!"llvm.loop.isvectorized", i32 1}
!14 = distinct !{!14, !12, !13, !15}
!15 = !{!"llvm.loop.unroll.runtime.disable"}
!16 = distinct !{!16, !12, !15, !13}
!17 = distinct !{!17, !12}
