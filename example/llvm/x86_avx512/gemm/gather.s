	.text
	.intel_syntax noprefix
	.file	"gather.c"
	.globl	gather_index                    # -- Begin function gather_index
	.p2align	4, 0x90
	.type	gather_index,@function
gather_index:                           # @gather_index
	.cfi_startproc
# %bb.0:
	test	rcx, rcx
	je	.LBB0_18
# %bb.1:
	cmp	rcx, 8
	jae	.LBB0_3
# %bb.2:
	xor	r11d, r11d
	jmp	.LBB0_17
.LBB0_3:
	cmp	rcx, 16
	jae	.LBB0_5
# %bb.4:
	xor	r11d, r11d
	jmp	.LBB0_14
.LBB0_5:
	mov	r11, rcx
	and	r11, -16
	lea	rax, [r11 - 16]
	mov	r9, rax
	shr	r9, 4
	inc	r9
	mov	r8d, r9d
	and	r8d, 3
	cmp	rax, 48
	jae	.LBB0_7
# %bb.6:
	xor	r10d, r10d
	jmp	.LBB0_9
.LBB0_7:
	and	r9, -4
	xor	r10d, r10d
	.p2align	4, 0x90
.LBB0_8:                                # =>This Inner Loop Header: Depth=1
	vmovups	zmm0, zmmword ptr [rsi + 4*r10]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	zmm1 {k1}, zmmword ptr [rdi + 4*zmm0]
	vmovups	zmmword ptr [rdx + 4*r10], zmm1
	vmovups	zmm0, zmmword ptr [rsi + 4*r10 + 64]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	zmm1 {k1}, zmmword ptr [rdi + 4*zmm0]
	vmovups	zmmword ptr [rdx + 4*r10 + 64], zmm1
	vmovups	zmm0, zmmword ptr [rsi + 4*r10 + 128]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	zmm1 {k1}, zmmword ptr [rdi + 4*zmm0]
	vmovups	zmmword ptr [rdx + 4*r10 + 128], zmm1
	vmovups	zmm0, zmmword ptr [rsi + 4*r10 + 192]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	zmm1 {k1}, zmmword ptr [rdi + 4*zmm0]
	vmovups	zmmword ptr [rdx + 4*r10 + 192], zmm1
	add	r10, 64
	add	r9, -4
	jne	.LBB0_8
.LBB0_9:
	test	r8, r8
	je	.LBB0_12
# %bb.10:
	lea	r9, [rdx + 4*r10]
	lea	r10, [rsi + 4*r10]
	shl	r8, 6
	xor	eax, eax
	.p2align	4, 0x90
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	vmovups	zmm0, zmmword ptr [r10 + rax]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	zmm1 {k1}, zmmword ptr [rdi + 4*zmm0]
	vmovups	zmmword ptr [r9 + rax], zmm1
	add	rax, 64
	cmp	r8, rax
	jne	.LBB0_11
.LBB0_12:
	cmp	r11, rcx
	je	.LBB0_18
# %bb.13:
	test	cl, 8
	je	.LBB0_17
.LBB0_14:
	mov	rax, r11
	mov	r11, rcx
	and	r11, -8
	.p2align	4, 0x90
.LBB0_15:                               # =>This Inner Loop Header: Depth=1
	vmovups	ymm0, ymmword ptr [rsi + 4*rax]
	kxnorw	k1, k0, k0
	vxorps	xmm1, xmm1, xmm1
	vgatherdps	ymm1 {k1}, ymmword ptr [rdi + 4*ymm0]
	vmovups	ymmword ptr [rdx + 4*rax], ymm1
	add	rax, 8
	cmp	r11, rax
	jne	.LBB0_15
# %bb.16:
	cmp	r11, rcx
	je	.LBB0_18
	.p2align	4, 0x90
.LBB0_17:                               # =>This Inner Loop Header: Depth=1
	movsxd	rax, dword ptr [rsi + 4*r11]
	vmovss	xmm0, dword ptr [rdi + 4*rax]   # xmm0 = mem[0],zero,zero,zero
	vmovss	dword ptr [rdx + 4*r11], xmm0
	inc	r11
	cmp	rcx, r11
	jne	.LBB0_17
.LBB0_18:
	vzeroupper
	ret
.Lfunc_end0:
	.size	gather_index, .Lfunc_end0-gather_index
	.cfi_endproc
                                        # -- End function
	.ident	"Ubuntu clang version 15.0.7"
	.section	".note.GNU-stack","",@progbits
	.addrsig
