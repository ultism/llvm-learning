; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

define <16 x float> @fused(<16 x float> %0, <16 x float> %1, <16 x float> %2) {
  %4 = call <16 x float> @llvm.fmuladd.v16f32(<16 x float> %0, <16 x float> %1, <16 x float> %2)
  ret <16 x float> %4
}

define <16 x float> @separate(<16 x float> %0, <16 x float> %1, <16 x float> %2) {
  %4 = fmul <16 x float> %0, %1
  %5 = fadd <16 x float> %4, %2
  ret <16 x float> %5
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x float> @llvm.fmuladd.v16f32(<16 x float>, <16 x float>, <16 x float>) #0

attributes #0 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
