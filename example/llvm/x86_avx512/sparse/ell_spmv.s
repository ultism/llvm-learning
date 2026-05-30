	.text
	.intel_syntax noprefix
	.file	"ell_spmv.c"
	.globl	ell_spmv                        # -- Begin function ell_spmv
	.p2align	4, 0x90
	.type	ell_spmv,@function
ell_spmv:                               # @ell_spmv
	.cfi_startproc
# %bb.0:
	push	rbp
	.cfi_def_cfa_offset 16
	push	r15
	.cfi_def_cfa_offset 24
	push	r14
	.cfi_def_cfa_offset 32
	push	r13
	.cfi_def_cfa_offset 40
	push	r12
	.cfi_def_cfa_offset 48
	push	rbx
	.cfi_def_cfa_offset 56
	sub	rsp, 72
	.cfi_def_cfa_offset 128
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp + 16], rsi       # 8-byte Spill
	mov	qword ptr [rsp + 8], rdi        # 8-byte Spill
	test	edx, edx
	jle	.LBB0_19
# %bb.1:
	mov	rbx, r9
	mov	r14, r8
	mov	r13d, ecx
	mov	eax, edx
	mov	r15d, edx
	lea	rdx, [4*r15]
	mov	rdi, r9
	xor	esi, esi
	mov	dword ptr [rsp + 4], eax        # 4-byte Spill
	call	memset@PLT
	mov	ebp, dword ptr [rsp + 4]        # 4-byte Reload
	test	r13d, r13d
	jle	.LBB0_19
# %bb.2:
	movsxd	rax, ebp
	mov	r10d, r13d
	mov	ecx, r15d
	and	ecx, -16
	mov	qword ptr [rsp + 24], rcx       # 8-byte Spill
	add	rcx, -16
	mov	qword ptr [rsp + 56], rcx       # 8-byte Spill
	mov	rdx, rcx
	shr	rdx, 4
	inc	rdx
	mov	rcx, rdx
	mov	qword ptr [rsp + 48], rdx       # 8-byte Spill
	and	rdx, -2
	mov	qword ptr [rsp + 40], rdx       # 8-byte Spill
	mov	r13d, r15d
	and	r13d, -8
	mov	r9, qword ptr [rsp + 16]        # 8-byte Reload
	lea	rsi, [r9 + 64]
	mov	qword ptr [rsp + 32], rax       # 8-byte Spill
	lea	rdi, [4*rax]
	mov	r12, qword ptr [rsp + 8]        # 8-byte Reload
	lea	rdx, [r12 + 64]
	xor	r8d, r8d
	mov	qword ptr [rsp + 64], r10       # 8-byte Spill
	jmp	.LBB0_3
	.p2align	4, 0x90
.LBB0_18:                               #   in Loop: Header=BB0_3 Depth=1
	inc	r8
	add	rsi, rdi
	add	rdx, rdi
	add	r9, rdi
	add	r12, rdi
	cmp	r8, r10
	je	.LBB0_19
.LBB0_3:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_10 Depth 2
                                        #     Child Loop BB0_15 Depth 2
                                        #     Child Loop BB0_17 Depth 2
	cmp	ebp, 8
	jae	.LBB0_5
# %bb.4:                                #   in Loop: Header=BB0_3 Depth=1
	xor	eax, eax
	jmp	.LBB0_17
	.p2align	4, 0x90
.LBB0_5:                                #   in Loop: Header=BB0_3 Depth=1
	cmp	ebp, 16
	jae	.LBB0_7
# %bb.6:                                #   in Loop: Header=BB0_3 Depth=1
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB0_15:                               #   Parent Loop BB0_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovups	ymm0, ymmword ptr [r12 + 4*rcx]
	vmovups	ymm1, ymmword ptr [r9 + 4*rcx]
	kxnorw	k1, k0, k0
	vxorps	xmm2, xmm2, xmm2
	vgatherdps	ymm2 {k1}, ymmword ptr [r14 + 4*ymm1]
	vfmadd213ps	ymm2, ymm0, ymmword ptr [rbx + 4*rcx] # ymm2 = (ymm0 * ymm2) + mem
	vmovups	ymmword ptr [rbx + 4*rcx], ymm2
	add	rcx, 8
	cmp	r13, rcx
	jne	.LBB0_15
# %bb.16:                               #   in Loop: Header=BB0_3 Depth=1
	mov	rax, r13
	cmp	r13, r15
	jne	.LBB0_17
	jmp	.LBB0_18
	.p2align	4, 0x90
.LBB0_7:                                #   in Loop: Header=BB0_3 Depth=1
	cmp	qword ptr [rsp + 56], 0         # 8-byte Folded Reload
	je	.LBB0_8
# %bb.9:                                #   in Loop: Header=BB0_3 Depth=1
	mov	r11, qword ptr [rsp + 40]       # 8-byte Reload
	xor	r10d, r10d
	.p2align	4, 0x90
.LBB0_10:                               #   Parent Loop BB0_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovups	zmm0, zmmword ptr [rdx + 4*r10 - 64]
	vmovups	zmm1, zmmword ptr [rsi + 4*r10 - 64]
	kxnorw	k1, k0, k0
	vxorps	xmm2, xmm2, xmm2
	vgatherdps	zmm2 {k1}, zmmword ptr [r14 + 4*zmm1]
	vfmadd213ps	zmm2, zmm0, zmmword ptr [rbx + 4*r10] # zmm2 = (zmm0 * zmm2) + mem
	vmovups	zmmword ptr [rbx + 4*r10], zmm2
	vmovups	zmm0, zmmword ptr [rdx + 4*r10]
	vmovups	zmm1, zmmword ptr [rsi + 4*r10]
	kxnorw	k1, k0, k0
	vxorps	xmm2, xmm2, xmm2
	vgatherdps	zmm2 {k1}, zmmword ptr [r14 + 4*zmm1]
	vfmadd213ps	zmm2, zmm0, zmmword ptr [rbx + 4*r10 + 64] # zmm2 = (zmm0 * zmm2) + mem
	vmovups	zmmword ptr [rbx + 4*r10 + 64], zmm2
	add	r10, 32
	add	r11, -2
	jne	.LBB0_10
# %bb.11:                               #   in Loop: Header=BB0_3 Depth=1
	test	byte ptr [rsp + 48], 1          # 1-byte Folded Reload
	je	.LBB0_13
.LBB0_12:                               #   in Loop: Header=BB0_3 Depth=1
	mov	rax, r8
	imul	rax, qword ptr [rsp + 32]       # 8-byte Folded Reload
	add	rax, r10
	mov	rcx, qword ptr [rsp + 8]        # 8-byte Reload
	vmovups	zmm0, zmmword ptr [rcx + 4*rax]
	mov	rcx, qword ptr [rsp + 16]       # 8-byte Reload
	vmovups	zmm1, zmmword ptr [rcx + 4*rax]
	kxnorw	k1, k0, k0
	vxorps	xmm2, xmm2, xmm2
	vgatherdps	zmm2 {k1}, zmmword ptr [r14 + 4*zmm1]
	vfmadd213ps	zmm2, zmm0, zmmword ptr [rbx + 4*r10] # zmm2 = (zmm0 * zmm2) + mem
	vmovups	zmmword ptr [rbx + 4*r10], zmm2
.LBB0_13:                               #   in Loop: Header=BB0_3 Depth=1
	cmp	qword ptr [rsp + 24], r15       # 8-byte Folded Reload
	mov	r10, qword ptr [rsp + 64]       # 8-byte Reload
	mov	ebp, dword ptr [rsp + 4]        # 4-byte Reload
	je	.LBB0_18
# %bb.14:                               #   in Loop: Header=BB0_3 Depth=1
	mov	rax, qword ptr [rsp + 24]       # 8-byte Reload
	mov	rcx, rax
	test	r15b, 8
	jne	.LBB0_15
	.p2align	4, 0x90
.LBB0_17:                               #   Parent Loop BB0_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovss	xmm0, dword ptr [r12 + 4*rax]   # xmm0 = mem[0],zero,zero,zero
	movsxd	rcx, dword ptr [r9 + 4*rax]
	vmovss	xmm1, dword ptr [r14 + 4*rcx]   # xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	xmm1, xmm0, dword ptr [rbx + 4*rax] # xmm1 = (xmm0 * xmm1) + mem
	vmovss	dword ptr [rbx + 4*rax], xmm1
	inc	rax
	cmp	r15, rax
	jne	.LBB0_17
	jmp	.LBB0_18
.LBB0_8:                                #   in Loop: Header=BB0_3 Depth=1
	xor	r10d, r10d
	test	byte ptr [rsp + 48], 1          # 1-byte Folded Reload
	jne	.LBB0_12
	jmp	.LBB0_13
.LBB0_19:
	add	rsp, 72
	.cfi_def_cfa_offset 56
	pop	rbx
	.cfi_def_cfa_offset 48
	pop	r12
	.cfi_def_cfa_offset 40
	pop	r13
	.cfi_def_cfa_offset 32
	pop	r14
	.cfi_def_cfa_offset 24
	pop	r15
	.cfi_def_cfa_offset 16
	pop	rbp
	.cfi_def_cfa_offset 8
	vzeroupper
	ret
.Lfunc_end0:
	.size	ell_spmv, .Lfunc_end0-ell_spmv
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
