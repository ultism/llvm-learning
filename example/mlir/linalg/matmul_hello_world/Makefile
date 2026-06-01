# linalg.matmul 的逐层下降 —— 用自编 mlir-opt / mlir-translate（23.0.0git，与 submodule 同源）
#
# 只有一个手写源：matmul.mlir（tensor 版）。其余全部由 pass 生成，绝不手写 memref。
#
#   make generic    # 旁支：named op → linalg.generic（露出 indexing maps + 迭代器 + body，仍是 tensor）
#   make bufferize  # ① tensor → memref（bufferization，这一步才把值语义变成 buffer）
#   make loops      # ② memref → scf 三层循环
#   make llvm       # ③ 全程降到 LLVM dialect（memref → descriptor struct）
#   make ll         # ④ 翻成真正的 LLVM IR（.ll，接回 llvm/ 那条线）
#   make artifacts  # 以上全部一把出（产物入库）
#   make clean      # 删所有生成物，只留 matmul.mlir
#
# 主链：matmul.mlir --bufferize--> matmul.bufferized.mlir --loops/llvm/ll-->
#       loops/llvm/ll 都从「生成的」memref 出发，所以 memref 的来历一目了然。

# 自编工具（首选，与源码同 commit）。从本目录到仓库根是 4 层。
MLIR_BIN  = ../../../../llvm-project/build/bin
MLIR_OPT  = $(MLIR_BIN)/mlir-opt
MLIR_TR   = $(MLIR_BIN)/mlir-translate

# bufferization：tensor → memref。identity-layout 让函数边界用干净的 memref<MxNxf32>
# （不带 strided<…> 动态布局），读起来清楚。
BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"

# memref 一路降到 LLVM dialect 的完整 pass 序列（逐个方言转换，便于对着读）：
#   linalg→scf 循环 / scf→cf 基本块 / memref→descriptor / func·arith·cf→llvm / 收尾去掉 unrealized cast
TO_LLVM = --convert-linalg-to-loops --convert-scf-to-cf --finalize-memref-to-llvm \
          --convert-func-to-llvm --convert-arith-to-llvm --convert-cf-to-llvm \
          --reconcile-unrealized-casts

generic:   matmul.generic.mlir
bufferize: matmul.bufferized.mlir
loops:     matmul.loops.mlir
llvm:      matmul.llvm-dialect.mlir
ll:        matmul.ll
artifacts: generic bufferize loops llvm ll

# 旁支：泛化只看语义，停在 tensor，不需要 bufferize
matmul.generic.mlir: matmul.mlir
	$(MLIR_OPT) --linalg-generalize-named-ops $< -o $@

# ① tensor → memref：memref 是「生成」出来的，不是手写
matmul.bufferized.mlir: matmul.mlir
	$(MLIR_OPT) $(BUF) $< -o $@

# ②③④ 都从生成的 memref 出发
matmul.loops.mlir: matmul.bufferized.mlir
	$(MLIR_OPT) --convert-linalg-to-loops $< -o $@

matmul.llvm-dialect.mlir: matmul.bufferized.mlir
	$(MLIR_OPT) $(TO_LLVM) $< -o $@

matmul.ll: matmul.bufferized.mlir
	$(MLIR_OPT) $(TO_LLVM) $< | $(MLIR_TR) --mlir-to-llvmir -o $@

clean:
	rm -f matmul.generic.mlir matmul.bufferized.mlir matmul.loops.mlir matmul.llvm-dialect.mlir matmul.ll

.PHONY: generic bufferize loops llvm ll artifacts clean
