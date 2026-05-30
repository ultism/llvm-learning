	.text
	.intel_syntax noprefix
	.file	"gemm.c"
	.globl	gemm_ijk                        # -- Begin function gemm_ijk
	.p2align	4, 0x90
	.type	gemm_ijk,@function
gemm_ijk:                               # @gemm_ijk
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
	mov	qword ptr [rsp - 104], r9       # 8-byte Spill
	mov	qword ptr [rsp - 72], rdx       # 8-byte Spill
	mov	qword ptr [rsp - 96], rsi       # 8-byte Spill
	mov	qword ptr [rsp - 80], rdi       # 8-byte Spill
	mov	qword ptr [rsp - 88], rcx       # 8-byte Spill
	test	rcx, rcx
	je	.LBB0_24
# %bb.1:
	cmp	qword ptr [rsp - 104], 0        # 8-byte Folded Reload
	je	.LBB0_24
# %bb.2:
	test	r8, r8
	je	.LBB0_25
# %bb.3:
	cmp	r8, 8
	setae	al
	mov	rcx, qword ptr [rsp - 104]      # 8-byte Reload
	cmp	rcx, 1
	sete	dl
	and	dl, al
	mov	byte ptr [rsp - 105], dl        # 1-byte Spill
	mov	r11, r8
	and	r11, -64
	mov	r9, r8
	and	r9, -8
	mov	rax, r8
	neg	rax
	mov	qword ptr [rsp - 24], rax       # 8-byte Spill
	mov	rdi, qword ptr [rsp - 80]       # 8-byte Reload
	lea	rbx, [rdi + 192]
	lea	rax, [4*r8]
	mov	qword ptr [rsp - 56], rax       # 8-byte Spill
	mov	rax, qword ptr [rsp - 96]       # 8-byte Reload
	add	rax, 192
	mov	qword ptr [rsp - 64], rax       # 8-byte Spill
	mov	r13, rcx
	shl	r13, 8
	mov	rbp, rcx
	shl	rbp, 5
	lea	rax, [4*rcx]
	mov	qword ptr [rsp - 40], rax       # 8-byte Spill
	lea	r15, [8*rcx]
	xor	ecx, ecx
	vxorps	xmm0, xmm0, xmm0
	jmp	.LBB0_4
	.p2align	4, 0x90
.LBB0_23:                               #   in Loop: Header=BB0_4 Depth=1
	mov	rcx, qword ptr [rsp - 48]       # 8-byte Reload
	inc	rcx
	mov	rax, qword ptr [rsp - 56]       # 8-byte Reload
	add	rbx, rax
	add	rdi, rax
	cmp	rcx, qword ptr [rsp - 88]       # 8-byte Folded Reload
	je	.LBB0_24
.LBB0_4:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
                                        #       Child Loop BB0_10 Depth 3
                                        #       Child Loop BB0_14 Depth 3
                                        #       Child Loop BB0_21 Depth 3
	mov	rax, rcx
	imul	rax, r8
	mov	qword ptr [rsp - 32], rax       # 8-byte Spill
	mov	qword ptr [rsp - 48], rcx       # 8-byte Spill
	imul	rcx, qword ptr [rsp - 104]      # 8-byte Folded Reload
	mov	qword ptr [rsp - 16], rcx       # 8-byte Spill
	mov	rsi, qword ptr [rsp - 96]       # 8-byte Reload
	mov	rdx, qword ptr [rsp - 64]       # 8-byte Reload
	xor	r12d, r12d
	jmp	.LBB0_5
	.p2align	4, 0x90
.LBB0_22:                               #   in Loop: Header=BB0_5 Depth=2
	mov	rax, qword ptr [rsp - 16]       # 8-byte Reload
	add	rax, r12
	mov	rcx, qword ptr [rsp - 72]       # 8-byte Reload
	vmovss	dword ptr [rcx + 4*rax], xmm1
	inc	r12
	mov	rdx, qword ptr [rsp - 8]        # 8-byte Reload
	add	rdx, 4
	add	rsi, 4
	cmp	r12, qword ptr [rsp - 104]      # 8-byte Folded Reload
	je	.LBB0_23
.LBB0_5:                                #   Parent Loop BB0_4 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_10 Depth 3
                                        #       Child Loop BB0_14 Depth 3
                                        #       Child Loop BB0_21 Depth 3
	cmp	byte ptr [rsp - 105], 0         # 1-byte Folded Reload
	mov	qword ptr [rsp - 8], rdx        # 8-byte Spill
	je	.LBB0_6
# %bb.7:                                #   in Loop: Header=BB0_5 Depth=2
	cmp	r8, 64
	jae	.LBB0_9
# %bb.8:                                #   in Loop: Header=BB0_5 Depth=2
	vxorps	xmm1, xmm1, xmm1
	xor	ecx, ecx
	jmp	.LBB0_13
	.p2align	4, 0x90
.LBB0_6:                                #   in Loop: Header=BB0_5 Depth=2
	vxorps	xmm1, xmm1, xmm1
	xor	edx, edx
	jmp	.LBB0_16
	.p2align	4, 0x90
.LBB0_9:                                #   in Loop: Header=BB0_5 Depth=2
	vxorps	xmm1, xmm1, xmm1
	mov	rax, rdx
	xor	ecx, ecx
	vxorps	xmm2, xmm2, xmm2
	vxorps	xmm3, xmm3, xmm3
	vxorps	xmm4, xmm4, xmm4
	.p2align	4, 0x90
.LBB0_10:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovups	zmm5, zmmword ptr [rax - 192]
	vmovups	zmm6, zmmword ptr [rax - 128]
	vmovups	zmm7, zmmword ptr [rax - 64]
	vmovups	zmm8, zmmword ptr [rax]
	vfmadd231ps	zmm1, zmm5, zmmword ptr [rbx + 4*rcx - 192] # zmm1 = (zmm5 * mem) + zmm1
	vfmadd231ps	zmm2, zmm6, zmmword ptr [rbx + 4*rcx - 128] # zmm2 = (zmm6 * mem) + zmm2
	vfmadd231ps	zmm3, zmm7, zmmword ptr [rbx + 4*rcx - 64] # zmm3 = (zmm7 * mem) + zmm3
	vfmadd231ps	zmm4, zmm8, zmmword ptr [rbx + 4*rcx] # zmm4 = (zmm8 * mem) + zmm4
	add	rcx, 64
	add	rax, r13
	cmp	r11, rcx
	jne	.LBB0_10
# %bb.11:                               #   in Loop: Header=BB0_5 Depth=2
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
	cmp	r11, r8
	je	.LBB0_22
# %bb.12:                               #   in Loop: Header=BB0_5 Depth=2
	mov	rcx, r11
	mov	rdx, r11
	test	r8b, 56
	je	.LBB0_16
.LBB0_13:                               #   in Loop: Header=BB0_5 Depth=2
	vblendps	xmm1, xmm0, xmm1, 1             # xmm1 = xmm1[0],xmm0[1,2,3]
	mov	rax, qword ptr [rsp - 104]      # 8-byte Reload
	imul	rax, rcx
	add	rax, r12
	mov	rdx, qword ptr [rsp - 96]       # 8-byte Reload
	lea	rax, [rdx + 4*rax]
	.p2align	4, 0x90
.LBB0_14:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovups	ymm2, ymmword ptr [rax]
	vfmadd231ps	ymm1, ymm2, ymmword ptr [rdi + 4*rcx] # ymm1 = (ymm2 * mem) + ymm1
	add	rcx, 8
	add	rax, rbp
	cmp	r9, rcx
	jne	.LBB0_14
# %bb.15:                               #   in Loop: Header=BB0_5 Depth=2
	vextractf128	xmm2, ymm1, 1
	vaddps	xmm1, xmm1, xmm2
	vpermilpd	xmm2, xmm1, 1           # xmm2 = xmm1[1,0]
	vaddps	xmm1, xmm1, xmm2
	vmovshdup	xmm2, xmm1              # xmm2 = xmm1[1,1,3,3]
	vaddss	xmm1, xmm1, xmm2
	mov	rdx, r9
	cmp	r9, r8
	je	.LBB0_22
.LBB0_16:                               #   in Loop: Header=BB0_5 Depth=2
	test	r8b, 1
	jne	.LBB0_18
# %bb.17:                               #   in Loop: Header=BB0_5 Depth=2
	mov	r10, rdx
	not	rdx
	cmp	rdx, qword ptr [rsp - 24]       # 8-byte Folded Reload
	je	.LBB0_22
	jmp	.LBB0_20
	.p2align	4, 0x90
.LBB0_18:                               #   in Loop: Header=BB0_5 Depth=2
	mov	rax, qword ptr [rsp - 32]       # 8-byte Reload
	lea	r10, [rdx + rax]
	mov	rax, rdx
	imul	rax, qword ptr [rsp - 104]      # 8-byte Folded Reload
	add	rax, r12
	mov	rcx, qword ptr [rsp - 96]       # 8-byte Reload
	vmovss	xmm2, dword ptr [rcx + 4*rax]   # xmm2 = mem[0],zero,zero,zero
	mov	rax, qword ptr [rsp - 80]       # 8-byte Reload
	vfmadd231ss	xmm1, xmm2, dword ptr [rax + 4*r10] # xmm1 = (xmm2 * mem) + xmm1
	mov	r10, rdx
	or	r10, 1
	not	rdx
	cmp	rdx, qword ptr [rsp - 24]       # 8-byte Folded Reload
	je	.LBB0_22
.LBB0_20:                               #   in Loop: Header=BB0_5 Depth=2
	lea	rax, [r10 + 1]
	mov	rcx, qword ptr [rsp - 40]       # 8-byte Reload
	imul	rax, rcx
	add	rax, rsi
	imul	rcx, r10
	add	rcx, rsi
	xor	r14d, r14d
	.p2align	4, 0x90
.LBB0_21:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovss	xmm2, dword ptr [rcx + r14]     # xmm2 = mem[0],zero,zero,zero
	vfmadd132ss	xmm2, xmm1, dword ptr [rdi + 4*r10] # xmm2 = (xmm2 * mem) + xmm1
	vmovss	xmm1, dword ptr [rax + r14]     # xmm1 = mem[0],zero,zero,zero
	vfmadd132ss	xmm1, xmm2, dword ptr [rdi + 4*r10 + 4] # xmm1 = (xmm1 * mem) + xmm2
	add	r10, 2
	add	r14, r15
	cmp	r8, r10
	jne	.LBB0_21
	jmp	.LBB0_22
.LBB0_24:
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
.LBB0_25:
	.cfi_def_cfa_offset 56
	mov	rdx, qword ptr [rsp - 104]      # 8-byte Reload
	imul	rdx, qword ptr [rsp - 88]       # 8-byte Folded Reload
	shl	rdx, 2
	mov	rdi, qword ptr [rsp - 72]       # 8-byte Reload
	xor	esi, esi
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
	jmp	memset@PLT                      # TAILCALL
.Lfunc_end0:
	.size	gemm_ijk, .Lfunc_end0-gemm_ijk
	.cfi_endproc
                                        # -- End function
	.globl	gemm_ikj                        # -- Begin function gemm_ikj
	.p2align	4, 0x90
	.type	gemm_ikj,@function
gemm_ikj:                               # @gemm_ikj
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
	sub	rsp, 88
	.cfi_def_cfa_offset 144
	.cfi_offset rbx, -56
	.cfi_offset r12, -48
	.cfi_offset r13, -40
	.cfi_offset r14, -32
	.cfi_offset r15, -24
	.cfi_offset rbp, -16
	mov	qword ptr [rsp], rsi            # 8-byte Spill
	mov	qword ptr [rsp + 80], rdi       # 8-byte Spill
	mov	qword ptr [rsp + 16], rcx       # 8-byte Spill
	test	rcx, rcx
	je	.LBB1_27
# %bb.1:
	mov	rbx, r9
	test	r8, r8
	je	.LBB1_25
# %bb.2:
	test	rbx, rbx
	je	.LBB1_27
# %bb.3:
	lea	rcx, [4*rbx]
	mov	r14, rbx
	and	r14, -64
	mov	r15, rbx
	and	r15, -8
	mov	rax, rbx
	neg	rax
	mov	qword ptr [rsp + 72], rax       # 8-byte Spill
	mov	rax, qword ptr [rsp]            # 8-byte Reload
	add	rax, 192
	mov	qword ptr [rsp + 32], rax       # 8-byte Spill
	lea	r12, [rdx + 192]
	xor	ebp, ebp
	mov	r13, rdx
	mov	qword ptr [rsp + 40], rdx       # 8-byte Spill
	mov	qword ptr [rsp + 8], rcx        # 8-byte Spill
	mov	qword ptr [rsp + 24], r8        # 8-byte Spill
	jmp	.LBB1_5
	.p2align	4, 0x90
.LBB1_4:                                #   in Loop: Header=BB1_5 Depth=1
	mov	rbp, qword ptr [rsp + 48]       # 8-byte Reload
	inc	rbp
	mov	rcx, qword ptr [rsp + 8]        # 8-byte Reload
	add	r12, rcx
	add	r13, rcx
	cmp	rbp, qword ptr [rsp + 16]       # 8-byte Folded Reload
	je	.LBB1_27
.LBB1_5:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB1_7 Depth 2
                                        #       Child Loop BB1_15 Depth 3
                                        #       Child Loop BB1_19 Depth 3
                                        #       Child Loop BB1_24 Depth 3
	mov	rax, rcx
	imul	rax, rbp
	lea	rdi, [rdx + rax]
	add	rax, rcx
	add	rax, rdx
	mov	qword ptr [rsp + 56], rax       # 8-byte Spill
	mov	qword ptr [rsp + 64], rdi       # 8-byte Spill
	xor	esi, esi
	mov	rdx, rcx
	vzeroupper
	call	memset@PLT
	mov	r8, qword ptr [rsp + 24]        # 8-byte Reload
	mov	rdx, qword ptr [rsp + 40]       # 8-byte Reload
	mov	r9, rbp
	imul	r9, r8
	mov	qword ptr [rsp + 48], rbp       # 8-byte Spill
	mov	r11, rbp
	imul	r11, rbx
	mov	rdi, qword ptr [rsp]            # 8-byte Reload
	mov	rax, rdi
	mov	rsi, qword ptr [rsp + 32]       # 8-byte Reload
	xor	r10d, r10d
	jmp	.LBB1_7
	.p2align	4, 0x90
.LBB1_6:                                #   in Loop: Header=BB1_7 Depth=2
	inc	r10
	mov	rcx, qword ptr [rsp + 8]        # 8-byte Reload
	add	rsi, rcx
	add	rax, rcx
	cmp	r10, r8
	je	.LBB1_4
.LBB1_7:                                #   Parent Loop BB1_5 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB1_15 Depth 3
                                        #       Child Loop BB1_19 Depth 3
                                        #       Child Loop BB1_24 Depth 3
	lea	rcx, [r10 + r9]
	mov	rbp, qword ptr [rsp + 80]       # 8-byte Reload
	vmovss	xmm0, dword ptr [rbp + 4*rcx]   # xmm0 = mem[0],zero,zero,zero
	cmp	rbx, 8
	jb	.LBB1_8
# %bb.9:                                #   in Loop: Header=BB1_7 Depth=2
	mov	rbp, qword ptr [rsp + 8]        # 8-byte Reload
	mov	rcx, rbp
	imul	rcx, r10
	add	rbp, rcx
	add	rbp, rdi
	cmp	qword ptr [rsp + 64], rbp       # 8-byte Folded Reload
	jae	.LBB1_12
# %bb.10:                               #   in Loop: Header=BB1_7 Depth=2
	add	rcx, rdi
	cmp	rcx, qword ptr [rsp + 56]       # 8-byte Folded Reload
	jae	.LBB1_12
.LBB1_8:                                #   in Loop: Header=BB1_7 Depth=2
	xor	ecx, ecx
.LBB1_21:                               #   in Loop: Header=BB1_7 Depth=2
	mov	rbp, rcx
	test	bl, 1
	je	.LBB1_23
# %bb.22:                               #   in Loop: Header=BB1_7 Depth=2
	mov	rdi, r10
	imul	rdi, rbx
	add	rdi, rcx
	mov	rbp, qword ptr [rsp]            # 8-byte Reload
	vmovss	xmm1, dword ptr [rbp + 4*rdi]   # xmm1 = mem[0],zero,zero,zero
	lea	rdi, [rcx + r11]
	vfmadd213ss	xmm1, xmm0, dword ptr [rdx + 4*rdi] # xmm1 = (xmm0 * xmm1) + mem
	vmovss	dword ptr [rdx + 4*rdi], xmm1
	mov	rdi, qword ptr [rsp]            # 8-byte Reload
	mov	rbp, rcx
	or	rbp, 1
.LBB1_23:                               #   in Loop: Header=BB1_7 Depth=2
	not	rcx
	cmp	rcx, qword ptr [rsp + 72]       # 8-byte Folded Reload
	je	.LBB1_6
	.p2align	4, 0x90
.LBB1_24:                               #   Parent Loop BB1_5 Depth=1
                                        #     Parent Loop BB1_7 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovss	xmm1, dword ptr [rax + 4*rbp]   # xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	xmm1, xmm0, dword ptr [r13 + 4*rbp] # xmm1 = (xmm0 * xmm1) + mem
	vmovss	dword ptr [r13 + 4*rbp], xmm1
	vmovss	xmm1, dword ptr [rax + 4*rbp + 4] # xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	xmm1, xmm0, dword ptr [r13 + 4*rbp + 4] # xmm1 = (xmm0 * xmm1) + mem
	vmovss	dword ptr [r13 + 4*rbp + 4], xmm1
	add	rbp, 2
	cmp	rbx, rbp
	jne	.LBB1_24
	jmp	.LBB1_6
	.p2align	4, 0x90
.LBB1_12:                               #   in Loop: Header=BB1_7 Depth=2
	cmp	rbx, 64
	jae	.LBB1_14
# %bb.13:                               #   in Loop: Header=BB1_7 Depth=2
	xor	ebp, ebp
	jmp	.LBB1_18
.LBB1_14:                               #   in Loop: Header=BB1_7 Depth=2
	vbroadcastss	zmm1, xmm0
	xor	ecx, ecx
	.p2align	4, 0x90
.LBB1_15:                               #   Parent Loop BB1_5 Depth=1
                                        #     Parent Loop BB1_7 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovups	zmm2, zmmword ptr [rsi + 4*rcx - 192]
	vmovups	zmm3, zmmword ptr [rsi + 4*rcx - 128]
	vmovups	zmm4, zmmword ptr [rsi + 4*rcx - 64]
	vmovups	zmm5, zmmword ptr [rsi + 4*rcx]
	vfmadd213ps	zmm2, zmm1, zmmword ptr [r12 + 4*rcx - 192] # zmm2 = (zmm1 * zmm2) + mem
	vfmadd213ps	zmm3, zmm1, zmmword ptr [r12 + 4*rcx - 128] # zmm3 = (zmm1 * zmm3) + mem
	vfmadd213ps	zmm4, zmm1, zmmword ptr [r12 + 4*rcx - 64] # zmm4 = (zmm1 * zmm4) + mem
	vfmadd213ps	zmm5, zmm1, zmmword ptr [r12 + 4*rcx] # zmm5 = (zmm1 * zmm5) + mem
	vmovups	zmmword ptr [r12 + 4*rcx - 192], zmm2
	vmovups	zmmword ptr [r12 + 4*rcx - 128], zmm3
	vmovups	zmmword ptr [r12 + 4*rcx - 64], zmm4
	vmovups	zmmword ptr [r12 + 4*rcx], zmm5
	add	rcx, 64
	cmp	r14, rcx
	jne	.LBB1_15
# %bb.16:                               #   in Loop: Header=BB1_7 Depth=2
	cmp	r14, rbx
	je	.LBB1_6
# %bb.17:                               #   in Loop: Header=BB1_7 Depth=2
	mov	rbp, r14
	mov	rcx, r14
	test	bl, 56
	je	.LBB1_21
.LBB1_18:                               #   in Loop: Header=BB1_7 Depth=2
	vbroadcastss	ymm1, xmm0
	.p2align	4, 0x90
.LBB1_19:                               #   Parent Loop BB1_5 Depth=1
                                        #     Parent Loop BB1_7 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	vmovups	ymm2, ymmword ptr [rax + 4*rbp]
	vfmadd213ps	ymm2, ymm1, ymmword ptr [r13 + 4*rbp] # ymm2 = (ymm1 * ymm2) + mem
	vmovups	ymmword ptr [r13 + 4*rbp], ymm2
	add	rbp, 8
	cmp	r15, rbp
	jne	.LBB1_19
# %bb.20:                               #   in Loop: Header=BB1_7 Depth=2
	mov	rcx, r15
	cmp	r15, rbx
	je	.LBB1_6
	jmp	.LBB1_21
.LBB1_25:
	test	rbx, rbx
	je	.LBB1_27
# %bb.26:
	imul	rbx, qword ptr [rsp + 16]       # 8-byte Folded Reload
	shl	rbx, 2
	mov	rdi, rdx
	xor	esi, esi
	mov	rdx, rbx
	add	rsp, 88
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
	jmp	memset@PLT                      # TAILCALL
.LBB1_27:
	.cfi_def_cfa_offset 144
	add	rsp, 88
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
.Lfunc_end1:
	.size	gemm_ikj, .Lfunc_end1-gemm_ikj
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
