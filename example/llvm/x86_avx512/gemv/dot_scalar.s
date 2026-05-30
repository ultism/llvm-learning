	.text
	.intel_syntax noprefix
	.file	"dot_scalar.c"
	.globl	dot_scalar                      # -- Begin function dot_scalar
	.p2align	4, 0x90
	.type	dot_scalar,@function
dot_scalar:                             # @dot_scalar
	.cfi_startproc
# %bb.0:
	test	rdx, rdx
	je	.LBB0_1
# %bb.2:
	lea	rcx, [rdx - 1]
	mov	eax, edx
	and	eax, 3
	cmp	rcx, 3
	jae	.LBB0_8
# %bb.3:
	vxorps	xmm0, xmm0, xmm0
	xor	ecx, ecx
	jmp	.LBB0_4
.LBB0_1:
	vxorps	xmm0, xmm0, xmm0
	ret
.LBB0_8:
	and	rdx, -4
	vxorps	xmm0, xmm0, xmm0
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB0_9:                                # =>This Inner Loop Header: Depth=1
	vmovss	xmm1, dword ptr [rdi + 4*rcx]   # xmm1 = mem[0],zero,zero,zero
	vmovss	xmm2, dword ptr [rdi + 4*rcx + 4] # xmm2 = mem[0],zero,zero,zero
	vfmadd132ss	xmm1, xmm0, dword ptr [rsi + 4*rcx] # xmm1 = (xmm1 * mem) + xmm0
	vfmadd231ss	xmm1, xmm2, dword ptr [rsi + 4*rcx + 4] # xmm1 = (xmm2 * mem) + xmm1
	vmovss	xmm2, dword ptr [rdi + 4*rcx + 8] # xmm2 = mem[0],zero,zero,zero
	vfmadd132ss	xmm2, xmm1, dword ptr [rsi + 4*rcx + 8] # xmm2 = (xmm2 * mem) + xmm1
	vmovss	xmm0, dword ptr [rdi + 4*rcx + 12] # xmm0 = mem[0],zero,zero,zero
	vfmadd132ss	xmm0, xmm2, dword ptr [rsi + 4*rcx + 12] # xmm0 = (xmm0 * mem) + xmm2
	add	rcx, 4
	cmp	rdx, rcx
	jne	.LBB0_9
.LBB0_4:
	test	rax, rax
	je	.LBB0_7
# %bb.5:
	lea	rdx, [rsi + 4*rcx]
	lea	rcx, [rdi + 4*rcx]
	xor	esi, esi
	.p2align	4, 0x90
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovss	xmm1, dword ptr [rcx + 4*rsi]   # xmm1 = mem[0],zero,zero,zero
	vfmadd231ss	xmm0, xmm1, dword ptr [rdx + 4*rsi] # xmm0 = (xmm1 * mem) + xmm0
	inc	rsi
	cmp	rax, rsi
	jne	.LBB0_6
.LBB0_7:
	ret
.Lfunc_end0:
	.size	dot_scalar, .Lfunc_end0-dot_scalar
	.cfi_endproc
                                        # -- End function
	.globl	gemv_scalar                     # -- Begin function gemv_scalar
	.p2align	4, 0x90
	.type	gemv_scalar,@function
gemv_scalar:                            # @gemv_scalar
	.cfi_startproc
# %bb.0:
	push	r15
	.cfi_def_cfa_offset 16
	push	r14
	.cfi_def_cfa_offset 24
	push	r12
	.cfi_def_cfa_offset 32
	push	rbx
	.cfi_def_cfa_offset 40
	.cfi_offset rbx, -40
	.cfi_offset r12, -32
	.cfi_offset r14, -24
	.cfi_offset r15, -16
	test	rcx, rcx
	je	.LBB1_9
# %bb.1:
	test	r8, r8
	je	.LBB1_10
# %bb.2:
	lea	r9, [r8 - 1]
	mov	r11d, r8d
	and	r11d, 3
	mov	r10, r8
	and	r10, -4
	lea	rax, [rdi + 12]
	shl	r8, 2
	xor	r14d, r14d
	jmp	.LBB1_3
	.p2align	4, 0x90
.LBB1_8:                                #   in Loop: Header=BB1_3 Depth=1
	vmovss	dword ptr [rdx + 4*r14], xmm0
	inc	r14
	add	rax, r8
	add	rdi, r8
	cmp	r14, rcx
	je	.LBB1_9
.LBB1_3:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_4 Depth 2
                                        #     Child Loop BB1_7 Depth 2
	vxorps	xmm0, xmm0, xmm0
	xor	ebx, ebx
	cmp	r9, 3
	jb	.LBB1_5
	.p2align	4, 0x90
.LBB1_4:                                #   Parent Loop BB1_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovss	xmm1, dword ptr [rax + 4*rbx - 12] # xmm1 = mem[0],zero,zero,zero
	vmovss	xmm2, dword ptr [rax + 4*rbx - 8] # xmm2 = mem[0],zero,zero,zero
	vfmadd132ss	xmm1, xmm0, dword ptr [rsi + 4*rbx] # xmm1 = (xmm1 * mem) + xmm0
	vfmadd231ss	xmm1, xmm2, dword ptr [rsi + 4*rbx + 4] # xmm1 = (xmm2 * mem) + xmm1
	vmovss	xmm2, dword ptr [rax + 4*rbx - 4] # xmm2 = mem[0],zero,zero,zero
	vfmadd132ss	xmm2, xmm1, dword ptr [rsi + 4*rbx + 8] # xmm2 = (xmm2 * mem) + xmm1
	vmovss	xmm0, dword ptr [rax + 4*rbx]   # xmm0 = mem[0],zero,zero,zero
	vfmadd132ss	xmm0, xmm2, dword ptr [rsi + 4*rbx + 12] # xmm0 = (xmm0 * mem) + xmm2
	add	rbx, 4
	cmp	r10, rbx
	jne	.LBB1_4
.LBB1_5:                                #   in Loop: Header=BB1_3 Depth=1
	test	r11, r11
	je	.LBB1_8
# %bb.6:                                #   in Loop: Header=BB1_3 Depth=1
	lea	r15, [rsi + 4*rbx]
	lea	r12, [rdi + 4*rbx]
	xor	ebx, ebx
	.p2align	4, 0x90
.LBB1_7:                                #   Parent Loop BB1_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovss	xmm1, dword ptr [r12 + 4*rbx]   # xmm1 = mem[0],zero,zero,zero
	vfmadd231ss	xmm0, xmm1, dword ptr [r15 + 4*rbx] # xmm0 = (xmm1 * mem) + xmm0
	inc	rbx
	cmp	r11, rbx
	jne	.LBB1_7
	jmp	.LBB1_8
.LBB1_9:
	pop	rbx
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	ret
.LBB1_10:
	.cfi_def_cfa_offset 40
	shl	rcx, 2
	mov	rdi, rdx
	xor	esi, esi
	mov	rdx, rcx
	pop	rbx
	.cfi_def_cfa_offset 32
	pop	r12
	.cfi_def_cfa_offset 24
	pop	r14
	.cfi_def_cfa_offset 16
	pop	r15
	.cfi_def_cfa_offset 8
	jmp	memset@PLT                      # TAILCALL
.Lfunc_end1:
	.size	gemv_scalar, .Lfunc_end1-gemv_scalar
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
