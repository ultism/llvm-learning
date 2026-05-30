; ModuleID = 'vadd_tma.cu'
source_filename = "vadd_tma.cu"
target datalayout = "e-p6:32:32-i64:64-i128:128-i256:256-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%struct.__half2 = type { %struct.__half, %struct.__half }
%struct.__half = type { i16 }

@_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sa = internal addrspace(3) global [256 x %struct.__half2] undef, align 16
@_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sb = internal addrspace(3) global [256 x %struct.__half2] undef, align 16
@_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar = internal addrspace(3) global i64 undef, align 8

; Function Attrs: convergent mustprogress noinline norecurse nounwind
define dso_local ptx_kernel void @_Z11vadd_h2_tmaPK7__half2S1_PS_i(ptr noundef %0, ptr noundef %1, ptr noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
  %6 = shl i32 %5, 8
  %7 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %8 = icmp eq i32 %7, 0
  br i1 %8, label %9, label %10

9:                                                ; preds = %4
  tail call void asm sideeffect "mbarrier.init.shared.b64 [$0], $1;", "r,r,~{memory}"(i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar to i32), i32 1) #3, !srcloc !11
  tail call void asm sideeffect "fence.proxy.async.shared::cta; // 6.", "~{memory}"() #3, !srcloc !12
  br label %10

10:                                               ; preds = %9, %4
  tail call void @llvm.nvvm.barrier.cta.sync.aligned.all(i32 0)
  br i1 %8, label %11, label %20

11:                                               ; preds = %10
  %12 = sext i32 %6 to i64
  %13 = getelementptr inbounds %struct.__half2, ptr %1, i64 %12
  %14 = addrspacecast ptr %13 to ptr addrspace(1)
  %15 = ptrtoint ptr addrspace(1) %14 to i64
  %16 = getelementptr inbounds %struct.__half2, ptr %0, i64 %12
  %17 = addrspacecast ptr %16 to ptr addrspace(1)
  %18 = ptrtoint ptr addrspace(1) %17 to i64
  %19 = tail call noundef i64 asm "mbarrier.arrive.expect_tx.release.cta.shared::cta.b64 $0, [$1], $2; // 8. ", "=l,r,r,~{memory}"(i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar to i32), i32 2048) #3, !srcloc !13
  tail call void asm sideeffect "cp.async.bulk.shared::cluster.global.mbarrier::complete_tx::bytes [$0], [$1], $2, [$3]; // 1a. unicast", "r,l,r,r,~{memory}"(i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sa to i32), i64 %18, i32 1024, i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar to i32)) #3, !srcloc !14
  tail call void asm sideeffect "cp.async.bulk.shared::cluster.global.mbarrier::complete_tx::bytes [$0], [$1], $2, [$3]; // 1a. unicast", "r,l,r,r,~{memory}"(i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sb to i32), i64 %15, i32 1024, i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar to i32)) #3, !srcloc !14
  br label %20

20:                                               ; preds = %11, %10
  br label %21

21:                                               ; preds = %20, %21
  %22 = tail call i32 asm "{\0A\09 .reg .pred P_OUT; \0A\09mbarrier.try_wait.parity.shared::cta.b64  P_OUT, [$1], $2;                                // 7a. \0A\09selp.b32 $0, 1, 0, P_OUT; \0A}", "=r,r,r,~{memory}"(i32 ptrtoint (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE3bar to i32), i32 0) #3, !srcloc !15
  %23 = icmp eq i32 %22, 0
  br i1 %23, label %21, label %24, !llvm.loop !16

24:                                               ; preds = %21
  tail call void @llvm.nvvm.barrier.cta.sync.aligned.all(i32 0)
  %25 = icmp samesign ult i32 %7, 256
  br i1 %25, label %26, label %32

26:                                               ; preds = %24
  %27 = tail call i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
  br label %28

28:                                               ; preds = %26, %33
  %29 = phi i32 [ %7, %26 ], [ %42, %33 ]
  %30 = or disjoint i32 %29, %6
  %31 = icmp slt i32 %30, %3
  br i1 %31, label %33, label %32

32:                                               ; preds = %28, %33, %24
  ret void

33:                                               ; preds = %28
  %34 = zext nneg i32 %29 to i64
  %35 = getelementptr inbounds nuw %struct.__half2, ptr addrspacecast (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sa to ptr), i64 %34
  %36 = load i32, ptr %35, align 4, !tbaa !6
  %37 = getelementptr inbounds nuw %struct.__half2, ptr addrspacecast (ptr addrspace(3) @_ZZ11vadd_h2_tmaPK7__half2S1_PS_iE2sb to ptr), i64 %34
  %38 = load i32, ptr %37, align 4, !tbaa !6
  %39 = tail call i32 asm "{add.f16x2 $0,$1,$2;\0A}", "=r,r,r"(i32 %36, i32 %38) #4, !srcloc !18
  %40 = sext i32 %30 to i64
  %41 = getelementptr inbounds %struct.__half2, ptr %2, i64 %40
  store i32 %39, ptr %41, align 4, !tbaa !6
  %42 = add nuw nsw i32 %29, %27
  %43 = icmp samesign ult i32 %42, 256
  br i1 %43, label %28, label %32, !llvm.loop !19
}

; Function Attrs: convergent nocallback nounwind
declare void @llvm.nvvm.barrier.cta.sync.aligned.all(i32) #1

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 2147483647) i32 @llvm.nvvm.read.ptx.sreg.ctaid.x() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.nvvm.read.ptx.sreg.tid.x() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 1, 1025) i32 @llvm.nvvm.read.ptx.sreg.ntid.x() #2

attributes #0 = { convergent mustprogress noinline norecurse nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_120" "target-features"="+ptx88,+sm_120" "uniform-work-group-size"="true" }
attributes #1 = { convergent nocallback nounwind }
attributes #2 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { convergent nounwind }
attributes #4 = { convergent nounwind memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3}
!llvm.ident = !{!4, !5}
!llvm.errno.tbaa = !{!6}
!nvvmir.version = !{!10}

!0 = !{i32 2, !"SDK Version", [2 x i32] [i32 12, i32 9]}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 4, !"nvvm-reflect-ftz", i32 0}
!3 = !{i32 7, !"frame-pointer", i32 2}
!4 = !{!"Ubuntu clang version 22.1.7 (++20260522062649+81c69e140401-1~exp1~20260522182710.78)"}
!5 = !{!"clang version 3.8.0 (tags/RELEASE_380/final)"}
!6 = !{!7, !7, i64 0}
!7 = !{!"int", !8, i64 0}
!8 = !{!"omnipotent char", !9, i64 0}
!9 = !{!"Simple C++ TBAA"}
!10 = !{i32 2, i32 0}
!11 = !{i64 2163901232}
!12 = !{i64 2163310980}
!13 = !{i64 2163880493}
!14 = !{i64 2161766756}
!15 = !{i64 2164165778, i64 2164165782, i64 2164165805, i64 2164165918, i64 2164165963}
!16 = distinct !{!16, !17}
!17 = !{!"llvm.loop.mustprogress"}
!18 = !{i64 2157450189, i64 2157450218}
!19 = distinct !{!19, !17}
