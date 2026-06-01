# linalg.matmul 走 GPU —— scf.parallel 官方路（NVVM/PTX/SASS）
#   自编 mlir-opt（23.0.0git，后端含 NVPTX）+ conda ptxas/cuobjdump（CUDA 12.8）。
#
# 同一个手写源 matmul.mlir（与 affine/ 同源，tensor 版命名 op）。
# 路线：bufferize → scf.parallel(m,n)+scf.for(k) →（gpu-map-parallel-loops +
#       convert-parallel-loops-to-gpu）gpu.launch → lower-affine + 抽 kernel →
#       gpu→nvvm → PTX → SASS。
# 关键：convert-parallel-loops-to-gpu 是 MLIR 官方的 parallel→GPU 映射 pass，
#      它把 m、n 两维全摊进 blocks（4×16 block × 1 线程），并在 kernel 体内插
#      affine.apply 从 block id 反算下标 —— 所以抽 kernel 前必须先 --lower-affine，
#      否则会残留 (i64)->index 的 unrealized_conversion_cast，gpu-module-to-binary 报错。
#
#   make parallel   # ① bufferize + linalg→parallel：scf.parallel(m,n) 套 scf.for(k)
#   make launch     # ② gpu-map + convert-parallel-loops-to-gpu：gpu.launch（m,n→blocks）
#   make module     # ③ lower-affine + 抽 kernel：host 的 gpu.launch_func + gpu.module/gpu.func
#   make nvvm       # ④ kernel 降到 NVVM：blockIdx = nvvm.read.ptx.sreg.ctaid.x/.y
#   make ptx        # ⑤ 序列化成 PTX（sm_120 虚拟 ISA），从 gpu.binary 抠成干净文本
#   make sass       # ⑥ ptxas + cuobjdump → 真 Blackwell(sm_120) 机器码
#   make artifacts  # 以上全部一把出（产物入库）
#   make clean      # 删生成物，只留 matmul.mlir（PTX 提取器在 ../../extract_ptx.py）

MLIR_BIN  = ../../../../../../llvm-project/build/bin
OPT       = $(MLIR_BIN)/mlir-opt
PTXAS     = /root/miniconda3/bin/ptxas
CUOBJDUMP = /root/miniconda3/bin/cuobjdump
CHIP      = sm_120

# bufferize：tensor → memref（identity 布局，干净 memref<MxNxf32>）
BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"

artifacts: parallel launch module nvvm ptx sass
parallel: matmul.parallel.mlir
launch:   matmul.gpu-launch.mlir
module:   matmul.gpu-module.mlir
nvvm:     matmul.nvvm.mlir
ptx:      matmul.ptx
sass:     matmul.sass

# ① bufferize + linalg → scf.parallel(m,n) 套 scf.for(k)
matmul.parallel.mlir: matmul.mlir
	$(OPT) $(BUF) $< | $(OPT) --convert-linalg-to-parallel-loops -o $@

# ② 官方映射：gpu-map-parallel-loops 标注，再 convert-parallel-loops-to-gpu 摊进网格
#    （m,n 两维 → blocks.y/blocks.x，每 block 1 线程；体内 affine.apply 反算下标）
matmul.gpu-launch.mlir: matmul.parallel.mlir
	$(OPT) --gpu-map-parallel-loops --convert-parallel-loops-to-gpu $< -o $@

# ③ lower-affine（拆掉那些 affine.apply，关键！）+ 抽 kernel
matmul.gpu-module.mlir: matmul.gpu-launch.mlir
	$(OPT) --lower-affine --gpu-kernel-outlining $< -o $@

# ④ kernel 降到 NVVM：scf→cf、gpu→nvvm（blockIdx 变 nvvm.read.ptx.sreg.ctaid），收尾去 cast
matmul.nvvm.mlir: matmul.gpu-module.mlir
	$(OPT) --convert-scf-to-cf --convert-gpu-to-nvvm --reconcile-unrealized-casts $< -o $@

# ⑤ 贴 sm_120 目标、序列化成 PTX（format=isa），抠出干净 PTX 文本
matmul.ptx: matmul.nvvm.mlir
	$(OPT) --nvvm-attach-target="chip=$(CHIP)" --gpu-module-to-binary="format=isa" $< | python3 ../../extract_ptx.py > $@

# ⑥ PTX → cubin（ptxas）→ SASS（cuobjdump）。cubin 二进制中间物不入库。
matmul.sass: matmul.ptx
	$(PTXAS) -arch=$(CHIP) $< -o matmul.cubin
	$(CUOBJDUMP) -sass matmul.cubin > $@
	rm -f matmul.cubin

clean:
	rm -f matmul.parallel.mlir matmul.gpu-launch.mlir matmul.gpu-module.mlir matmul.nvvm.mlir matmul.ptx matmul.sass matmul.cubin

.PHONY: artifacts parallel launch module nvvm ptx sass clean
