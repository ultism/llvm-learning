; ModuleID = 'dot_scalar.c'
source_filename = "dot_scalar.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: argmemonly nofree nosync nounwind readonly uwtable
define dso_local float @dot_scalar(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, i64 noundef %2) local_unnamed_addr #0 !dbg !8 {
  %4 = icmp eq i64 %2, 0, !dbg !11
  br i1 %4, label %28, label %5, !dbg !12

5:                                                ; preds = %3
  %6 = add i64 %2, -1, !dbg !12
  %7 = and i64 %2, 3, !dbg !12
  %8 = icmp ult i64 %6, 3, !dbg !12
  br i1 %8, label %11, label %9, !dbg !12

9:                                                ; preds = %5
  %10 = and i64 %2, -4, !dbg !12
  br label %30, !dbg !12

11:                                               ; preds = %30, %5
  %12 = phi float [ undef, %5 ], [ %56, %30 ]
  %13 = phi i64 [ 0, %5 ], [ %57, %30 ]
  %14 = phi float [ 0.000000e+00, %5 ], [ %56, %30 ]
  %15 = icmp eq i64 %7, 0, !dbg !12
  br i1 %15, label %28, label %16, !dbg !12

16:                                               ; preds = %11, %16
  %17 = phi i64 [ %25, %16 ], [ %13, %11 ]
  %18 = phi float [ %24, %16 ], [ %14, %11 ]
  %19 = phi i64 [ %26, %16 ], [ 0, %11 ]
  %20 = getelementptr inbounds float, ptr %0, i64 %17, !dbg !13
  %21 = load float, ptr %20, align 4, !dbg !13, !tbaa !14
  %22 = getelementptr inbounds float, ptr %1, i64 %17, !dbg !18
  %23 = load float, ptr %22, align 4, !dbg !18, !tbaa !14
  %24 = tail call float @llvm.fmuladd.f32(float %21, float %23, float %18), !dbg !19
  %25 = add nuw i64 %17, 1, !dbg !20
  %26 = add i64 %19, 1, !dbg !12
  %27 = icmp eq i64 %26, %7, !dbg !12
  br i1 %27, label %28, label %16, !dbg !12, !llvm.loop !21

28:                                               ; preds = %11, %16, %3
  %29 = phi float [ 0.000000e+00, %3 ], [ %12, %11 ], [ %24, %16 ], !dbg !23
  ret float %29, !dbg !24

30:                                               ; preds = %30, %9
  %31 = phi i64 [ 0, %9 ], [ %57, %30 ]
  %32 = phi float [ 0.000000e+00, %9 ], [ %56, %30 ]
  %33 = phi i64 [ 0, %9 ], [ %58, %30 ]
  %34 = getelementptr inbounds float, ptr %0, i64 %31, !dbg !13
  %35 = load float, ptr %34, align 4, !dbg !13, !tbaa !14
  %36 = getelementptr inbounds float, ptr %1, i64 %31, !dbg !18
  %37 = load float, ptr %36, align 4, !dbg !18, !tbaa !14
  %38 = tail call float @llvm.fmuladd.f32(float %35, float %37, float %32), !dbg !19
  %39 = or i64 %31, 1, !dbg !20
  %40 = getelementptr inbounds float, ptr %0, i64 %39, !dbg !13
  %41 = load float, ptr %40, align 4, !dbg !13, !tbaa !14
  %42 = getelementptr inbounds float, ptr %1, i64 %39, !dbg !18
  %43 = load float, ptr %42, align 4, !dbg !18, !tbaa !14
  %44 = tail call float @llvm.fmuladd.f32(float %41, float %43, float %38), !dbg !19
  %45 = or i64 %31, 2, !dbg !20
  %46 = getelementptr inbounds float, ptr %0, i64 %45, !dbg !13
  %47 = load float, ptr %46, align 4, !dbg !13, !tbaa !14
  %48 = getelementptr inbounds float, ptr %1, i64 %45, !dbg !18
  %49 = load float, ptr %48, align 4, !dbg !18, !tbaa !14
  %50 = tail call float @llvm.fmuladd.f32(float %47, float %49, float %44), !dbg !19
  %51 = or i64 %31, 3, !dbg !20
  %52 = getelementptr inbounds float, ptr %0, i64 %51, !dbg !13
  %53 = load float, ptr %52, align 4, !dbg !13, !tbaa !14
  %54 = getelementptr inbounds float, ptr %1, i64 %51, !dbg !18
  %55 = load float, ptr %54, align 4, !dbg !18, !tbaa !14
  %56 = tail call float @llvm.fmuladd.f32(float %53, float %55, float %50), !dbg !19
  %57 = add nuw i64 %31, 4, !dbg !20
  %58 = add i64 %33, 4, !dbg !12
  %59 = icmp eq i64 %58, %10, !dbg !12
  br i1 %59, label %11, label %30, !dbg !12, !llvm.loop !25
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind readnone speculatable willreturn
declare float @llvm.fmuladd.f32(float, float, float) #1

; Function Attrs: argmemonly nofree nosync nounwind uwtable
define dso_local void @gemv_scalar(ptr nocapture noundef readonly %0, ptr nocapture noundef readonly %1, ptr nocapture noundef writeonly %2, i64 noundef %3, i64 noundef %4) local_unnamed_addr #2 !dbg !28 {
  %6 = icmp eq i64 %3, 0, !dbg !29
  br i1 %6, label %17, label %7, !dbg !30

7:                                                ; preds = %5
  %8 = icmp eq i64 %4, 0
  br i1 %8, label %15, label %9, !dbg !31

9:                                                ; preds = %7
  %10 = add i64 %4, -1, !dbg !30
  %11 = and i64 %4, 3
  %12 = icmp ult i64 %10, 3
  %13 = and i64 %4, -4
  %14 = icmp eq i64 %11, 0
  br label %18, !dbg !30

15:                                               ; preds = %7
  %16 = shl nuw i64 %3, 2, !dbg !30
  tail call void @llvm.memset.p0.i64(ptr align 4 %2, i8 0, i64 %16, i1 false), !dbg !33, !tbaa !14
  br label %17, !dbg !34

17:                                               ; preds = %68, %15, %5
  ret void, !dbg !34

18:                                               ; preds = %9, %68
  %19 = phi i64 [ %71, %68 ], [ 0, %9 ]
  %20 = mul i64 %19, %4, !dbg !35
  %21 = getelementptr inbounds float, ptr %0, i64 %20, !dbg !36
  br i1 %12, label %52, label %22, !dbg !31

22:                                               ; preds = %18, %22
  %23 = phi i64 [ %49, %22 ], [ 0, %18 ]
  %24 = phi float [ %48, %22 ], [ 0.000000e+00, %18 ]
  %25 = phi i64 [ %50, %22 ], [ 0, %18 ]
  %26 = getelementptr inbounds float, ptr %21, i64 %23, !dbg !37
  %27 = load float, ptr %26, align 4, !dbg !37, !tbaa !14
  %28 = getelementptr inbounds float, ptr %1, i64 %23, !dbg !38
  %29 = load float, ptr %28, align 4, !dbg !38, !tbaa !14
  %30 = tail call float @llvm.fmuladd.f32(float %27, float %29, float %24), !dbg !39
  %31 = or i64 %23, 1, !dbg !40
  %32 = getelementptr inbounds float, ptr %21, i64 %31, !dbg !37
  %33 = load float, ptr %32, align 4, !dbg !37, !tbaa !14
  %34 = getelementptr inbounds float, ptr %1, i64 %31, !dbg !38
  %35 = load float, ptr %34, align 4, !dbg !38, !tbaa !14
  %36 = tail call float @llvm.fmuladd.f32(float %33, float %35, float %30), !dbg !39
  %37 = or i64 %23, 2, !dbg !40
  %38 = getelementptr inbounds float, ptr %21, i64 %37, !dbg !37
  %39 = load float, ptr %38, align 4, !dbg !37, !tbaa !14
  %40 = getelementptr inbounds float, ptr %1, i64 %37, !dbg !38
  %41 = load float, ptr %40, align 4, !dbg !38, !tbaa !14
  %42 = tail call float @llvm.fmuladd.f32(float %39, float %41, float %36), !dbg !39
  %43 = or i64 %23, 3, !dbg !40
  %44 = getelementptr inbounds float, ptr %21, i64 %43, !dbg !37
  %45 = load float, ptr %44, align 4, !dbg !37, !tbaa !14
  %46 = getelementptr inbounds float, ptr %1, i64 %43, !dbg !38
  %47 = load float, ptr %46, align 4, !dbg !38, !tbaa !14
  %48 = tail call float @llvm.fmuladd.f32(float %45, float %47, float %42), !dbg !39
  %49 = add nuw i64 %23, 4, !dbg !40
  %50 = add i64 %25, 4, !dbg !31
  %51 = icmp eq i64 %50, %13, !dbg !31
  br i1 %51, label %52, label %22, !dbg !31, !llvm.loop !41

52:                                               ; preds = %22, %18
  %53 = phi float [ undef, %18 ], [ %48, %22 ]
  %54 = phi i64 [ 0, %18 ], [ %49, %22 ]
  %55 = phi float [ 0.000000e+00, %18 ], [ %48, %22 ]
  br i1 %14, label %68, label %56, !dbg !31

56:                                               ; preds = %52, %56
  %57 = phi i64 [ %65, %56 ], [ %54, %52 ]
  %58 = phi float [ %64, %56 ], [ %55, %52 ]
  %59 = phi i64 [ %66, %56 ], [ 0, %52 ]
  %60 = getelementptr inbounds float, ptr %21, i64 %57, !dbg !37
  %61 = load float, ptr %60, align 4, !dbg !37, !tbaa !14
  %62 = getelementptr inbounds float, ptr %1, i64 %57, !dbg !38
  %63 = load float, ptr %62, align 4, !dbg !38, !tbaa !14
  %64 = tail call float @llvm.fmuladd.f32(float %61, float %63, float %58), !dbg !39
  %65 = add nuw i64 %57, 1, !dbg !40
  %66 = add i64 %59, 1, !dbg !31
  %67 = icmp eq i64 %66, %11, !dbg !31
  br i1 %67, label %68, label %56, !dbg !31, !llvm.loop !43

68:                                               ; preds = %56, %52
  %69 = phi float [ %53, %52 ], [ %64, %56 ], !dbg !39
  %70 = getelementptr inbounds float, ptr %2, i64 %19, !dbg !44
  store float %69, ptr %70, align 4, !dbg !33, !tbaa !14
  %71 = add nuw i64 %19, 1, !dbg !45
  %72 = icmp eq i64 %71, %3, !dbg !29
  br i1 %72, label %17, label %18, !dbg !30, !llvm.loop !46
}

; Function Attrs: argmemonly nocallback nofree nounwind willreturn writeonly
declare void @llvm.memset.p0.i64(ptr nocapture writeonly, i8, i64, i1 immarg) #3

attributes #0 = { argmemonly nofree nosync nounwind readonly uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #1 = { mustprogress nocallback nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { argmemonly nofree nosync nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "prefer-vector-width"="512" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #3 = { argmemonly nocallback nofree nounwind willreturn writeonly }

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
!13 = !DILocation(line: 16, column: 14, scope: !8)
!14 = !{!15, !15, i64 0}
!15 = !{!"float", !16, i64 0}
!16 = !{!"omnipotent char", !17, i64 0}
!17 = !{!"Simple C/C++ TBAA"}
!18 = !DILocation(line: 16, column: 21, scope: !8)
!19 = !DILocation(line: 16, column: 11, scope: !8)
!20 = !DILocation(line: 15, column: 32, scope: !8)
!21 = distinct !{!21, !22}
!22 = !{!"llvm.loop.unroll.disable"}
!23 = !DILocation(line: 0, scope: !8)
!24 = !DILocation(line: 17, column: 5, scope: !8)
!25 = distinct !{!25, !12, !26, !27}
!26 = !DILocation(line: 16, column: 24, scope: !8)
!27 = !{!"llvm.loop.mustprogress"}
!28 = distinct !DISubprogram(name: "gemv_scalar", scope: !1, file: !1, line: 20, type: !9, scopeLine: 21, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!29 = !DILocation(line: 22, column: 26, scope: !28)
!30 = !DILocation(line: 22, column: 5, scope: !28)
!31 = !DILocation(line: 15, column: 5, scope: !8, inlinedAt: !32)
!32 = distinct !DILocation(line: 23, column: 16, scope: !28)
!33 = !DILocation(line: 23, column: 14, scope: !28)
!34 = !DILocation(line: 24, column: 1, scope: !28)
!35 = !DILocation(line: 23, column: 33, scope: !28)
!36 = !DILocation(line: 23, column: 29, scope: !28)
!37 = !DILocation(line: 16, column: 14, scope: !8, inlinedAt: !32)
!38 = !DILocation(line: 16, column: 21, scope: !8, inlinedAt: !32)
!39 = !DILocation(line: 16, column: 11, scope: !8, inlinedAt: !32)
!40 = !DILocation(line: 15, column: 32, scope: !8, inlinedAt: !32)
!41 = distinct !{!41, !31, !42, !27}
!42 = !DILocation(line: 16, column: 24, scope: !8, inlinedAt: !32)
!43 = distinct !{!43, !22}
!44 = !DILocation(line: 23, column: 9, scope: !28)
!45 = !DILocation(line: 22, column: 32, scope: !28)
!46 = distinct !{!46, !30, !47, !27}
!47 = !DILocation(line: 23, column: 42, scope: !28)
