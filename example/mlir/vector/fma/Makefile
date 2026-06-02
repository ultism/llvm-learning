# vector.fma 降到 x86 —— MLIR 通用 op 怎么落到 AVX-512 向量指令（路 A）
#
# 工具：自编 23.0.0git 的 mlir-opt / mlir-translate / llc（X86 后端）。
MLIR_BIN   := ../../../../llvm-project/build/bin
MLIR_OPT   := $(MLIR_BIN)/mlir-opt
MLIR_XLATE := $(MLIR_BIN)/mlir-translate
LLC        := $(MLIR_BIN)/llc

# 直接用本机微架构 Zen5（AVX-512 + FMA，全宽 512 位，无 Skylake 的 256 位降频惩罚）。
CPU := znver5

SRC := fma.mlir

# vector→llvm 方言（外加 arith / func）。这一步里 vector.fma → llvm.intr.fmuladd。
TO_LLVM := --convert-vector-to-llvm --convert-arith-to-llvm \
           --convert-func-to-llvm --reconcile-unrealized-casts

.PHONY: artifacts ir llvmir asm clean

artifacts: ir llvmir asm

# ① LLVM 方言：vector.fma → llvm.intr.fmuladd；mulf/addf → llvm.fmul/fadd
ir: fma.llvm.mlir
fma.llvm.mlir: $(SRC)
	$(MLIR_OPT) $(SRC) $(TO_LLVM) -o $@

# ② LLVM IR：@fused 出 @llvm.fmuladd，@separate 出 fmul + fadd
llvmir: fma.ll
fma.ll: fma.llvm.mlir
	$(MLIR_XLATE) --mlir-to-llvmir $< -o $@

# ③ x86 汇编：
#   fma.s   有 FMA 单元（本机 znver5，512 位）：@fused 出一条 vfmadd；@separate 出 vmul+vadd。
#   nofma.s 假装没 FMA（-mattr=-fma）：连 @fused 也得拆成 vmul+vadd。
#           注意：x86 里 AVX-512 依赖 FMA，去掉 FMA 会连带降到 AVX2，宽度掉到 256 位 ymm。
asm: fma.fma.s fma.nofma.s
fma.fma.s: fma.ll
	$(LLC) -mcpu=$(CPU) $< -o $@
fma.nofma.s: fma.ll
	$(LLC) -mcpu=$(CPU) -mattr=-fma $< -o $@

clean:
	rm -f fma.llvm.mlir fma.ll fma.fma.s fma.nofma.s
