# 同一个 matmul.mlir，走不同 pass 路径降到 LLVM IR —— 每条路径一个子文件夹。
#   make all     # 把每个子文件夹的产物都生成出来
#   make clean   # 清掉所有子文件夹的生成物
# 单独跑某一条：进对应子目录 make（见各自 README）。

PATHS = scf_loops affine_loops parallel_loops affine_vectorize

all:
	@for d in $(PATHS); do echo "=== $$d ==="; $(MAKE) --no-print-directory -C $$d all || exit 1; done

clean:
	@for d in $(PATHS); do $(MAKE) --no-print-directory -C $$d clean; done

.PHONY: all clean
