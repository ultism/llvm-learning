	.text
	.intel_syntax noprefix
	.file	"csr_spmv.c"
	.globl	csr_spmv                        # -- Begin function csr_spmv
	.p2align	4, 0x90
	.type	csr_spmv,@function
csr_spmv:                               # @csr_spmv
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
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	test	r9d, r9d
	jle	.LBB0_11
# %bb.1:
	mov	r11, r8
	mov	ebx, r9d
	mov	r15d, dword ptr [rdx]
	lea	rax, [rdi + 192]
	mov	qword ptr [rsp - 24], rax       # 8-byte Spill
	lea	rax, [rsi + 192]
	mov	qword ptr [rsp - 32], rax       # 8-byte Spill
	xor	r8d, r8d
	vxorps	xmm0, xmm0, xmm0
	mov	qword ptr [rsp - 8], r11        # 8-byte Spill
	mov	qword ptr [rsp - 16], rdx       # 8-byte Spill
	mov	qword ptr [rsp - 40], rbx       # 8-byte Spill
	jmp	.LBB0_2
.LBB0_15:                               #   in Loop: Header=BB0_2 Depth=1
	mov	rbx, qword ptr [rsp - 40]       # 8-byte Reload
	.p2align	4, 0x90
.LBB0_10:                               #   in Loop: Header=BB0_2 Depth=1
	vmovss	dword ptr [r11 + 4*r14], xmm1
	cmp	r8, rbx
	je	.LBB0_11
.LBB0_2:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_13 Depth 2
                                        #     Child Loop BB0_8 Depth 2
                                        #     Child Loop BB0_18 Depth 2
	mov	r14, r8
	mov	eax, r15d
	inc	r8
	mov	r15d, dword ptr [rdx + 4*r14 + 4]
	vxorps	xmm1, xmm1, xmm1
	cmp	eax, r15d
	jge	.LBB0_10
# %bb.3:                                #   in Loop: Header=BB0_2 Depth=1
	movsxd	r12, r15d
	movsxd	r9, eax
	mov	r10, r12
	sub	r10, r9
	vxorps	xmm1, xmm1, xmm1
	cmp	r10, 8
	jae	.LBB0_5
# %bb.4:                                #   in Loop: Header=BB0_2 Depth=1
	mov	r13, r9
	jmp	.LBB0_18
	.p2align	4, 0x90
.LBB0_5:                                #   in Loop: Header=BB0_2 Depth=1
	cmp	r10, 64
	jae	.LBB0_12
# %bb.6:                                #   in Loop: Header=BB0_2 Depth=1
	vxorps	xmm1, xmm1, xmm1
	xor	ebp, ebp
	jmp	.LBB0_7
.LBB0_12:                               #   in Loop: Header=BB0_2 Depth=1
	mov	rbp, r10
	and	rbp, -64
	mov	rax, qword ptr [rsp - 24]       # 8-byte Reload
	lea	r13, [rax + 4*r9]
	mov	rax, qword ptr [rsp - 32]       # 8-byte Reload
	lea	rax, [rax + 4*r9]
	vxorps	xmm1, xmm1, xmm1
	xor	ebx, ebx
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	vxorps	xmm4, xmm4, xmm4
	.p2align	4, 0x90
.LBB0_13:                               #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovups	zmm5, zmmword ptr [rax + 4*rbx - 192]
	vmovups	zmm6, zmmword ptr [rax + 4*rbx - 128]
	vmovups	zmm7, zmmword ptr [rax + 4*rbx - 64]
	vmovups	zmm8, zmmword ptr [rax + 4*rbx]
	vxorps	xmm9, xmm9, xmm9
	kxnorw	k1, k0, k0
	vgatherdps	zmm9 {k1}, zmmword ptr [rcx + 4*zmm5]
	vxorps	xmm5, xmm5, xmm5
	kxnorw	k1, k0, k0
	vgatherdps	zmm5 {k1}, zmmword ptr [rcx + 4*zmm6]
	vxorps	xmm6, xmm6, xmm6
	kxnorw	k1, k0, k0
	vgatherdps	zmm6 {k1}, zmmword ptr [rcx + 4*zmm7]
	vxorps	xmm7, xmm7, xmm7
	kxnorw	k1, k0, k0
	vgatherdps	zmm7 {k1}, zmmword ptr [rcx + 4*zmm8]
	vfmadd231ps	zmm1, zmm9, zmmword ptr [r13 + 4*rbx - 192] # zmm1 = (zmm9 * mem) + zmm1
	vfmadd231ps	zmm2, zmm5, zmmword ptr [r13 + 4*rbx - 128] # zmm2 = (zmm5 * mem) + zmm2
	vfmadd231ps	zmm3, zmm6, zmmword ptr [r13 + 4*rbx - 64] # zmm3 = (zmm6 * mem) + zmm3
	vfmadd231ps	zmm4, zmm7, zmmword ptr [r13 + 4*rbx] # zmm4 = (zmm7 * mem) + zmm4
	add	rbx, 64
	cmp	rbp, rbx
	jne	.LBB0_13
# %bb.14:                               #   in Loop: Header=BB0_2 Depth=1
	vaddps	zmm1, zmm2, zmm1
	vaddps	zmm1, zmm3, zmm1
	vaddps	zmm1, zmm4, zmm1
	vextractf64x4	ymm2, zmm1, 1
	vaddps	zmm1, zmm1, zmm2
	vextractf128	xmm2, ymm1, 1
	vaddps	xmm1, xmm1, xmm2
	vpermilpd	xmm2, xmm1, 1           # xmm2 = xmm1[1,0]
	vaddps	xmm1, xmm1, xmm2
	vmovshdup	xmm2, xmm1              # xmm2 = xmm1[1,1,3,3]
	vaddss	xmm1, xmm1, xmm2
	cmp	r10, rbp
	je	.LBB0_15
# %bb.16:                               #   in Loop: Header=BB0_2 Depth=1
	test	r10b, 56
	je	.LBB0_17
.LBB0_7:                                #   in Loop: Header=BB0_2 Depth=1
	vblendps	xmm1, xmm0, xmm1, 1             # xmm1 = xmm1[0],xmm0[1,2,3]
	mov	r11, r10
	and	r11, -8
	lea	r13, [r11 + r9]
	lea	rbx, [rdi + 4*r9]
	lea	rax, [rsi + 4*r9]
	.p2align	4, 0x90
.LBB0_8:                                #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovups	ymm2, ymmword ptr [rax + 4*rbp]
	vxorps	xmm3, xmm3, xmm3
	kxnorw	k1, k0, k0
	vgatherdps	ymm3 {k1}, ymmword ptr [rcx + 4*ymm2]
	vfmadd231ps	ymm1, ymm3, ymmword ptr [rbx + 4*rbp] # ymm1 = (ymm3 * mem) + ymm1
	add	rbp, 8
	cmp	r11, rbp
	jne	.LBB0_8
# %bb.9:                                #   in Loop: Header=BB0_2 Depth=1
	vextractf128	xmm2, ymm1, 1
	vaddps	xmm1, xmm1, xmm2
	vpermilpd	xmm2, xmm1, 1           # xmm2 = xmm1[1,0]
	vaddps	xmm1, xmm1, xmm2
	vmovshdup	xmm2, xmm1              # xmm2 = xmm1[1,1,3,3]
	vaddss	xmm1, xmm1, xmm2
	cmp	r10, r11
	mov	r11, qword ptr [rsp - 8]        # 8-byte Reload
	mov	rdx, qword ptr [rsp - 16]       # 8-byte Reload
	mov	rbx, qword ptr [rsp - 40]       # 8-byte Reload
	jne	.LBB0_18
	jmp	.LBB0_10
.LBB0_17:                               #   in Loop: Header=BB0_2 Depth=1
	add	rbp, r9
	mov	r13, rbp
	mov	rbx, qword ptr [rsp - 40]       # 8-byte Reload
	.p2align	4, 0x90
.LBB0_18:                               #   Parent Loop BB0_2 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	movsxd	rax, dword ptr [rsi + 4*r13]
	vmovss	xmm2, dword ptr [rcx + 4*rax]   # xmm2 = mem[0],zero,zero,zero
	vfmadd231ss	xmm1, xmm2, dword ptr [rdi + 4*r13] # xmm1 = (xmm2 * mem) + xmm1
	inc	r13
	cmp	r12, r13
	jne	.LBB0_18
	jmp	.LBB0_10
.LBB0_11:
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
	.size	csr_spmv, .Lfunc_end0-csr_spmv
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
