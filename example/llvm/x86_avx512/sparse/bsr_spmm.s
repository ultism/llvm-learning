	.text
	.intel_syntax noprefix
	.file	"bsr_spmm.c"
	.globl	bsr_spmm                        # -- Begin function bsr_spmm
	.p2align	4, 0x90
	.type	bsr_spmm,@function
bsr_spmm:                               # @bsr_spmm
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
	mov	qword ptr [rsp - 120], r8       # 8-byte Spill
	mov	qword ptr [rsp - 128], rcx      # 8-byte Spill
	mov	qword ptr [rsp - 48], rsi       # 8-byte Spill
	mov	qword ptr [rsp - 56], rdi       # 8-byte Spill
	test	edx, edx
	jle	.LBB0_21
# %bb.1:
	mov	ecx, dword ptr [rsp + 56]
	test	ecx, ecx
	jle	.LBB0_21
# %bb.2:
	test	r9d, r9d
	jle	.LBB0_21
# %bb.3:
	movsxd	rsi, ecx
	mov	rax, rsi
	imul	rax, rsi
	mov	qword ptr [rsp - 64], rax       # 8-byte Spill
	movsxd	rax, r9d
	mov	qword ptr [rsp - 32], rsi       # 8-byte Spill
	imul	rsi, rax
	mov	edx, edx
	mov	qword ptr [rsp - 80], rdx       # 8-byte Spill
	mov	r8d, ecx
	mov	ebx, r9d
	mov	ecx, ebx
	and	ecx, -64
	mov	qword ptr [rsp - 112], rcx      # 8-byte Spill
	mov	r12d, ebx
	and	r12d, -8
	mov	rcx, qword ptr [rsp - 128]      # 8-byte Reload
	add	rcx, 192
	mov	qword ptr [rsp - 88], rcx       # 8-byte Spill
	mov	qword ptr [rsp - 72], rsi       # 8-byte Spill
	lea	rcx, [4*rsi]
	mov	qword ptr [rsp - 96], rcx       # 8-byte Spill
	shl	rax, 2
	mov	rcx, qword ptr [rsp - 120]      # 8-byte Reload
	add	rcx, 192
	mov	qword ptr [rsp - 104], rcx      # 8-byte Spill
	lea	rdi, [4*rbx]
	and	rdi, -256
	xor	esi, esi
	jmp	.LBB0_4
	.p2align	4, 0x90
.LBB0_20:                               #   in Loop: Header=BB0_4 Depth=1
	mov	rsi, qword ptr [rsp - 40]       # 8-byte Reload
	inc	rsi
	cmp	rsi, qword ptr [rsp - 80]       # 8-byte Folded Reload
	je	.LBB0_21
.LBB0_4:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_5 Depth 2
                                        #       Child Loop BB0_6 Depth 3
                                        #         Child Loop BB0_11 Depth 4
                                        #         Child Loop BB0_15 Depth 4
                                        #         Child Loop BB0_17 Depth 4
	mov	rcx, qword ptr [rsp - 64]       # 8-byte Reload
	imul	rcx, rsi
	mov	rdx, qword ptr [rsp - 56]       # 8-byte Reload
	lea	r13, [rdx + 4*rcx]
	mov	rcx, qword ptr [rsp - 48]       # 8-byte Reload
	mov	qword ptr [rsp - 40], rsi       # 8-byte Spill
	movsxd	rsi, dword ptr [rcx + 4*rsi]
	mov	rcx, qword ptr [rsp - 72]       # 8-byte Reload
	imul	rcx, rsi
	mov	rdx, qword ptr [rsp - 128]      # 8-byte Reload
	lea	rcx, [rdx + 4*rcx]
	mov	qword ptr [rsp - 24], rcx       # 8-byte Spill
	imul	rsi, qword ptr [rsp - 96]       # 8-byte Folded Reload
	add	rsi, qword ptr [rsp - 88]       # 8-byte Folded Reload
	mov	qword ptr [rsp - 16], rsi       # 8-byte Spill
	mov	r14, qword ptr [rsp - 120]      # 8-byte Reload
	mov	rsi, qword ptr [rsp - 104]      # 8-byte Reload
	xor	r15d, r15d
	jmp	.LBB0_5
	.p2align	4, 0x90
.LBB0_19:                               #   in Loop: Header=BB0_5 Depth=2
	mov	r15, qword ptr [rsp - 8]        # 8-byte Reload
	inc	r15
	add	rsi, rax
	add	r14, rax
	cmp	r15, r8
	je	.LBB0_20
.LBB0_5:                                #   Parent Loop BB0_4 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_6 Depth 3
                                        #         Child Loop BB0_11 Depth 4
                                        #         Child Loop BB0_15 Depth 4
                                        #         Child Loop BB0_17 Depth 4
	mov	qword ptr [rsp - 8], r15        # 8-byte Spill
	imul	r15, qword ptr [rsp - 32]       # 8-byte Folded Reload
	mov	rbp, qword ptr [rsp - 24]       # 8-byte Reload
	mov	r10, qword ptr [rsp - 16]       # 8-byte Reload
	xor	r11d, r11d
	jmp	.LBB0_6
	.p2align	4, 0x90
.LBB0_18:                               #   in Loop: Header=BB0_6 Depth=3
	inc	r11
	add	r10, rax
	add	rbp, rax
	cmp	r11, r8
	je	.LBB0_19
.LBB0_6:                                #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_11 Depth 4
                                        #         Child Loop BB0_15 Depth 4
                                        #         Child Loop BB0_17 Depth 4
	lea	rcx, [r11 + r15]
	vmovss	xmm0, dword ptr [r13 + 4*rcx]   # xmm0 = mem[0],zero,zero,zero
	cmp	r9d, 8
	jae	.LBB0_8
# %bb.7:                                #   in Loop: Header=BB0_6 Depth=3
	xor	edx, edx
	jmp	.LBB0_17
	.p2align	4, 0x90
.LBB0_8:                                #   in Loop: Header=BB0_6 Depth=3
	cmp	r9d, 64
	jae	.LBB0_10
# %bb.9:                                #   in Loop: Header=BB0_6 Depth=3
	xor	ecx, ecx
	jmp	.LBB0_14
	.p2align	4, 0x90
.LBB0_10:                               #   in Loop: Header=BB0_6 Depth=3
	mov	rcx, r8
	vbroadcastss	zmm1, xmm0
	xor	r8d, r8d
	.p2align	4, 0x90
.LBB0_11:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        #       Parent Loop BB0_6 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	vmovups	zmm2, zmmword ptr [r10 + r8 - 192]
	vmovups	zmm3, zmmword ptr [r10 + r8 - 128]
	vmovups	zmm4, zmmword ptr [r10 + r8 - 64]
	vmovups	zmm5, zmmword ptr [r10 + r8]
	vfmadd213ps	zmm2, zmm1, zmmword ptr [rsi + r8 - 192] # zmm2 = (zmm1 * zmm2) + mem
	vfmadd213ps	zmm3, zmm1, zmmword ptr [rsi + r8 - 128] # zmm3 = (zmm1 * zmm3) + mem
	vfmadd213ps	zmm4, zmm1, zmmword ptr [rsi + r8 - 64] # zmm4 = (zmm1 * zmm4) + mem
	vfmadd213ps	zmm5, zmm1, zmmword ptr [rsi + r8] # zmm5 = (zmm1 * zmm5) + mem
	vmovups	zmmword ptr [rsi + r8 - 192], zmm2
	vmovups	zmmword ptr [rsi + r8 - 128], zmm3
	vmovups	zmmword ptr [rsi + r8 - 64], zmm4
	vmovups	zmmword ptr [rsi + r8], zmm5
	add	r8, 256
	cmp	rdi, r8
	jne	.LBB0_11
# %bb.12:                               #   in Loop: Header=BB0_6 Depth=3
	cmp	qword ptr [rsp - 112], rbx      # 8-byte Folded Reload
	mov	r8, rcx
	je	.LBB0_18
# %bb.13:                               #   in Loop: Header=BB0_6 Depth=3
	mov	rdx, qword ptr [rsp - 112]      # 8-byte Reload
	mov	rcx, rdx
	test	bl, 56
	je	.LBB0_17
.LBB0_14:                               #   in Loop: Header=BB0_6 Depth=3
	vbroadcastss	ymm1, xmm0
	.p2align	4, 0x90
.LBB0_15:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        #       Parent Loop BB0_6 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	vmovups	ymm2, ymmword ptr [rbp + 4*rcx]
	vfmadd213ps	ymm2, ymm1, ymmword ptr [r14 + 4*rcx] # ymm2 = (ymm1 * ymm2) + mem
	vmovups	ymmword ptr [r14 + 4*rcx], ymm2
	add	rcx, 8
	cmp	r12, rcx
	jne	.LBB0_15
# %bb.16:                               #   in Loop: Header=BB0_6 Depth=3
	mov	rdx, r12
	cmp	r12, rbx
	je	.LBB0_18
	.p2align	4, 0x90
.LBB0_17:                               #   Parent Loop BB0_4 Depth=1
                                        #     Parent Loop BB0_5 Depth=2
                                        #       Parent Loop BB0_6 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	vmovss	xmm1, dword ptr [rbp + 4*rdx]   # xmm1 = mem[0],zero,zero,zero
	vfmadd213ss	xmm1, xmm0, dword ptr [r14 + 4*rdx] # xmm1 = (xmm0 * xmm1) + mem
	vmovss	dword ptr [r14 + 4*rdx], xmm1
	inc	rdx
	cmp	rbx, rdx
	jne	.LBB0_17
	jmp	.LBB0_18
.LBB0_21:
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
	.size	bsr_spmm, .Lfunc_end0-bsr_spmm
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
