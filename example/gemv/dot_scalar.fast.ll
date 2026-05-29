; ModuleID = 'dot_scalar.c'
source_filename = "dot_scalar.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree norecurse nosync nounwind readonly uwtable
define dso_local float @dot_scalar(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 !dbg !8 {
  %4 = icmp eq i64 %2, 0, !dbg !11
  br i1 %4, label %74, label %5, !dbg !12

5:                                                ; preds = %3
  %6 = icmp ult i64 %2, 8, !dbg !12
  br i1 %6, label %71, label %7, !dbg !12

7:                                                ; preds = %5
  %8 = icmp ult i64 %2, 64, !dbg !12
  br i1 %8, label %52, label %9, !dbg !12

9:                                                ; preds = %7
  %10 = and i64 %2, -64, !dbg !12
  br label %11, !dbg !12

11:                                               ; preds = %11, %9
  %12 = phi i64 [ 0, %9 ], [ %41, %11 ], !dbg !13
  %13 = phi <16 x float> [ zeroinitializer, %9 ], [ %37, %11 ]
  %14 = phi <16 x float> [ zeroinitializer, %9 ], [ %38, %11 ]
  %15 = phi <16 x float> [ zeroinitializer, %9 ], [ %39, %11 ]
  %16 = phi <16 x float> [ zeroinitializer, %9 ], [ %40, %11 ]
  %17 = getelementptr inbounds float, ptr %0, i64 %12, !dbg !14
  %18 = load <16 x float>, ptr %17, align 4, !dbg !14, !tbaa !15
  %19 = getelementptr inbounds float, ptr %17, i64 16, !dbg !14
  %20 = load <16 x float>, ptr %19, align 4, !dbg !14, !tbaa !15
  %21 = getelementptr inbounds float, ptr %17, i64 32, !dbg !14
  %22 = load <16 x float>, ptr %21, align 4, !dbg !14, !tbaa !15
  %23 = getelementptr inbounds float, ptr %17, i64 48, !dbg !14
  %24 = load <16 x float>, ptr %23, align 4, !dbg !14, !tbaa !15
  %25 = getelementptr inbounds float, ptr %1, i64 %12, !dbg !19
  %26 = load <16 x float>, ptr %25, align 4, !dbg !19, !tbaa !15
  %27 = getelementptr inbounds float, ptr %25, i64 16, !dbg !19
  %28 = load <16 x float>, ptr %27, align 4, !dbg !19, !tbaa !15
  %29 = getelementptr inbounds float, ptr %25, i64 32, !dbg !19
  %30 = load <16 x float>, ptr %29, align 4, !dbg !19, !tbaa !15
  %31 = getelementptr inbounds float, ptr %25, i64 48, !dbg !19
  %32 = load <16 x float>, ptr %31, align 4, !dbg !19, !tbaa !15
  %33 = fmul fast <16 x float> %26, %18, !dbg !20
  %34 = fmul fast <16 x float> %28, %20, !dbg !20
  %35 = fmul fast <16 x float> %30, %22, !dbg !20
  %36 = fmul fast <16 x float> %32, %24, !dbg !20
  %37 = fadd fast <16 x float> %33, %13, !dbg !21
  %38 = fadd fast <16 x float> %34, %14, !dbg !21
  %39 = fadd fast <16 x float> %35, %15, !dbg !21
  %40 = fadd fast <16 x float> %36, %16, !dbg !21
  %41 = add nuw i64 %12, 64, !dbg !13
  %42 = icmp eq i64 %41, %10, !dbg !13
  br i1 %42, label %43, label %11, !dbg !13, !llvm.loop !22

43:                                               ; preds = %11
  %44 = fadd fast <16 x float> %38, %37, !dbg !12
  %45 = fadd fast <16 x float> %39, %44, !dbg !12
  %46 = fadd fast <16 x float> %40, %45, !dbg !12
  %47 = tail call fast float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %46), !dbg !12
  %48 = icmp eq i64 %10, %2, !dbg !12
  br i1 %48, label %74, label %49, !dbg !12

49:                                               ; preds = %43
  %50 = and i64 %2, 56, !dbg !12
  %51 = icmp eq i64 %50, 0, !dbg !12
  br i1 %51, label %71, label %52, !dbg !12

52:                                               ; preds = %7, %49
  %53 = phi float [ 0.000000e+00, %7 ], [ %47, %49 ]
  %54 = phi i64 [ 0, %7 ], [ %10, %49 ]
  %55 = and i64 %2, -8, !dbg !12
  %56 = insertelement <8 x float> <float poison, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %53, i64 0, !dbg !12
  br label %57, !dbg !12

57:                                               ; preds = %57, %52
  %58 = phi i64 [ %54, %52 ], [ %66, %57 ], !dbg !13
  %59 = phi <8 x float> [ %56, %52 ], [ %65, %57 ]
  %60 = getelementptr inbounds float, ptr %0, i64 %58, !dbg !14
  %61 = load <8 x float>, ptr %60, align 4, !dbg !14, !tbaa !15
  %62 = getelementptr inbounds float, ptr %1, i64 %58, !dbg !19
  %63 = load <8 x float>, ptr %62, align 4, !dbg !19, !tbaa !15
  %64 = fmul fast <8 x float> %63, %61, !dbg !20
  %65 = fadd fast <8 x float> %64, %59, !dbg !21
  %66 = add nuw i64 %58, 8, !dbg !13
  %67 = icmp eq i64 %66, %55, !dbg !13
  br i1 %67, label %68, label %57, !dbg !13, !llvm.loop !26

68:                                               ; preds = %57
  %69 = tail call fast float @llvm.vector.reduce.fadd.v8f32(float -0.000000e+00, <8 x float> %65), !dbg !12
  %70 = icmp eq i64 %55, %2, !dbg !12
  br i1 %70, label %74, label %71, !dbg !12

71:                                               ; preds = %5, %49, %68
  %72 = phi i64 [ 0, %5 ], [ %10, %49 ], [ %55, %68 ]
  %73 = phi float [ 0.000000e+00, %5 ], [ %47, %49 ], [ %69, %68 ]
  br label %76, !dbg !12

74:                                               ; preds = %76, %43, %68, %3
  %75 = phi float [ 0.000000e+00, %3 ], [ %47, %43 ], [ %69, %68 ], [ %84, %76 ], !dbg !28
  ret float %75, !dbg !29

76:                                               ; preds = %71, %76
  %77 = phi i64 [ %85, %76 ], [ %72, %71 ]
  %78 = phi float [ %84, %76 ], [ %73, %71 ]
  %79 = getelementptr inbounds float, ptr %0, i64 %77, !dbg !14
  %80 = load float, ptr %79, align 4, !dbg !14, !tbaa !15
  %81 = getelementptr inbounds float, ptr %1, i64 %77, !dbg !19
  %82 = load float, ptr %81, align 4, !dbg !19, !tbaa !15
  %83 = fmul fast float %82, %80, !dbg !20
  %84 = fadd fast float %83, %78, !dbg !21
  %85 = add nuw i64 %77, 1, !dbg !13
  %86 = icmp eq i64 %85, %2, !dbg !11
  br i1 %86, label %74, label %76, !dbg !12, !llvm.loop !30
}

; Function Attrs: argmemonly nofree norecurse nosync nounwind uwtable
define dso_local void @gemv_scalar(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, ptr nocapture noundef writeonly %2, i64 noundef %3, i64 noundef %4) local_unnamed_addr #1 !dbg !31 {
  %6 = icmp eq i64 %3, 0, !dbg !32
  br i1 %6, label %20, label %7, !dbg !33

7:                                                ; preds = %5
  %8 = icmp eq i64 %4, 0
  br i1 %8, label %18, label %9, !dbg !34

9:                                                ; preds = %7
  %10 = icmp ult i64 %4, 8
  %11 = icmp ult i64 %4, 64
  %12 = and i64 %4, -64
  %13 = icmp eq i64 %12, %4
  %14 = and i64 %4, 56
  %15 = icmp eq i64 %14, 0
  %16 = and i64 %4, -8
  %17 = icmp eq i64 %16, %4
  br label %21, !dbg !33

18:                                               ; preds = %7
  %19 = shl nuw i64 %3, 2, !dbg !33
  tail call void @llvm.memset.p0.i64(ptr align 4 %2, i8 0, i64 %19, i1 false), !dbg !36, !tbaa !15
  br label %20, !dbg !37

20:                                               ; preds = %95, %18, %5
  ret void, !dbg !37

21:                                               ; preds = %9, %95
  %22 = phi i64 [ %98, %95 ], [ 0, %9 ]
  %23 = mul i64 %22, %4, !dbg !38
  %24 = getelementptr inbounds float, ptr %0, i64 %23, !dbg !39
  br i1 %10, label %81, label %25, !dbg !34

25:                                               ; preds = %21
  br i1 %11, label %64, label %26, !dbg !34

26:                                               ; preds = %25, %26
  %27 = phi i64 [ %56, %26 ], [ 0, %25 ], !dbg !40
  %28 = phi <16 x float> [ %52, %26 ], [ zeroinitializer, %25 ]
  %29 = phi <16 x float> [ %53, %26 ], [ zeroinitializer, %25 ]
  %30 = phi <16 x float> [ %54, %26 ], [ zeroinitializer, %25 ]
  %31 = phi <16 x float> [ %55, %26 ], [ zeroinitializer, %25 ]
  %32 = getelementptr inbounds float, ptr %24, i64 %27, !dbg !41
  %33 = load <16 x float>, ptr %32, align 4, !dbg !41, !tbaa !15
  %34 = getelementptr inbounds float, ptr %32, i64 16, !dbg !41
  %35 = load <16 x float>, ptr %34, align 4, !dbg !41, !tbaa !15
  %36 = getelementptr inbounds float, ptr %32, i64 32, !dbg !41
  %37 = load <16 x float>, ptr %36, align 4, !dbg !41, !tbaa !15
  %38 = getelementptr inbounds float, ptr %32, i64 48, !dbg !41
  %39 = load <16 x float>, ptr %38, align 4, !dbg !41, !tbaa !15
  %40 = getelementptr inbounds float, ptr %1, i64 %27, !dbg !42
  %41 = load <16 x float>, ptr %40, align 4, !dbg !42, !tbaa !15
  %42 = getelementptr inbounds float, ptr %40, i64 16, !dbg !42
  %43 = load <16 x float>, ptr %42, align 4, !dbg !42, !tbaa !15
  %44 = getelementptr inbounds float, ptr %40, i64 32, !dbg !42
  %45 = load <16 x float>, ptr %44, align 4, !dbg !42, !tbaa !15
  %46 = getelementptr inbounds float, ptr %40, i64 48, !dbg !42
  %47 = load <16 x float>, ptr %46, align 4, !dbg !42, !tbaa !15
  %48 = fmul fast <16 x float> %41, %33, !dbg !43
  %49 = fmul fast <16 x float> %43, %35, !dbg !43
  %50 = fmul fast <16 x float> %45, %37, !dbg !43
  %51 = fmul fast <16 x float> %47, %39, !dbg !43
  %52 = fadd fast <16 x float> %48, %28, !dbg !44
  %53 = fadd fast <16 x float> %49, %29, !dbg !44
  %54 = fadd fast <16 x float> %50, %30, !dbg !44
  %55 = fadd fast <16 x float> %51, %31, !dbg !44
  %56 = add nuw i64 %27, 64, !dbg !40
  %57 = icmp eq i64 %56, %12, !dbg !40
  br i1 %57, label %58, label %26, !dbg !40, !llvm.loop !45

58:                                               ; preds = %26
  %59 = fadd fast <16 x float> %53, %52, !dbg !34
  %60 = fadd fast <16 x float> %54, %59, !dbg !34
  %61 = fadd fast <16 x float> %55, %60, !dbg !34
  %62 = tail call fast float @llvm.vector.reduce.fadd.v16f32(float -0.000000e+00, <16 x float> %61), !dbg !34
  br i1 %13, label %95, label %63, !dbg !34

63:                                               ; preds = %58
  br i1 %15, label %81, label %64, !dbg !34

64:                                               ; preds = %25, %63
  %65 = phi float [ 0.000000e+00, %25 ], [ %62, %63 ]
  %66 = phi i64 [ 0, %25 ], [ %12, %63 ]
  %67 = insertelement <8 x float> <float poison, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00, float 0.000000e+00>, float %65, i64 0, !dbg !34
  br label %68, !dbg !34

68:                                               ; preds = %68, %64
  %69 = phi i64 [ %66, %64 ], [ %77, %68 ], !dbg !40
  %70 = phi <8 x float> [ %67, %64 ], [ %76, %68 ]
  %71 = getelementptr inbounds float, ptr %24, i64 %69, !dbg !41
  %72 = load <8 x float>, ptr %71, align 4, !dbg !41, !tbaa !15
  %73 = getelementptr inbounds float, ptr %1, i64 %69, !dbg !42
  %74 = load <8 x float>, ptr %73, align 4, !dbg !42, !tbaa !15
  %75 = fmul fast <8 x float> %74, %72, !dbg !43
  %76 = fadd fast <8 x float> %75, %70, !dbg !44
  %77 = add nuw i64 %69, 8, !dbg !40
  %78 = icmp eq i64 %77, %16, !dbg !40
  br i1 %78, label %79, label %68, !dbg !40, !llvm.loop !47

79:                                               ; preds = %68
  %80 = tail call fast float @llvm.vector.reduce.fadd.v8f32(float -0.000000e+00, <8 x float> %76), !dbg !34
  br i1 %17, label %95, label %81, !dbg !34

81:                                               ; preds = %21, %63, %79
  %82 = phi i64 [ 0, %21 ], [ %12, %63 ], [ %16, %79 ]
  %83 = phi float [ 0.000000e+00, %21 ], [ %62, %63 ], [ %80, %79 ]
  br label %84, !dbg !34

84:                                               ; preds = %81, %84
  %85 = phi i64 [ %93, %84 ], [ %82, %81 ]
  %86 = phi float [ %92, %84 ], [ %83, %81 ]
  %87 = getelementptr inbounds float, ptr %24, i64 %85, !dbg !41
  %88 = load float, ptr %87, align 4, !dbg !41, !tbaa !15
  %89 = getelementptr inbounds float, ptr %1, i64 %85, !dbg !42
  %90 = load float, ptr %89, align 4, !dbg !42, !tbaa !15
  %91 = fmul fast float %90, %88, !dbg !43
  %92 = fadd fast float %91, %86, !dbg !44
  %93 = add nuw i64 %85, 1, !dbg !40
  %94 = icmp eq i64 %93, %4, !dbg !48
  br i1 %94, label %95, label %84, !dbg !34, !llvm.loop !49

95:                                               ; preds = %84, %79, %58
  %96 = phi float [ %62, %58 ], [ %80, %79 ], [ %92, %84 ], !dbg !44
  %97 = getelementptr inbounds float, ptr %2, i64 %22, !dbg !50
  store float %96, ptr %97, align 4, !dbg !36, !tbaa !15
  %98 = add nuw i64 %22, 1, !dbg !51
  %99 = icmp eq i64 %98, %3, !dbg !32
  br i1 %99, label %20, label %21, !dbg !33, !llvm.loop !52
}

; Function Attrs: argmemonly nocallback nofree nounwind willreturn writeonly
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #2

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v16f32(float, <16 x float>) #3

; Function Attrs: nocallback nofree nosync nounwind readnone willreturn
declare float @llvm.vector.reduce.fadd.v8f32(float, <8 x float>) #3

attributes #0 = { argmemonly nofree norecurse nosync nounwind readonly uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly nofree norecurse nosync nounwind uwtable "approx-func-fp-math"="true" "denormal-fp-math"="preserve-sign,preserve-sign" "frame-pointer"="none" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" "unsafe-fp-math"="true" }
attributes #2 = { argmemonly nocallback nofree nounwind willreturn writeonly }
attributes #3 = { nocallback nofree nosync nounwind readnone willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 15.0.7", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "dot_scalar.c", directory: "/root/learn/example/gemv")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"PIC Level", i32 2}
!5 = !{i32 7, !"PIE Level", i32 2}
!6 = !{i32 7, !"uwtable", i32 2}
!7 = !{!"Ubuntu clang version 15.0.7"}
!8 = distinct !DISubprogram(name: "dot_scalar", scope: !1, file: !1, line: 12, type: !9, scopeLine: 13, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!9 = !DISubroutineType(types: !10)
!10 = !{}
!11 = !DILocation(line: 15, column: 26, scope: !8)
!12 = !DILocation(line: 15, column: 5, scope: !8)
!13 = !DILocation(line: 15, column: 32, scope: !8)
!14 = !DILocation(line: 16, column: 14, scope: !8)
!15 = !{!16, !16, i64 0}
!16 = !{!"float", !17, i64 0}
!17 = !{!"omnipotent char", !18, i64 0}
!18 = !{!"Simple C/C++ TBAA"}
!19 = !DILocation(line: 16, column: 21, scope: !8)
!20 = !DILocation(line: 16, column: 19, scope: !8)
!21 = !DILocation(line: 16, column: 11, scope: !8)
!22 = distinct !{!22, !12, !23, !24, !25}
!23 = !DILocation(line: 16, column: 24, scope: !8)
!24 = !{!"llvm.loop.mustprogress"}
!25 = !{!"llvm.loop.isvectorized", i32 1}
!26 = distinct !{!26, !12, !23, !24, !25, !27}
!27 = !{!"llvm.loop.unroll.runtime.disable"}
!28 = !DILocation(line: 0, scope: !8)
!29 = !DILocation(line: 17, column: 5, scope: !8)
!30 = distinct !{!30, !12, !23, !24, !27, !25}
!31 = distinct !DISubprogram(name: "gemv_scalar", scope: !1, file: !1, line: 20, type: !9, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!32 = !DILocation(line: 22, column: 26, scope: !31)
!33 = !DILocation(line: 22, column: 5, scope: !31)
!34 = !DILocation(line: 15, column: 5, scope: !8, inlinedAt: !35)
!35 = distinct !DILocation(line: 23, column: 16, scope: !31)
!36 = !DILocation(line: 23, column: 14, scope: !31)
!37 = !DILocation(line: 24, column: 1, scope: !31)
!38 = !DILocation(line: 23, column: 33, scope: !31)
!39 = !DILocation(line: 23, column: 29, scope: !31)
!40 = !DILocation(line: 15, column: 32, scope: !8, inlinedAt: !35)
!41 = !DILocation(line: 16, column: 14, scope: !8, inlinedAt: !35)
!42 = !DILocation(line: 16, column: 21, scope: !8, inlinedAt: !35)
!43 = !DILocation(line: 16, column: 19, scope: !8, inlinedAt: !35)
!44 = !DILocation(line: 16, column: 11, scope: !8, inlinedAt: !35)
!45 = distinct !{!45, !34, !46, !24, !25}
!46 = !DILocation(line: 16, column: 24, scope: !8, inlinedAt: !35)
!47 = distinct !{!47, !34, !46, !24, !25, !27}
!48 = !DILocation(line: 15, column: 26, scope: !8, inlinedAt: !35)
!49 = distinct !{!49, !34, !46, !24, !27, !25}
!50 = !DILocation(line: 23, column: 9, scope: !31)
!51 = !DILocation(line: 22, column: 32, scope: !31)
!52 = distinct !{!52, !33, !53, !24}
!53 = !DILocation(line: 23, column: 42, scope: !31)
