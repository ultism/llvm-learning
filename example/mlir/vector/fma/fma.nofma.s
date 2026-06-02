	.att_syntax
	.file	"LLVMDialectModule"
	.text
	.globl	fused                           # -- Begin function fused
	.prefalign	4, .Lfunc_end0, nop
	.type	fused,@function
fused:                                  # @fused
	.cfi_startproc
# %bb.0:
	vmulps	%ymm2, %ymm0, %ymm0
	vmulps	%ymm3, %ymm1, %ymm1
	vaddps	%ymm4, %ymm0, %ymm0
	vaddps	%ymm5, %ymm1, %ymm1
	retq
.Lfunc_end0:
	.size	fused, .Lfunc_end0-fused
	.cfi_endproc
                                        # -- End function
	.globl	separate                        # -- Begin function separate
	.prefalign	4, .Lfunc_end1, nop
	.type	separate,@function
separate:                               # @separate
	.cfi_startproc
# %bb.0:
	vmulps	%ymm3, %ymm1, %ymm1
	vmulps	%ymm2, %ymm0, %ymm0
	vaddps	%ymm4, %ymm0, %ymm0
	vaddps	%ymm5, %ymm1, %ymm1
	retq
.Lfunc_end1:
	.size	separate, .Lfunc_end1-separate
	.cfi_endproc
                                        # -- End function
	.section	".note.GNU-stack","",@progbits
