# linalg.matmul 走 tensor core（WMMA）—— 自编 mlir-opt（23.0.0git，NVPTX）+ conda ptxas/cuobjdump
#
# 源：matmul.mlir（f16 16x16x16，包在 gpu.launch=1 warp 里）+ schedule.mlir（transform 调度，外挂）。
# 路线：transform 向量化→vector.contract → convert-vector-to-gpu→gpu.subgroup_mma → 抽 kernel
#       → gpu→nvvm（nvvm.wmma）→ PTX（wmma.mma.sync）→ SASS（HMMA）。
#
#   make contract   # ① 向量化+prepare patterns：linalg.matmul → vector.contract
#   make mma        # ② convert-vector-to-gpu：vector.contract → gpu.subgroup_mma_*（WMMA op）
#   make module     # ③ 抽 kernel：host 的 gpu.launch_func + gpu.module/gpu.func
#   make nvvm       # ④ gpu→nvvm：nvvm.wmma.load/mma/store
#   make ptx        # ⑤ 序列化成 PTX：wmma.load/mma/store.sync.aligned（sm_120）
#   make sass       # ⑥ ptxas + cuobjdump → 真 Blackwell：HMMA.16816
#   make artifacts  # 全出（产物入库）
#   make clean      # 删生成物，只留 matmul.mlir / schedule.mlir（PTX 提取器在 ../extract_ptx.py）

MLIR_BIN  = ../../../../../llvm-project/build/bin
OPT       = $(MLIR_BIN)/mlir-opt
PTXAS     = /root/miniconda3/bin/ptxas
CUOBJDUMP = /root/miniconda3/bin/cuobjdump
CHIP      = sm_120

# 外挂调度执行：transform.structured.vectorize + reduction_to_contract 等 prepare patterns
VECTORIZE = --transform-preload-library="transform-library-paths=schedule.mlir" --transform-interpreter

artifacts: contract mma module nvvm ptx sass
contract: matmul.contract.mlir
mma:      matmul.subgroup-mma.mlir
module:   matmul.gpu-module.mlir
nvvm:     matmul.nvvm.mlir
ptx:      matmul.ptx
sass:     matmul.sass

# ① linalg.matmul → vector.contract（向量化默认到 multi_reduction，靠 prepare patterns 抬成 contract）
matmul.contract.mlir: matmul.mlir schedule.mlir
	$(OPT) matmul.mlir $(VECTORIZE) -o $@

# ② vector.contract → gpu.subgroup_mma_load/compute/store + !gpu.mma_matrix
matmul.subgroup-mma.mlir: matmul.contract.mlir
	$(OPT) --convert-vector-to-gpu $< -o $@

# ③ 抽 kernel：launch 体进 gpu.module，host 留 gpu.launch_func
matmul.gpu-module.mlir: matmul.subgroup-mma.mlir
	$(OPT) --gpu-kernel-outlining $< -o $@

# ④ kernel 降到 NVVM：gpu.subgroup_mma → nvvm.wmma.*
matmul.nvvm.mlir: matmul.gpu-module.mlir
	$(OPT) --convert-scf-to-cf --convert-gpu-to-nvvm --reconcile-unrealized-casts $< -o $@

# ⑤ 贴 sm_120 目标、序列化成 PTX（format=isa），抠出干净文本
matmul.ptx: matmul.nvvm.mlir
	$(OPT) --nvvm-attach-target="chip=$(CHIP)" --gpu-module-to-binary="format=isa" $< | python3 ../extract_ptx.py > $@

# ⑥ PTX → cubin（ptxas）→ SASS（cuobjdump）。cubin 二进制中间物不入库。
matmul.sass: matmul.ptx
	$(PTXAS) -arch=$(CHIP) $< -o matmul.cubin
	$(CUOBJDUMP) -sass matmul.cubin > $@
	rm -f matmul.cubin

clean:
	rm -f matmul.contract.mlir matmul.subgroup-mma.mlir matmul.gpu-module.mlir matmul.nvvm.mlir matmul.ptx matmul.sass matmul.cubin

.PHONY: artifacts contract mma module nvvm ptx sass clean
