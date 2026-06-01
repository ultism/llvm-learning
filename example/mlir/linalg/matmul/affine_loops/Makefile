# 路径②：linalg → affine.for 三层循环 →（--lower-affine）→ LLVM IR
#   make all    # 生成 affine.mlir（中间形态）+ matmul.ll
#   make clean
# 与 scf_loops 的差别：循环先落在 affine 方言（affine.for + affine_map 下标），
# 再用 --lower-affine 把 affine 拆成 arith + scf，之后收尾相同。

MLIR_BIN = ../../../../../llvm-project/build/bin
OPT = $(MLIR_BIN)/mlir-opt
TR  = $(MLIR_BIN)/mlir-translate
SRC = ../matmul.mlir

BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"
LL_TAIL = --convert-scf-to-cf --finalize-memref-to-llvm \
          --convert-func-to-llvm --convert-arith-to-llvm --convert-cf-to-llvm \
          --reconcile-unrealized-casts

all: affine.mlir matmul.ll

# 特征中间形态：三层 affine.for，下标用 affine_map 表达
affine.mlir: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-affine-loops -o $@

matmul.ll: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-affine-loops --lower-affine $(LL_TAIL) | $(TR) --mlir-to-llvmir -o $@

clean:
	rm -f affine.mlir matmul.ll

.PHONY: all clean
