; ModuleID = 'vadd.cu'
source_filename = "vadd.cu"
target datalayout = "e-p6:32:32-i64:64-i128:128-i256:256-v16:16-v32:32-n16:32:64"
target triple = "nvptx64-nvidia-cuda"

%struct.__half = type { i16 }
%struct.__nv_bfloat16 = type { i16 }

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite)
define dso_local ptx_kernel void @_Z8vadd_f32PKfS0_Pfi(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1, ptr noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #0 {
  %5 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
  %6 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
  %7 = mul i32 %5, %6
  %8 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %9 = add i32 %7, %8
  %10 = icmp slt i32 %9, %3
  br i1 %10, label %11, label %19

11:                                               ; preds = %4
  %12 = sext i32 %9 to i64
  %13 = getelementptr inbounds float, ptr %2, i64 %12
  %14 = getelementptr inbounds float, ptr %1, i64 %12
  %15 = getelementptr inbounds float, ptr %0, i64 %12
  %16 = load float, ptr %15, align 4, !tbaa !11
  %17 = load float, ptr %14, align 4, !tbaa !11
  %18 = fadd contract float %16, %17
  store float %18, ptr %13, align 4, !tbaa !11
  br label %19

19:                                               ; preds = %11, %4
  ret void
}

; Function Attrs: convergent mustprogress noinline norecurse nounwind memory(argmem: readwrite)
define dso_local ptx_kernel void @_Z8vadd_f16PK6__halfS1_PS_i(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1, ptr noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #1 {
  %5 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
  %6 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
  %7 = mul i32 %5, %6
  %8 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %9 = add i32 %7, %8
  %10 = icmp slt i32 %9, %3
  br i1 %10, label %11, label %19

11:                                               ; preds = %4
  %12 = sext i32 %9 to i64
  %13 = getelementptr inbounds %struct.__half, ptr %0, i64 %12
  %14 = getelementptr inbounds %struct.__half, ptr %1, i64 %12
  %15 = load i16, ptr %13, align 2, !tbaa !13
  %16 = load i16, ptr %14, align 2, !tbaa !13
  %17 = tail call i16 asm "{add.f16 $0,$1,$2;\0A}", "=h,h,h"(i16 %15, i16 %16) #3, !srcloc !15
  %18 = getelementptr inbounds %struct.__half, ptr %2, i64 %12
  store i16 %17, ptr %18, align 2, !tbaa !13
  br label %19

19:                                               ; preds = %11, %4
  ret void
}

; Function Attrs: convergent mustprogress noinline norecurse nounwind memory(argmem: readwrite)
define dso_local ptx_kernel void @_Z9vadd_bf16PK13__nv_bfloat16S1_PS_i(ptr noundef readonly captures(none) %0, ptr noundef readonly captures(none) %1, ptr noundef writeonly captures(none) %2, i32 noundef %3) local_unnamed_addr #1 {
  %5 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ctaid.x()
  %6 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.ntid.x()
  %7 = mul i32 %5, %6
  %8 = tail call noundef i32 @llvm.nvvm.read.ptx.sreg.tid.x()
  %9 = add i32 %7, %8
  %10 = icmp slt i32 %9, %3
  br i1 %10, label %11, label %19

11:                                               ; preds = %4
  %12 = sext i32 %9 to i64
  %13 = getelementptr inbounds %struct.__nv_bfloat16, ptr %0, i64 %12
  %14 = getelementptr inbounds %struct.__nv_bfloat16, ptr %1, i64 %12
  %15 = load i16, ptr %13, align 2, !tbaa !13
  %16 = load i16, ptr %14, align 2, !tbaa !13
  %17 = tail call i16 asm "{ add.bf16 $0,$1,$2; }\0A", "=h,h,h"(i16 %15, i16 %16) #3, !srcloc !16
  %18 = getelementptr inbounds %struct.__nv_bfloat16, ptr %2, i64 %12
  store i16 %17, ptr %18, align 2, !tbaa !13
  br label %19

19:                                               ; preds = %11, %4
  ret void
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 2147483647) i32 @llvm.nvvm.read.ptx.sreg.ctaid.x() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 1, 1025) i32 @llvm.nvvm.read.ptx.sreg.ntid.x() #2

; Function Attrs: mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare noundef range(i32 0, 1024) i32 @llvm.nvvm.read.ptx.sreg.tid.x() #2

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(argmem: readwrite) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_90" "target-features"="+ptx88,+sm_90" "uniform-work-group-size"="true" }
attributes #1 = { convergent mustprogress noinline norecurse nounwind memory(argmem: readwrite) "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="sm_90" "target-features"="+ptx88,+sm_90" "uniform-work-group-size"="true" }
attributes #2 = { mustprogress nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { convergent nounwind memory(none) }

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
!11 = !{!12, !12, i64 0}
!12 = !{!"float", !8, i64 0}
!13 = !{!14, !14, i64 0}
!14 = !{!"short", !8, i64 0}
!15 = !{i64 2157586993, i64 2157587020}
!16 = !{i64 2160684969}
