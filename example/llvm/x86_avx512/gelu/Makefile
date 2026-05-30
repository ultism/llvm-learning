# Build the GELU demo with LLVM/clang.
#
# -march=native enables AVX-512 (incl. AVX512DQ) on this Zen 5 machine.
# To target AVX-512 explicitly instead, swap in:
#   CFLAGS = -O3 -mavx512f -mavx512dq -mfma -Wall -Wextra -std=c11

CC      = clang
CFLAGS  = -O3 -march=native -Wall -Wextra -std=c11
LDLIBS  = -lsleef -lm   # SLEEF provides the vectorised erf (Sleef_erff16_u10)

SRC     = main.c gelu_scalar.c gelu_avx512.c
BIN     = gelu_demo.out

$(BIN): $(SRC) gelu.h
	$(CC) $(CFLAGS) -o $@ $(SRC) $(LDLIBS)

run: $(BIN)
	./$(BIN)

# Inspect the generated AVX-512 assembly for the kernel.
asm: gelu_avx512.c gelu.h
	$(CC) $(CFLAGS) -S -o gelu_avx512.s gelu_avx512.c

# Dump LLVM IR for both kernels.
#  - the scalar dump also prints the loop-vectorizer's verdict; the erff() call
#    blocks auto-vectorization (clang 15's libmvec map has no erf), so it stays
#    scalar. The AVX-512 dump shows <16 x float> ops + the Sleef_erff16_u10 call.
ir: gelu_scalar.c gelu_avx512.c gelu.h
	$(CC) $(CFLAGS) -emit-llvm -S gelu_scalar.c -o gelu_scalar.ll \
	    -Rpass=loop-vectorize -Rpass-missed=loop-vectorize -Rpass-analysis=loop-vectorize
	$(CC) $(CFLAGS) -emit-llvm -S gelu_avx512.c -o gelu_avx512.ll
	@echo "wrote gelu_scalar.ll, gelu_avx512.ll"

clean:
	rm -f $(BIN) gelu_avx512.s gelu_scalar.ll gelu_avx512.ll

.PHONY: run asm ir clean
