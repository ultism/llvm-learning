; ModuleID = 'gather.c'
source_filename = "gather.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @gather_index(ptr noalias nocapture noundef readonly %0, ptr noalias nocapture noundef readonly %1, ptr noalias nocapture noundef writeonly %2, i64 noundef %3) local_unnamed_addr #0 {
  %5 = icmp eq i64 %3, 0
  br i1 %5, label %89, label %6

6:                                                ; preds = %4
  %7 = icmp ult i64 %3, 8
  br i1 %7, label %87, label %8

8:                                                ; preds = %6
  %9 = icmp ult i64 %3, 16
  br i1 %9, label %72, label %10

10:                                               ; preds = %8
  %11 = and i64 %3, -16
  %12 = add i64 %11, -16
  %13 = lshr exact i64 %12, 4
  %14 = add nuw nsw i64 %13, 1
  %15 = and i64 %14, 3
  %16 = icmp ult i64 %12, 48
  br i1 %16, label %52, label %17

17:                                               ; preds = %10
  %18 = and i64 %14, 2305843009213693948
  br label %19

19:                                               ; preds = %19, %17
  %20 = phi i64 [ 0, %17 ], [ %49, %19 ]
  %21 = phi i64 [ 0, %17 ], [ %50, %19 ]
  %22 = getelementptr inbounds i32, ptr %1, i64 %20
  %23 = load <16 x i32>, ptr %22, align 4, !tbaa !5
  %24 = sext <16 x i32> %23 to <16 x i64>
  %25 = getelementptr inbounds float, ptr %0, <16 x i64> %24
  %26 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %25, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %27 = getelementptr inbounds float, ptr %2, i64 %20
  store <16 x float> %26, ptr %27, align 4, !tbaa !9
  %28 = or i64 %20, 16
  %29 = getelementptr inbounds i32, ptr %1, i64 %28
  %30 = load <16 x i32>, ptr %29, align 4, !tbaa !5
  %31 = sext <16 x i32> %30 to <16 x i64>
  %32 = getelementptr inbounds float, ptr %0, <16 x i64> %31
  %33 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %32, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %34 = getelementptr inbounds float, ptr %2, i64 %28
  store <16 x float> %33, ptr %34, align 4, !tbaa !9
  %35 = or i64 %20, 32
  %36 = getelementptr inbounds i32, ptr %1, i64 %35
  %37 = load <16 x i32>, ptr %36, align 4, !tbaa !5
  %38 = sext <16 x i32> %37 to <16 x i64>
  %39 = getelementptr inbounds float, ptr %0, <16 x i64> %38
  %40 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %39, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %41 = getelementptr inbounds float, ptr %2, i64 %35
  store <16 x float> %40, ptr %41, align 4, !tbaa !9
  %42 = or i64 %20, 48
  %43 = getelementptr inbounds i32, ptr %1, i64 %42
  %44 = load <16 x i32>, ptr %43, align 4, !tbaa !5
  %45 = sext <16 x i32> %44 to <16 x i64>
  %46 = getelementptr inbounds float, ptr %0, <16 x i64> %45
  %47 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %46, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %48 = getelementptr inbounds float, ptr %2, i64 %42
  store <16 x float> %47, ptr %48, align 4, !tbaa !9
  %49 = add nuw i64 %20, 64
  %50 = add i64 %21, 4
  %51 = icmp eq i64 %50, %18
  br i1 %51, label %52, label %19, !llvm.loop !11

52:                                               ; preds = %19, %10
  %53 = phi i64 [ 0, %10 ], [ %49, %19 ]
  %54 = icmp eq i64 %15, 0
  br i1 %54, label %67, label %55

55:                                               ; preds = %52, %55
  %56 = phi i64 [ %64, %55 ], [ %53, %52 ]
  %57 = phi i64 [ %65, %55 ], [ 0, %52 ]
  %58 = getelementptr inbounds i32, ptr %1, i64 %56
  %59 = load <16 x i32>, ptr %58, align 4, !tbaa !5
  %60 = sext <16 x i32> %59 to <16 x i64>
  %61 = getelementptr inbounds float, ptr %0, <16 x i64> %60
  %62 = tail call <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr> %61, i32 4, <16 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <16 x float> undef), !tbaa !9
  %63 = getelementptr inbounds float, ptr %2, i64 %56
  store <16 x float> %62, ptr %63, align 4, !tbaa !9
  %64 = add nuw i64 %56, 16
  %65 = add i64 %57, 1
  %66 = icmp eq i64 %65, %15
  br i1 %66, label %67, label %55, !llvm.loop !14

67:                                               ; preds = %55, %52
  %68 = icmp eq i64 %11, %3
  br i1 %68, label %89, label %69

69:                                               ; preds = %67
  %70 = and i64 %3, 8
  %71 = icmp eq i64 %70, 0
  br i1 %71, label %87, label %72

72:                                               ; preds = %8, %69
  %73 = phi i64 [ %11, %69 ], [ 0, %8 ]
  %74 = and i64 %3, -8
  br label %75

75:                                               ; preds = %75, %72
  %76 = phi i64 [ %73, %72 ], [ %83, %75 ]
  %77 = getelementptr inbounds i32, ptr %1, i64 %76
  %78 = load <8 x i32>, ptr %77, align 4, !tbaa !5
  %79 = sext <8 x i32> %78 to <8 x i64>
  %80 = getelementptr inbounds float, ptr %0, <8 x i64> %79
  %81 = tail call <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr> %80, i32 4, <8 x i1> <i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true, i1 true>, <8 x float> undef), !tbaa !9
  %82 = getelementptr inbounds float, ptr %2, i64 %76
  store <8 x float> %81, ptr %82, align 4, !tbaa !9
  %83 = add nuw i64 %76, 8
  %84 = icmp eq i64 %83, %74
  br i1 %84, label %85, label %75, !llvm.loop !16

85:                                               ; preds = %75
  %86 = icmp eq i64 %74, %3
  br i1 %86, label %89, label %87

87:                                               ; preds = %6, %69, %85
  %88 = phi i64 [ 0, %6 ], [ %11, %69 ], [ %74, %85 ]
  br label %90

89:                                               ; preds = %90, %67, %85, %4
  ret void

90:                                               ; preds = %87, %90
  %91 = phi i64 [ %98, %90 ], [ %88, %87 ]
  %92 = getelementptr inbounds i32, ptr %1, i64 %91
  %93 = load i32, ptr %92, align 4, !tbaa !5
  %94 = sext i32 %93 to i64
  %95 = getelementptr inbounds float, ptr %0, i64 %94
  %96 = load float, ptr %95, align 4, !tbaa !9
  %97 = getelementptr inbounds float, ptr %2, i64 %91
  store float %96, ptr %97, align 4, !tbaa !9
  %98 = add nuw i64 %91, 1
  %99 = icmp eq i64 %98, %3
  br i1 %99, label %89, label %90, !llvm.loop !18
}

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <16 x float> @llvm.masked.gather.v16f32.v16p0(<16 x ptr>, i32 immarg, <16 x i1>, <16 x float>) #1

; Function Attrs: nocallback nofree nosync nounwind readonly willreturn
declare <8 x float> @llvm.masked.gather.v8f32.v8p0(<8 x ptr>, i32 immarg, <8 x i1>, <8 x float>) #1

attributes #0 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #1 = { nocallback nofree nosync nounwind readonly willreturn }

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
!14 = distinct !{!14, !15}
!15 = !{!"llvm.loop.unroll.disable"}
!16 = distinct !{!16, !12, !13, !17}
!17 = !{!"llvm.loop.unroll.runtime.disable"}
!18 = distinct !{!18, !12, !17, !13}
