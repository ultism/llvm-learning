# linalg.matmul 走 GPU（NVVM/PTX/SASS）—— 用自编 mlir-opt（23.0.0git，后端含 NVPTX）
#
# 只有一个手写源 matmul.mlir（与 matmul_hello_world 同一个 tensor 版命名 op）。
# 路线：bufferize → affine 循环 →（affine-for-to-gpu）gpu.launch → 抽 kernel → NVVM → PTX → SASS。
# 关键：用 --convert-affine-for-to-gpu 把规整的 affine.for 直接映射成 GPU 网格，
#      m→block.x、n→thread.x，k 留作 kernel 内的顺序 affine.for。
#
#   make launch     # ① gpu.launch（m→block, n→thread；体内仍是 affine.for/affine.load）
#   make module     # ② lower-affine + 抽 kernel：host 的 gpu.launch_func + gpu.module/gpu.func
#   make nvvm       # ③ kernel 降到 NVVM：blockIdx/threadIdx = nvvm.read.ptx.sreg.ctaid/tid
#   make ptx        # ④ 序列化成 PTX（sm_120 虚拟 ISA），从 gpu.binary 抠成干净文本
#   make sass       # ⑤ ptxas + cuobjdump → 真 Blackwell(sm_120) 机器码
#   make artifacts  # 以上全部一把出（产物入库）
#   make clean      # 删所有生成物，只留 matmul.mlir / extract_ptx.py
#
# 链式依赖：每层都从上一层的产物出发，下降关系一目了然。

MLIR_BIN  = ../../../../llvm-project/build/bin
OPT       = $(MLIR_BIN)/mlir-opt
PTXAS     = /root/miniconda3/bin/ptxas
CUOBJDUMP = /root/miniconda3/bin/cuobjdump
CHIP      = sm_120

# bufferize：tensor → memref（identity 布局，干净 memref<MxNxf32>）
BUF = --one-shot-bufferize="bufferize-function-boundaries function-boundary-type-conversion=identity-layout-map"
# affine.for → GPU：ConvertAffineForToGPU 是 func 级 pass，得用 pass-pipeline 嵌进 func.func。
# gpu-block-dims=1 gpu-thread-dims=1：第 1 层循环(m)→block.x，第 2 层(n)→thread.x，其余(k)留循环。
A2G = --pass-pipeline=builtin.module(func.func(convert-affine-for-to-gpu{gpu-block-dims=1 gpu-thread-dims=1}))

artifacts: launch module nvvm ptx sass
launch: matmul.gpu-launch.mlir
module: matmul.gpu-module.mlir
nvvm:   matmul.nvvm.mlir
ptx:    matmul.ptx
sass:   matmul.sass

# ① linalg → affine 循环 → gpu.launch（m→block.x, n→thread.x, k 留 affine.for）
matmul.gpu-launch.mlir: matmul.mlir
	$(OPT) $(BUF) $< | $(OPT) --convert-linalg-to-affine-loops | $(OPT) "$(A2G)" -o $@

# ② lower-affine（affine→scf/arith/memref）+ 抽 kernel（host 留 gpu.launch_func，kernel 进 gpu.module）
matmul.gpu-module.mlir: matmul.gpu-launch.mlir
	$(OPT) --lower-affine --gpu-kernel-outlining $< -o $@

# ③ kernel 降到 NVVM：scf→cf、gpu→nvvm（blockIdx/threadIdx 变 nvvm.read.ptx.sreg），收尾去 cast
matmul.nvvm.mlir: matmul.gpu-module.mlir
	$(OPT) --convert-scf-to-cf --convert-gpu-to-nvvm --reconcile-unrealized-casts $< -o $@

# ④ 给 kernel 贴 sm_120 目标、序列化成 PTX（format=isa），再抠出干净 PTX 文本
matmul.ptx: matmul.nvvm.mlir
	$(OPT) --nvvm-attach-target="chip=$(CHIP)" --gpu-module-to-binary="format=isa" $< | python3 extract_ptx.py > $@

# ⑤ PTX → cubin（ptxas）→ SASS（cuobjdump）。cubin 是二进制中间物，不入库。
matmul.sass: matmul.ptx
	$(PTXAS) -arch=$(CHIP) $< -o matmul.cubin
	$(CUOBJDUMP) -sass matmul.cubin > $@
	rm -f matmul.cubin

clean:
	rm -f matmul.gpu-launch.mlir matmul.gpu-module.mlir matmul.nvvm.mlir matmul.ptx matmul.sass matmul.cubin

.PHONY: artifacts launch module nvvm ptx sass clean
