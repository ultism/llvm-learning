	.text
	.intel_syntax noprefix
	.file	"dot_avx512.c"
	.globl	dot_avx512                      # -- Begin function dot_avx512
	.p2align	4, 0x90
	.type	dot_avx512,@function
dot_avx512:                             # @dot_avx512
	.cfi_startproc
# %bb.0:
	vxorps	xmm0, xmm0, xmm0
	xor	eax, eax
	cmp	rdx, 64
	jb	.LBB0_4
# %bb.1:
	vxorps	xmm1, xmm1, xmm1
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	.p2align	4, 0x90
.LBB0_2:                                # =>This Inner Loop Header: Depth=1
	mov	rcx, rax
	vmovups	zmm4, zmmword ptr [rdi + 4*rax]
	vmovups	zmm5, zmmword ptr [rdi + 4*rax + 64]
	vmovups	zmm6, zmmword ptr [rdi + 4*rax + 128]
	vmovups	zmm7, zmmword ptr [rdi + 4*rax + 192]
	vfmadd231ps	zmm0, zmm4, zmmword ptr [rsi + 4*rax] # zmm0 = (zmm4 * mem) + zmm0
	vfmadd231ps	zmm1, zmm5, zmmword ptr [rsi + 4*rax + 64] # zmm1 = (zmm5 * mem) + zmm1
	vfmadd231ps	zmm2, zmm6, zmmword ptr [rsi + 4*rax + 128] # zmm2 = (zmm6 * mem) + zmm2
	vfmadd231ps	zmm3, zmm7, zmmword ptr [rsi + 4*rax + 192] # zmm3 = (zmm7 * mem) + zmm3
	add	rax, 64
	sub	rcx, -128
	cmp	rcx, rdx
	jbe	.LBB0_2
# %bb.3:
	vaddps	zmm0, zmm1, zmm0
	vaddps	zmm1, zmm3, zmm2
	vaddps	zmm0, zmm1, zmm0
.LBB0_4:
	mov	rcx, rax
	or	rcx, 16
	cmp	rcx, rdx
	jbe	.LBB0_6
# %bb.5:
	mov	rcx, rax
	jmp	.LBB0_7
	.p2align	4, 0x90
.LBB0_6:                                # =>This Inner Loop Header: Depth=1
	vmovups	zmm1, zmmword ptr [rdi + 4*rax]
	vfmadd231ps	zmm0, zmm1, zmmword ptr [rsi + 4*rax] # zmm0 = (zmm1 * mem) + zmm0
	lea	rcx, [rax + 16]
	add	rax, 32
	cmp	rax, rdx
	mov	rax, rcx
	jbe	.LBB0_6
.LBB0_7:
	cmp	rcx, rdx
	je	.LBB0_9
# %bb.8:
	sub	edx, ecx
	mov	eax, -1
	shlx	eax, eax, edx
	not	eax
	kmovd	k1, eax
	vmovups	zmm1 {k1} {z}, zmmword ptr [rdi + 4*rcx]
	vmovups	zmm2 {k1} {z}, zmmword ptr [rsi + 4*rcx]
	vfmadd231ps	zmm0, zmm1, zmm2        # zmm0 = (zmm1 * zmm2) + zmm0
.LBB0_9:
	vextractf64x4	ymm1, zmm0, 1
	vaddps	zmm0, zmm0, zmm1
	vextractf128	xmm1, ymm0, 1
	vaddps	xmm0, xmm0, xmm1
	vpermilpd	xmm1, xmm0, 1           # xmm1 = xmm0[1,0]
	vaddps	xmm0, xmm0, xmm1
	vmovshdup	xmm1, xmm0              # xmm1 = xmm0[1,1,3,3]
	vaddss	xmm0, xmm0, xmm1
	vzeroupper
	ret
.Lfunc_end0:
	.size	dot_avx512, .Lfunc_end0-dot_avx512
	.cfi_endproc
                                        # -- End function
	.globl	gemv_avx512                     # -- Begin function gemv_avx512
	.p2align	4, 0x90
	.type	gemv_avx512,@function
gemv_avx512:                            # @gemv_avx512
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
	test	rcx, rcx
	je	.LBB1_37
# %bb.1:
	cmp	r8, 64
	jae	.LBB1_2
# %bb.10:
	cmp	r8, 16
	jae	.LBB1_11
# %bb.17:
	test	r8, r8
	je	.LBB1_20
# %bb.18:
	mov	eax, -1
	shlx	eax, eax, r8d
	not	eax
	kmovd	k1, eax
	shl	r8, 2
	xor	eax, eax
	vxorps	xmm0, xmm0, xmm0
	.p2align	4, 0x90
.LBB1_19:                               # =>This Inner Loop Header: Depth=1
	vmovups	zmm1 {k1} {z}, zmmword ptr [rdi]
	vmovups	zmm2 {k1} {z}, zmmword ptr [rsi]
	vfmadd213ps	zmm2, zmm1, zmm0        # zmm2 = (zmm1 * zmm2) + zmm0
	vextractf64x4	ymm1, zmm2, 1
	vaddps	zmm1, zmm2, zmm1
	vextractf128	xmm2, ymm1, 1
	vaddps	xmm1, xmm1, xmm2
	vpermilpd	xmm2, xmm1, 1           # xmm2 = xmm1[1,0]
	vaddps	xmm1, xmm1, xmm2
	vmovshdup	xmm2, xmm1              # xmm2 = xmm1[1,1,3,3]
	vaddss	xmm1, xmm1, xmm2
	vmovss	dword ptr [rdx + 4*rax], xmm1
	inc	rax
	add	rdi, r8
	cmp	rcx, rax
	jne	.LBB1_19
	jmp	.LBB1_37
.LBB1_2:
	lea	r12, [rdi + 192]
	lea	rax, [4*r8]
	mov	qword ptr [rsp - 8], rax        # 8-byte Spill
	lea	r14, [rdi + 256]
	xor	r11d, r11d
	jmp	.LBB1_3
	.p2align	4, 0x90
.LBB1_9:                                #   in Loop: Header=BB1_3 Depth=1
	vextractf64x4	ymm1, zmm0, 1
	vaddps	zmm0, zmm0, zmm1
	vextractf128	xmm1, ymm0, 1
	vaddps	xmm0, xmm0, xmm1
	vpermilpd	xmm1, xmm0, 1           # xmm1 = xmm0[1,0]
	vaddps	xmm0, xmm0, xmm1
	vmovshdup	xmm1, xmm0              # xmm1 = xmm0[1,1,3,3]
	vaddss	xmm0, xmm0, xmm1
	vmovss	dword ptr [rdx + 4*r11], xmm0
	inc	r11
	mov	rax, qword ptr [rsp - 8]        # 8-byte Reload
	add	r12, rax
	add	r14, rax
	cmp	r11, rcx
	je	.LBB1_37
.LBB1_3:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_4 Depth 2
                                        #     Child Loop BB1_6 Depth 2
	mov	rax, r11
	imul	rax, r8
	lea	r15, [rdi + 4*rax]
	vxorps	xmm0, xmm0, xmm0
	mov	eax, 64
	mov	r10, r14
	xor	r9d, r9d
	vxorps	xmm1, xmm1, xmm1
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	.p2align	4, 0x90
.LBB1_4:                                #   Parent Loop BB1_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	r13, r9
	mov	rbp, rax
	mov	rbx, r10
	vmovups	zmm4, zmmword ptr [r12 + 4*r9 - 192]
	vmovups	zmm5, zmmword ptr [r12 + 4*r9 - 128]
	vmovups	zmm6, zmmword ptr [r12 + 4*r9 - 64]
	vfmadd231ps	zmm0, zmm4, zmmword ptr [rsi + 4*r9] # zmm0 = (zmm4 * mem) + zmm0
	vfmadd231ps	zmm1, zmm5, zmmword ptr [rsi + 4*r9 + 64] # zmm1 = (zmm5 * mem) + zmm1
	vfmadd231ps	zmm2, zmm6, zmmword ptr [rsi + 4*r9 + 128] # zmm2 = (zmm6 * mem) + zmm2
	vmovups	zmm4, zmmword ptr [r12 + 4*r9]
	vfmadd231ps	zmm3, zmm4, zmmword ptr [rsi + 4*r9 + 192] # zmm3 = (zmm4 * mem) + zmm3
	add	r9, 64
	sub	r13, -128
	add	rax, 64
	add	r10, 256
	cmp	r13, r8
	jbe	.LBB1_4
# %bb.5:                                #   in Loop: Header=BB1_3 Depth=1
	vaddps	zmm0, zmm0, zmm1
	vaddps	zmm1, zmm2, zmm3
	vaddps	zmm0, zmm0, zmm1
	lea	rax, [r9 + 16]
	cmp	rax, r8
	ja	.LBB1_7
	.p2align	4, 0x90
.LBB1_6:                                #   Parent Loop BB1_3 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	vmovups	zmm1, zmmword ptr [rbx]
	vfmadd231ps	zmm0, zmm1, zmmword ptr [rsi + 4*rbp] # zmm0 = (zmm1 * mem) + zmm0
	lea	r9, [rbp + 16]
	add	rbx, 64
	add	rbp, 32
	cmp	rbp, r8
	mov	rbp, r9
	jbe	.LBB1_6
.LBB1_7:                                #   in Loop: Header=BB1_3 Depth=1
	cmp	r9, r8
	je	.LBB1_9
# %bb.8:                                #   in Loop: Header=BB1_3 Depth=1
	mov	eax, r8d
	sub	eax, r9d
	mov	ebp, -1
	shlx	eax, ebp, eax
	not	eax
	kmovd	k1, eax
	vmovups	zmm1 {k1} {z}, zmmword ptr [r15 + 4*r9]
	vmovups	zmm2 {k1} {z}, zmmword ptr [rsi + 4*r9]
	vfmadd231ps	zmm0, zmm1, zmm2        # zmm0 = (zmm1 * zmm2) + zmm0
	jmp	.LBB1_9
.LBB1_11:
	lea	r10, [4*r8]
	xor	ebp, ebp
	mov	r9d, -1
	jmp	.LBB1_12
	.p2align	4, 0x90
.LBB1_16:                               #   in Loop: Header=BB1_12 Depth=1
	vextractf64x4	ymm1, zmm0, 1
	vaddps	zmm0, zmm0, zmm1
	vextractf128	xmm1, ymm0, 1
	vaddps	xmm0, xmm0, xmm1
	vpermilpd	xmm1, xmm0, 1           # xmm1 = xmm0[1,0]
	vaddps	xmm0, xmm0, xmm1
	vmovshdup	xmm1, xmm0              # xmm1 = xmm0[1,1,3,3]
	vaddss	xmm0, xmm0, xmm1
	vmovss	dword ptr [rdx + 4*rbp], xmm0
	inc	rbp
	add	rdi, r10
	cmp	rbp, rcx
	je	.LBB1_37
.LBB1_12:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_13 Depth 2
	vxorps	xmm0, xmm0, xmm0
	xor	eax, eax
	.p2align	4, 0x90
.LBB1_13:                               #   Parent Loop BB1_12 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	mov	rbx, rax
	vmovups	zmm1, zmmword ptr [rdi + 4*rax]
	vfmadd231ps	zmm0, zmm1, zmmword ptr [rsi + 4*rax] # zmm0 = (zmm1 * mem) + zmm0
	add	rax, 16
	add	rbx, 32
	cmp	rbx, r8
	jbe	.LBB1_13
# %bb.14:                               #   in Loop: Header=BB1_12 Depth=1
	cmp	r8, rax
	je	.LBB1_16
# %bb.15:                               #   in Loop: Header=BB1_12 Depth=1
	mov	ebx, r8d
	sub	ebx, eax
	shlx	ebx, r9d, ebx
	not	ebx
	kmovd	k1, ebx
	vmovups	zmm1 {k1} {z}, zmmword ptr [rdi + 4*rax]
	vmovups	zmm2 {k1} {z}, zmmword ptr [rsi + 4*rax]
	vfmadd231ps	zmm0, zmm1, zmm2        # zmm0 = (zmm1 * zmm2) + zmm0
	jmp	.LBB1_16
.LBB1_20:
	cmp	rcx, 8
	jae	.LBB1_22
# %bb.21:
	xor	eax, eax
	jmp	.LBB1_36
.LBB1_22:
	cmp	rcx, 64
	jae	.LBB1_24
# %bb.23:
	xor	eax, eax
	jmp	.LBB1_33
.LBB1_24:
	mov	rax, rcx
	and	rax, -64
	vxorps	xmm0, xmm0, xmm0
	lea	rbp, [rax - 64]
	mov	rdi, rbp
	shr	rdi, 6
	inc	rdi
	mov	esi, edi
	and	esi, 3
	cmp	rbp, 192
	jae	.LBB1_26
# %bb.25:
	xor	ebp, ebp
	jmp	.LBB1_28
.LBB1_26:
	and	rdi, -4
	xor	ebp, ebp
	.p2align	4, 0x90
.LBB1_27:                               # =>This Inner Loop Header: Depth=1
	vmovups	zmmword ptr [rdx + 4*rbp], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 64], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 128], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 192], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 256], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 320], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 384], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 448], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 512], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 576], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 640], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 704], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 768], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 832], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 896], zmm0
	vmovups	zmmword ptr [rdx + 4*rbp + 960], zmm0
	add	rbp, 256
	add	rdi, -4
	jne	.LBB1_27
.LBB1_28:
	test	rsi, rsi
	je	.LBB1_31
# %bb.29:
	lea	rdi, [rdx + 4*rbp]
	add	rdi, 192
	shl	rsi, 8
	xor	ebp, ebp
	.p2align	4, 0x90
.LBB1_30:                               # =>This Inner Loop Header: Depth=1
	vmovups	zmmword ptr [rdi + rbp - 192], zmm0
	vmovups	zmmword ptr [rdi + rbp - 128], zmm0
	vmovups	zmmword ptr [rdi + rbp - 64], zmm0
	vmovups	zmmword ptr [rdi + rbp], zmm0
	add	rbp, 256
	cmp	rsi, rbp
	jne	.LBB1_30
.LBB1_31:
	cmp	rax, rcx
	je	.LBB1_37
# %bb.32:
	test	cl, 56
	je	.LBB1_36
.LBB1_33:
	mov	rsi, rax
	mov	rax, rcx
	and	rax, -8
	vxorps	xmm0, xmm0, xmm0
	.p2align	4, 0x90
.LBB1_34:                               # =>This Inner Loop Header: Depth=1
	vmovups	ymmword ptr [rdx + 4*rsi], ymm0
	add	rsi, 8
	cmp	rax, rsi
	jne	.LBB1_34
# %bb.35:
	cmp	rax, rcx
	je	.LBB1_37
	.p2align	4, 0x90
.LBB1_36:                               # =>This Inner Loop Header: Depth=1
	mov	dword ptr [rdx + 4*rax], 0
	inc	rax
	cmp	rcx, rax
	jne	.LBB1_36
.LBB1_37:
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
.Lfunc_end1:
	.size	gemv_avx512, .Lfunc_end1-gemv_avx512
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
