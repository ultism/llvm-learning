# 路径①：linalg → scf.for 三层标量循环 → LLVM IR（最朴素的降法）
#   make all    # 生成 loops.mlir（中间形态）+ matmul.ll（最终 IR）
#   make clean
# 自编工具，子目录到仓库根是 5 层。

MLIR_BIN = ../../../../../llvm-project/build/bin
OPT = $(MLIR_BIN)/mlir-opt
TR  = $(MLIR_BIN)/mlir-translate
SRC = ../matmul.mlir

# 四条路径共用：先 bufferize（tensor→memref，identity 布局求干净 memref<MxNxf32>）
BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"
# 共用收尾：scf→cf / memref→descriptor / func·arith·cf→llvm / 去 unrealized cast
LL_TAIL = --convert-scf-to-cf --finalize-memref-to-llvm \
          --convert-func-to-llvm --convert-arith-to-llvm --convert-cf-to-llvm \
          --reconcile-unrealized-casts

all: loops.mlir matmul.ll

# 特征中间形态：三层 scf.for（k 在最内层做归约）
loops.mlir: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-loops -o $@

matmul.ll: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-loops $(LL_TAIL) | $(TR) --mlir-to-llvmir -o $@

clean:
	rm -f loops.mlir matmul.ll

.PHONY: all clean
