CC      = clang
CFLAGS  = -O3 -march=native -Wall -Wextra -std=c11
LDLIBS  = -lm

SRC = dot_scalar.c dot_avx512.c main.c
BIN = dot_demo

all: $(BIN)

$(BIN): $(SRC) dot.h
	$(CC) $(CFLAGS) $(SRC) -o $(BIN) $(LDLIBS)

run: $(BIN)
	./$(BIN)

# Intel 语法汇编,看实际生成的指令
asm:
	$(CC) $(CFLAGS) -S -masm=intel dot_scalar.c -o dot_scalar.s
	$(CC) $(CFLAGS) -S -masm=intel dot_avx512.c -o dot_avx512.s

# LLVM IR。标量版本 dump 两份,对比浮点归约向量化的开关:
#   .strict.ll  : 默认严格 FP —— fadd 不可重排,归约循环 *不* 向量化
#   .fast.ll    : -ffast-math —— 允许重新结合 -> 多累加器 + FMA + reduce.fadd
ir:
	$(CC) -O3 -march=native -mprefer-vector-width=512 -emit-llvm -S \
	      -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize \
	      dot_scalar.c -o dot_scalar.strict.ll
	$(CC) -O3 -march=native -mprefer-vector-width=512 -ffast-math -emit-llvm -S \
	      -Rpass=loop-vectorize \
	      dot_scalar.c -o dot_scalar.fast.ll
	$(CC) $(CFLAGS) -emit-llvm -S dot_avx512.c -o dot_avx512.ll

clean:
	rm -f $(BIN) *.s *.ll

.PHONY: all run asm ir clean
