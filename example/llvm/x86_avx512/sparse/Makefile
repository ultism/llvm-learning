CC    = clang
FLAGS = -O3 -march=native -ffast-math -mprefer-vector-width=512

# csr_spmv : 非结构化稀疏,x[col[k]] 逐元素间接 → 向量 GEP + masked.gather + vgatherdps
# bsr_spmm : 块稀疏,间接在块级(标量基址),块内稠密连续 → broadcast,无 gather
ir:
	$(CC) $(FLAGS) -emit-llvm -S csr_spmv.c -o csr_spmv.ll
	$(CC) $(FLAGS) -emit-llvm -S bsr_spmm.c -o bsr_spmm.ll
	$(CC) $(FLAGS) -emit-llvm -S ell_spmv.c -o ell_spmv.ll
asm:
	$(CC) $(FLAGS) -S -masm=intel csr_spmv.c -o csr_spmv.s
	$(CC) $(FLAGS) -S -masm=intel bsr_spmm.c -o bsr_spmm.s
	$(CC) $(FLAGS) -S -masm=intel ell_spmv.c -o ell_spmv.s
clean:
	rm -f *.ll *.s
.PHONY: ir asm clean
