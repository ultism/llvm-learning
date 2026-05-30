# CUDA 向量加：fp32 vs fp16 —— 三层中间产物对照
#   make run   # 编译并在 GPU 上跑（正确性）
#   make ir    # ① clang LLVM IR  → vadd.ll
#   make ptx   # ② nvcc PTX        → vadd.ptx
#   make sass  # ③ 真卡 SASS       → vadd.sass（sm_120）
#   make clean

NVCC      = /root/miniconda3/bin/nvcc
CUOBJDUMP = /root/miniconda3/bin/cuobjdump
CLANG     = clang-22

CUDA_PATH = /root/miniconda3
CUDA_INC  = $(CUDA_PATH)/targets/x86_64-linux/include

# 出 IR/PTX 不挑卡，用任意被认识的低 arch 即可；真在卡上跑/出 SASS 才要本机的 sm_120。
ARCH_IR   = sm_90
ARCH_RUN  = sm_120

SRC = vadd.cu
BIN = vadd.out

# 默认：编译并在 GPU 上验正确性
run: $(BIN)
	./$(BIN)

$(BIN): $(SRC)
	$(NVCC) -O3 -arch=$(ARCH_RUN) $(SRC) -o $(BIN)

# ① clang LLVM IR：只出 device 端（nvptx64 模块），host main 被忽略
ir:
	$(CLANG) -x cuda --cuda-gpu-arch=$(ARCH_IR) --cuda-device-only \
	  --cuda-path=$(CUDA_PATH) -I$(CUDA_INC) \
	  -O3 -emit-llvm -S $(SRC) -o vadd.ll

# ② nvcc PTX（NVVM 虚拟 ISA）
ptx:
	$(NVCC) -ptx -arch=$(ARCH_IR) $(SRC) -o vadd.ptx

# ③ 真卡 SASS：编 cubin（sm_120）再反汇编
sass:
	$(NVCC) -cubin -arch=$(ARCH_RUN) $(SRC) -o vadd.cubin
	$(CUOBJDUMP) -sass vadd.cubin > vadd.sass

# 三层一把出
artifacts: ir ptx sass

clean:
	rm -f $(BIN) vadd.cubin vadd.ll vadd.ptx vadd.sass

.PHONY: run ir ptx sass artifacts clean
