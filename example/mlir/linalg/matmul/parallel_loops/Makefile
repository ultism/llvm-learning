# 路径③：linalg → scf.parallel（并行循环）→ LLVM IR
#   make all    # 生成 parallel.mlir（中间形态）+ matmul.ll
#   make clean
# 与 scf_loops 的差别：m、n 两个 parallel 维落成一个 scf.parallel（声明「可并行」），
# k 这个 reduction 维仍是内层 scf.for。本例单线程降级（--convert-scf-to-cf 把 scf.parallel
# 摊成顺序 CFG，不真起线程），所以最终 .ll 仍是标量；并行信息体现在中间形态。

MLIR_BIN = ../../../../../llvm-project/build/bin
OPT = $(MLIR_BIN)/mlir-opt
TR  = $(MLIR_BIN)/mlir-translate
SRC = ../matmul.mlir

BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"
LL_TAIL = --convert-scf-to-cf --finalize-memref-to-llvm \
          --convert-func-to-llvm --convert-arith-to-llvm --convert-cf-to-llvm \
          --reconcile-unrealized-casts

all: parallel.mlir matmul.ll

# 特征中间形态：scf.parallel(m,n) 套一层 scf.for(k)
parallel.mlir: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-parallel-loops -o $@

matmul.ll: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-parallel-loops $(LL_TAIL) | $(TR) --mlir-to-llvmir -o $@

clean:
	rm -f parallel.mlir matmul.ll

.PHONY: all clean
