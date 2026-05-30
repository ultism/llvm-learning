CC     = clang
FLAGS  = -O3 -march=native -ffast-math -mprefer-vector-width=512

# 三段对照,看 row-major 访问各自生成什么:
#   gemm_ijk : 跨步列访问 → 编译器按 N==1 版本化 + N>1 标量(不 gather)
#   gemm_ikj : 连续 + 标量不变量 → broadcast
#   gather   : 间接索引 → 向量 GEP + masked.gather + vgatherdps
ir:
	$(CC) $(FLAGS) -emit-llvm -S gemm.c   -o gemm.ll
	$(CC) $(FLAGS) -emit-llvm -S gather.c -o gather.ll
asm:
	$(CC) $(FLAGS) -S -masm=intel gemm.c   -o gemm.s
	$(CC) $(FLAGS) -S -masm=intel gather.c -o gather.s
remarks:
	$(CC) $(FLAGS) -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize -S gemm.c gather.c -o /dev/null

clean:
	rm -f *.ll *.s
.PHONY: ir asm remarks clean
