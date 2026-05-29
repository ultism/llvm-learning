; ModuleID = 'gelu_scalar.c'
source_filename = "gelu_scalar.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

; Function Attrs: nounwind uwtable
define dso_local float @gelu_scalar(float noundef %0) local_unnamed_addr #0 !dbg !8 {
  %2 = fmul float %0, 5.000000e-01, !dbg !11
  %3 = fmul float %0, 0x3FE6A09E60000000, !dbg !12
  %4 = tail call float @erff(float noundef %3) #2, !dbg !13
  %5 = fadd float %4, 1.000000e+00, !dbg !14
  %6 = fmul float %2, %5, !dbg !15
  ret float %6, !dbg !16
}

; Function Attrs: nounwind
declare float @erff(float noundef) local_unnamed_addr #1

; Function Attrs: nounwind uwtable
define dso_local void @gelu_scalar_array(ptr nocapture noundef readonly %0, ptr nocapture noundef writeonly %1, i64 noundef %2) local_unnamed_addr #0 !dbg !17 {
  %4 = icmp eq i64 %2, 0, !dbg !18
  br i1 %4, label %5, label %6, !dbg !19

5:                                                ; preds = %6, %3
  ret void, !dbg !20

6:                                                ; preds = %3, %6
  %7 = phi i64 [ %16, %6 ], [ 0, %3 ]
  %8 = getelementptr inbounds float, ptr %0, i64 %7, !dbg !21
  %9 = load float, ptr %8, align 4, !dbg !21, !tbaa !22
  %10 = fmul float %9, 5.000000e-01, !dbg !26
  %11 = fmul float %9, 0x3FE6A09E60000000, !dbg !28
  %12 = tail call float @erff(float noundef %11) #2, !dbg !29
  %13 = fadd float %12, 1.000000e+00, !dbg !30
  %14 = fmul float %10, %13, !dbg !31
  %15 = getelementptr inbounds float, ptr %1, i64 %7, !dbg !32
  store float %14, ptr %15, align 4, !dbg !33, !tbaa !22
  %16 = add nuw i64 %7, 1, !dbg !34
  %17 = icmp eq i64 %16, %2, !dbg !18
  br i1 %17, label %5, label %6, !dbg !19, !llvm.loop !35
}

attributes #0 = { nounwind uwtable "frame-pointer"="none" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #1 = { nounwind "frame-pointer"="none" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+64bit,+adx,+aes,+avx,+avx2,+avx512bf16,+avx512bitalg,+avx512bw,+avx512cd,+avx512dq,+avx512f,+avx512ifma,+avx512vbmi,+avx512vbmi2,+avx512vl,+avx512vnni,+avx512vp2intersect,+avx512vpopcntdq,+avxvnni,+bmi,+bmi2,+clflushopt,+clwb,+clzero,+cmov,+crc32,+cx16,+cx8,+f16c,+fma,+fsgsbase,+fxsr,+gfni,+invpcid,+lzcnt,+mmx,+movbe,+pclmul,+popcnt,+prfchw,+rdpid,+rdrnd,+rdseed,+sahf,+sha,+shstk,+sse,+sse2,+sse3,+sse4.1,+sse4.2,+sse4a,+ssse3,+vaes,+vpclmulqdq,+x87,+xsave,+xsavec,+xsaveopt,+xsaves,-amx-bf16,-amx-int8,-amx-tile,-avx512er,-avx512fp16,-avx512pf,-cldemote,-enqcmd,-fma4,-hreset,-kl,-lwp,-movdir64b,-movdiri,-mwaitx,-pconfig,-pku,-prefetchwt1,-ptwrite,-rdpru,-rtm,-serialize,-sgx,-tbm,-tsxldtrk,-uintr,-waitpkg,-wbnoinvd,-widekl,-xop" }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 15.0.7", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "gelu_scalar.c", directory: "/root/learn/example/gelu")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{i32 7, !"PIC Level", i32 2}
!5 = !{i32 7, !"PIE Level", i32 2}
!6 = !{i32 7, !"uwtable", i32 2}
!7 = !{!"Ubuntu clang version 15.0.7"}
!8 = distinct !DISubprogram(name: "gelu_scalar", scope: !1, file: !1, line: 16, type: !9, scopeLine: 17, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!9 = !DISubroutineType(types: !10)
!10 = !{}
!11 = !DILocation(line: 18, column: 17, scope: !8)
!12 = !DILocation(line: 18, column: 38, scope: !8)
!13 = !DILocation(line: 18, column: 31, scope: !8)
!14 = !DILocation(line: 18, column: 29, scope: !8)
!15 = !DILocation(line: 18, column: 21, scope: !8)
!16 = !DILocation(line: 18, column: 5, scope: !8)
!17 = distinct !DISubprogram(name: "gelu_scalar_array", scope: !1, file: !1, line: 21, type: !9, scopeLine: 22, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !10)
!18 = !DILocation(line: 23, column: 26, scope: !17)
!19 = !DILocation(line: 23, column: 5, scope: !17)
!20 = !DILocation(line: 25, column: 1, scope: !17)
!21 = !DILocation(line: 24, column: 30, scope: !17)
!22 = !{!23, !23, i64 0}
!23 = !{!"float", !24, i64 0}
!24 = !{!"omnipotent char", !25, i64 0}
!25 = !{!"Simple C/C++ TBAA"}
!26 = !DILocation(line: 18, column: 17, scope: !8, inlinedAt: !27)
!27 = distinct !DILocation(line: 24, column: 18, scope: !17)
!28 = !DILocation(line: 18, column: 38, scope: !8, inlinedAt: !27)
!29 = !DILocation(line: 18, column: 31, scope: !8, inlinedAt: !27)
!30 = !DILocation(line: 18, column: 29, scope: !8, inlinedAt: !27)
!31 = !DILocation(line: 18, column: 21, scope: !8, inlinedAt: !27)
!32 = !DILocation(line: 24, column: 9, scope: !17)
!33 = !DILocation(line: 24, column: 16, scope: !17)
!34 = !DILocation(line: 23, column: 31, scope: !17)
!35 = distinct !{!35, !19, !36, !37}
!36 = !DILocation(line: 24, column: 35, scope: !17)
!37 = !{!"llvm.loop.mustprogress"}
