# tma_half2 —— 用 TMA 读 + half2 加，三层看 sm_120 的异步搬运

第二个 CUDA 例子。在 [`../vector_add`](../vector_add) 把「一个线程加一个标量」讲透之后，这里换两样东西，
**全程只看本机 `sm_120`（RTX 5060 Ti，消费级 Blackwell），不做跨代对比**：

1. **TMA（Tensor Memory Accelerator）做「读」**：一条硬件指令把整块 global 异步搬进 shared，
   由单个线程发射，完成用 mbarrier 跟踪。
2. **half2（`__half2` = 打包的 2 个 fp16）做「加」**：一条 `HADD2` 同时算两个 half——
   兑现上个例子结尾说的「fp16 要打包才有吞吐红利」。

> **为什么不像 fp16/bf16 那样跨代比？** TMA 是强按代分化的特性：Hopper（sm_90）、Blackwell 数据中心
> （sm_100）、Blackwell 消费（sm_120）三代的能力和指令都不一样。本机 sm_120 **有 TMA 但没有 multicast**，
> 所以这里的 `cp.async.bulk` 是 **unicast**（PTX/IR 注释里直接写着 `// 1a. unicast`）。拿它和别代比只会添乱，
> 因此 Makefile 三层统一 `ARCH = sm_120`，不退回 sm_90。

## 文件

| 文件 | 内容 |
|---|---|
| `vadd_tma.cu` | kernel `vadd_h2_tma`（TMA 读→half2 加→普通写回）+ host 验证 |
| `vadd_tma.ll` / `.ptx` / `.sass` | 三层产物（`make artifacts` 生成，已入库） |
| `Makefile` | `run` / `ir` / `ptx` / `sass` / `artifacts` / `clean`，全程 `sm_120` |

## 跑

```sh
make run        # GPU 上验：OK，c[0]={3.0,3.0}
make artifacts  # 一把出 .ll / .ptx / .sass（都 sm_120）
```

> 写法用 `cuda::ptx::` 薄封装（`#include <cuda/ptx>`）。每个 TMA/mbarrier 操作在 IR/PTX 里
> 都是一条带 `// 序号` 注释的内联 asm（序号对应 PTX ISA 文档的指令编号），对着读最直观。
> 没用高层 `cuda::barrier`，是因为它的 `__shared__ barrier` 带构造函数，**clang 前端拒编**
> （`initialization is not supported for __shared__ variables`），那样就出不了 `.ll`。

---

## TMA 异步读的完整协议（三层逐条对上）

整个流程就 6 步，每步在三层里都能一一对应：

| 步骤 | 源码（`cuda::ptx::`） | PTX | SASS |
|---|---|---|---|
| 1. 初始化 mbarrier | `mbarrier_init(&bar,1)` | `mbarrier.init.shared.b64`（`.ptx:46`） | `SYNCS.EXCH.64`（`.sass:39`） |
| 2. 让 async proxy 看见初始化 | `fence_proxy_async(space_shared)` | `fence.proxy.async.shared::cta`（`.ptx:49`） | `MEMBAR.ALL.CTA`（`.sass:49`） |
| 3. 声明期望字节 + arrive | `mbarrier_arrive_expect_tx(…,2*BYTES)` | `mbarrier.arrive.expect_tx.…b64`（`.ptx:58`） | `SYNCS.ARRIVE.TRANS64`（`.sass:89`） |
| 4. **发起 TMA 读**（×2） | `cp_async_bulk(space_cluster,space_global,…)` | `cp.async.bulk.…complete_tx::bytes … // 1a. unicast`（`.ptx:66,72`） | `ELECT` + `UBLKCP.S.G`（`.sass:129/131`、`195/197`） |
| 5. 自旋等这一相完成 | `while(!mbarrier_try_wait_parity(&bar,0)){}` | `mbarrier.try_wait.parity.…b64`（`.ptx:81`） | `SYNCS.PHASECHK.TRANS64.TRYWAIT`（`.sass:215`） |
| 6. 读 shared → 加 → 写回 | `__hadd2(sa[i],sb[i])` | `ld.shared.u32` + `{add.f16x2}`（`.ptx:99-104`） | `LDS` + `HADD2` + `STG.E`（`.sass:255-267`） |

### 几个关键点

**TMA 读 = 一条 `UBLKCP.S.G`，由单线程发射。**
SASS 里每次 `cp.async.bulk` 落成 `UBLKCP.S.G [dst], [src], size`（**U**niform **BL**oc**K** **CP**y，`S.G` = Shared←Global），
前面紧跟一条 `ELECT`——硬件从 warp 里选一条 lane 来发射这条 uniform 指令（因为我们只让 `threadIdx.x==0` 发）。
两次拷贝就有两组 `ELECT`+`UBLKCP`（`.sass:129/131` 与 `195/197`）。
```
@P0  ELECT  P1, URZ, PT                       ; .sass:129  选出 leader lane
     UBLKCP.S.G [UR6], [UR4], UR8  ?WAIT12…   ; .sass:131  TMA：异步整块搬 global→shared
```
`?WAIT12_END_GROUP` 这类调度标记说明它是**异步**的——发射完不阻塞，完成与否靠 mbarrier。

**完成用 mbarrier 的「期望字节（tx-count）」机制，不是普通计数。**
`mbarrier_arrive_expect_tx(…, 2*BYTES)` 在 IR 里是 `i32 2048`（=2×1024 字节），告诉 barrier「这一相要等 2048 字节落地」。
TMA 每搬完一块就把已到字节累加，凑满 2048 且 arrive 数也够，相位（phase）才翻转。其它线程用
`mbarrier.try_wait.parity`（SASS 的 `SYNCS.PHASECHK.TRANS64.TRYWAIT`）自旋查这一相翻了没。

**IR 里 TMA 全是内联 asm。**
因为 `cuda::ptx::` 封装本身就是 `asm volatile(...)`，所以 `vadd_tma.ll` 里这些操作都是
`tail call … asm sideeffect "cp.async.bulk.… // 1a. unicast"`（`.ll:39,40`）之类——编译器不「理解」TMA，
只是把头文件给的 PTX 原样塞进去。这点和上个例子里 fp16 的 `{add.f16}` 是一回事：**16-bit 浮点运算、TMA，
在 CUDA 里都靠内联 PTX 兜底，不是编译器原生 IR。**

---

## half2：这次 `HADD2` 两道全用

```
ld.shared.u32  %r26, [%r30];          ; .ptx:99    一个 u32 = 一个 half2（两个 fp16）
{add.f16x2 %r25,%r26,%r27;            ; .ptx:104   打包加
```
```
LDS   R6, [R6]                         ; .sass:255  从 shared 取 half2
LDS   R7, [R7]                         ; .sass:261
HADD2 R9, R6, R7                       ; .sass:265  ← 两道全用，一条算两个 fp16
STG.E desc[UR6][R2.64], R9             ; .sass:267  普通 store 写回（只「读」用 TMA）
```

对照上个例子 [`../vector_add`](../vector_add) 里**标量** fp16：
```
HADD2 R5, R2.H0_H0, R5.H0_H0          ; vector_add 里：只用低半道 H0，另一道浪费
```
同一条 `HADD2` opcode，区别全在操作数修饰符：
- 标量 fp16：`R2.H0_H0`（把低 16-bit 那道复制到两道，实际只算一个有效结果）；
- 打包 half2：`R6`（整 32-bit 两道都是有效数据，一条指令出两个结果）。

**这就是红利兑现**：每条 `HADD2`、每次 `LDS`/`STG` 都满载，吞吐 ×2。要喂饱它，数据最好成块、对齐地搬进来——
正是 TMA 擅长的事，两件事天然配套。

## 读这些产物时盯什么

- `UBLKCP.S.G` + 前面的 `ELECT` → TMA 读由单线程发射的硬件指令；`?WAIT…` 标记 = 异步。
- `mbarrier.arrive.expect_tx` 的字节数（IR 里的 `i32 2048`） → tx-count 完成机制，不是线程到达计数。
- `SYNCS.PHASECHK.…TRYWAIT` → mbarrier 的相位自旋等待。
- IR 里 TMA/mbarrier 全是 `asm sideeffect "...// 序号"` → 编译器不原生支持，靠头文件内联 PTX。
- `HADD2` 后面有没有 `.H0_H0` → 区分标量 fp16（半道）vs 打包 half2（满道）。
- PTX 的 `// 1a. unicast` → 本机 sm_120 没有 multicast，这是单播 bulk copy。

## 环境

nvcc 12.8（conda，`/root/miniconda3`），clang-22（出 IR），真卡 RTX 5060 Ti（`sm_120`，Blackwell）。
本目录所有 `.ll`/`.ptx`/`.sass` 都是 `make artifacts`（全程 sm_120）生成的，可随时 `make clean` 重来。
