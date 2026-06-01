# 路径④：linalg → affine.for →（--affine-super-vectorize）→ vector 方言 → LLVM IR
#   make all    # 生成 vector.mlir（中间形态）+ matmul.ll
#   make clean
# 唯一一条最终 .ll 真正变样的路径：N 维按 step 8 切，算子升成 vector<8xf32>，
# 落到 LLVM IR 就是 <8 x float> 的 fmul/fadd + @llvm.masked.load/store（真 SIMD）。

MLIR_BIN = ../../../../../llvm-project/build/bin
OPT = $(MLIR_BIN)/mlir-opt
TR  = $(MLIR_BIN)/mlir-translate
SRC = ../matmul.mlir

BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"
# N 维向量宽度 8；vectorize-reductions 让沿 k 的归约也能向量化
VEC = --affine-super-vectorize="virtual-vector-size=8 vectorize-reductions=true"

all: vector.mlir matmul.ll

# 特征中间形态：affine.for + vector.transfer_read/write + arith.mulf : vector<8xf32>
vector.mlir: $(SRC)
	$(OPT) $(BUF) $(SRC) | $(OPT) --convert-linalg-to-affine-loops $(VEC) -o $@

# vector 比标量多两步：--convert-vector-to-scf 把 transfer 拆成带掩码的访存，
# --convert-vector-to-llvm 落成 <N x f32> 指令；transfer 的填充会引入 ub.poison，
# 故收尾加 --convert-ub-to-llvm（须在 reconcile 之前）。
matmul.ll: $(SRC)
	$(OPT) $(BUF) $(SRC) \
	  | $(OPT) --convert-linalg-to-affine-loops $(VEC) --lower-affine \
	           --convert-vector-to-scf --convert-vector-to-llvm \
	           --convert-scf-to-cf --finalize-memref-to-llvm \
	           --convert-func-to-llvm --convert-arith-to-llvm --convert-cf-to-llvm \
	           --convert-ub-to-llvm --reconcile-unrealized-casts \
	  | $(TR) --mlir-to-llvmir -o $@

clean:
	rm -f vector.mlir matmul.ll

.PHONY: all clean
