# TMA 读 + half2 向量加 —— 全程只看本机 sm_120（不跨代比较）
#   make run   # 编译并在 GPU 上跑（正确性）
#   make ir    # ① clang LLVM IR  → vadd_tma.ll
#   make ptx   # ② nvcc PTX        → vadd_tma.ptx
#   make sass  # ③ 真卡 SASS       → vadd_tma.sass
#   make clean

NVCC      = /root/miniconda3/bin/nvcc
CUOBJDUMP = /root/miniconda3/bin/cuobjdump
CLANG     = clang-22

CUDA_PATH = /root/miniconda3
CUDA_INC  = $(CUDA_PATH)/targets/x86_64-linux/include

# TMA 是强按代分化的特性，本例只针对本机 sm_120，三层统一用它（不退回 sm_90）。
ARCH      = sm_120
STD       = c++17

SRC = vadd_tma.cu
BIN = vadd_tma.out

run: $(BIN)
	./$(BIN)

$(BIN): $(SRC)
	$(NVCC) -O3 -arch=$(ARCH) -std=$(STD) $(SRC) -o $(BIN)

# ① clang LLVM IR：只出 device 端（nvptx64 模块）
ir:
	$(CLANG) -x cuda --cuda-gpu-arch=$(ARCH) --cuda-device-only \
	  --cuda-path=$(CUDA_PATH) -I$(CUDA_INC) -std=$(STD) \
	  -O3 -emit-llvm -S $(SRC) -o vadd_tma.ll

# ② nvcc PTX
ptx:
	$(NVCC) -ptx -arch=$(ARCH) -std=$(STD) $(SRC) -o vadd_tma.ptx

# ③ 真卡 SASS：编 cubin 再反汇编
sass:
	$(NVCC) -cubin -arch=$(ARCH) -std=$(STD) $(SRC) -o vadd_tma.cubin
	$(CUOBJDUMP) -sass vadd_tma.cubin > vadd_tma.sass

artifacts: ir ptx sass

clean:
	rm -f $(BIN) vadd_tma.cubin vadd_tma.ll vadd_tma.ptx vadd_tma.sass

.PHONY: run ir ptx sass artifacts clean
