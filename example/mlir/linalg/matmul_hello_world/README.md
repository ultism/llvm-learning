# linalg.matmul —— 一个命名 op 怎么一层层降到 LLVM IR

MLIR 这条线的第一个例子,**定位是「hello world」——只把 pass 链跑通、看清逐层降到什么,
还没到 tile / vectorize 那些真正的特性展开**(留给后续例子)。前面 `llvm/` 那些例子是从 C
出发往下看 `.ll`/`.s`/`.ptx`/`.sass`；MLIR 在 LLVM IR **之上**又叠了好几层「方言（dialect）」,
这里拿 `linalg.matmul` 当样本,**从高层方言一路降到我们熟的 `.ll`**,每降一层看清它变成了什么。

> **全程只有一个手写源 `matmul.mlir`(tensor 版)。其余 `.mlir`/`.ll` 全是 pass 生成的——尤其
> memref 形态是 bufferization「生成」出来的,不是手写。** 用自编的 `mlir-opt` / `mlir-translate`
> (`llvm-project/build/bin/`,`23.0.0git`,与 submodule 同源;见仓库根 [AGENTS.md](../../../../AGENTS.md) 的「MLIR」小节)。

## `linalg.matmul` 怎么写

手写源是 **tensor(值语义)** 版:

```mlir
%0 = linalg.matmul ins(%A, %B : tensor<4x8xf32>, tensor<8x16xf32>)
                   outs(%C : tensor<4x16xf32>) -> tensor<4x16xf32>
```

- `ins` = 两个乘数;`outs` = **累加目标**,既是初值也是输出 —— 语义是 `C += A·B`,不是 `C = A·B`。
- 形状 `A[4x8]·B[8x16]=C[4x16]`,即 `M=4, N=16, K=8`。
- tensor 是值语义:不改输入,**产出一个新值 `%0`** 再 `return`。
- 它**只声明「这是矩阵乘」,不规定怎么算**(循环序、分块、向量化留给后续 pass)。这正是 linalg 的价值。

memref(buffer)形态长这样——但它是后面 **bufferize 生成**的,不在手写源里:

```mlir
linalg.matmul ins(%A, %B : memref<4x8xf32>, memref<8x16xf32>)
              outs(%C : memref<4x16xf32>)        // 原地写 C，无产出值
```

## 文件

| 文件 | 来历 | 内容 |
|---|---|---|
| `matmul.mlir` | **手写(唯一源)** | tensor 版命名 op |
| `matmul.generic.mlir` | 生成 | 旁支:泛化成 `linalg.generic`(露出语义,仍 tensor) |
| `matmul.bufferized.mlir` | 生成 | **① bufferize:tensor → memref** |
| `matmul.loops.mlir` | 生成 | ② memref → `scf` 三层循环 |
| `matmul.llvm-dialect.mlir` | 生成 | ③ 全程降到 LLVM dialect |
| `matmul.ll` | 生成 | ④ 真正的 LLVM IR(接回 `llvm/` 那条线) |
| `Makefile` | — | `generic`/`bufferize`/`loops`/`llvm`/`ll`/`artifacts`/`clean` |

主链:`matmul.mlir ──bufferize──▶ matmul.bufferized.mlir ──loops/llvm/ll──▶`。
`make artifacts` 一把重生成全部产物(都已入库);`make clean` 删所有生成物、只留 `matmul.mlir`。

---

## 旁支:`linalg.matmul` 的真身（`matmul.generic.mlir`）

`--linalg-generalize-named-ops`。`linalg.matmul` 五个字其实是下面这一整套的简写(仍是 tensor):

```mlir
#map  = affine_map<(d0, d1, d2) -> (d0, d2)>   // 取 A[m,k]
#map1 = affine_map<(d0, d1, d2) -> (d2, d1)>   // 取 B[k,n]
#map2 = affine_map<(d0, d1, d2) -> (d0, d1)>   // 取/写 C[m,n]
linalg.generic {indexing_maps = [#map, #map1, #map2],
                iterator_types = ["parallel", "parallel", "reduction"]}
  ins(%A, %B) outs(%C) {
^bb0(%in: f32, %in_0: f32, %out: f32):
  %1 = arith.mulf %in, %in_0 : f32      // C[m,n] += A[m,k]*B[k,n]
  %2 = arith.addf %out, %1   : f32      //   的内层一拍
  linalg.yield %2 : f32
}
```

三件事拼出矩阵乘的定义(迭代空间 `(d0,d1,d2)=(m,n,k)`):**三张 indexing map** = A/B/C 各自的下标公式;
**iterator_types** `[parallel, parallel, reduction]` —— m、n 并行,k 是**归约维**(累加沿 k 走);
**标量 body** = 内层那一拍 `mulf` 后 `addf` 到 `%out`。换 `linalg.matvec`/`conv_2d` 不过是换这套 map 和 iterator。

> 泛化停在 tensor,不需要 bufferize——它只是把语义摊开看,没换语义模型。

---

## 主链:四层下降,逐层对上

### ① tensor → memref:bufferization（`matmul.bufferized.mlir`）

`--one-shot-bufferize`(用 `identity-layout-map` 求干净的 `memref<MxNxf32>`)。**这一步才把值语义换成 buffer 语义,
memref 在这里第一次出现**——之前的 `.mlir` 里根本没有 memref:

```mlir
func.func @matmul(%arg0: memref<4x8xf32>, %arg1: memref<8x16xf32>,
                  %arg2: memref<4x16xf32>) -> memref<4x16xf32> {
  linalg.matmul ins(%arg0, %arg1 : ...) outs(%arg2 : ...)   // 无产出值，原地写 %arg2
  return %arg2 : memref<4x16xf32>
}
```

对比 tensor 源,变化全在「值语义 → buffer 语义」:
- `%0 = linalg.matmul … -> tensor` + `return %0`  ⟶  `linalg.matmul ins outs`(**无结果**)+ `return %arg2`。
  那个 `%0` 不是被删了,而是**坍缩进了对 `%arg2` buffer 的原地写**——值语义里显式命名的结果,在 buffer 语义里变成副作用。
- bufferize 分析后发现**可以直接复用 C 的 buffer 原地写**,于是没有 `alloc`/`copy`,直接把 `%arg2` 当结果还回去。
- 若换成纯 `C=A·B`(用 `tensor.empty()` 造 C、不接外部 C),bufferize 就**被迫**插入 `memref.alloc()` + `linalg.fill`(清零)——
  省下的工作不会凭空消失,只是推迟到这一步。

### ② → `scf` 循环:抽象逐字落地（`matmul.loops.mlir`）

`--convert-linalg-to-loops`。上面那套抽象**逐字**变成循环嵌套:

| 来自 generic 的 | 循环里变成（`matmul.loops.mlir`） |
|---|---|
| 迭代空间 `(m,n,k)` | 三层 `scf.for`:`%arg3`∈[0,4)=m、`%arg4`∈[0,16)=n、`%arg5`∈[0,8)=k(`:8-10`) |
| `reduction`(k) | **最内层**那层(累加沿它) |
| `#map (m,k)` 取 A | `memref.load %arg0[%arg3, %arg5]`(`:11`) |
| `#map1 (k,n)` 取 B | `memref.load %arg1[%arg5, %arg4]`(`:12`) |
| `#map2 (m,n)` 取/写 C | `load` + `store %arg2[%arg3, %arg4]`(`:13,16`) |
| body 的 `mulf`/`addf` | 原样的 `arith.mulf`/`arith.addf`(`:14-15`) |

一句话:**indexing map 就是下标公式,iterator type 就是循环结构**。上下界 `4/16/8` 来自 memref 的静态维度。

### ③ → LLVM dialect:memref 变成 descriptor struct（`matmul.llvm-dialect.mlir`）

完整 pass 序列(见 Makefile 的 `TO_LLVM`):`linalg→scf` / `scf→cf`(基本块) / `memref→descriptor` /
`func·arith·cf→llvm` / 收尾。两个关键变化:

- 每个 `memref<MxNxf32>` 被摊平成一个 **descriptor struct** `(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)`
  = (allocated ptr, aligned ptr, offset, sizes[2], strides[2]),靠一串 `llvm.insertvalue` 拼出来。
- `scf.for` 没了,变成 `llvm.br` / `llvm.cond_br` + 基本块(结构化循环 → 控制流图)。

### ④ → LLVM IR:接回 `.ll`（`matmul.ll`）

`mlir-translate --mlir-to-llvmir`。这一步才**跨出 MLIR**,落到我们在 `llvm/` 里读过的同一种 `.ll`:

```llvm
define { ptr, ptr, i64, [2 x i64], [2 x i64] } @matmul(ptr %0, ... i64 %20) {   ; :4
  br i1 %45, label %46, label %81                       ; :31 三层循环 → 三组 br i1（:31/:39/:47）
  %56 = mul nuw nsw i64 %44, 8                           ; :51 行偏移:A 是 4x8，行步长 8
  %66 = mul nuw nsw i64 %44, 16                          ; :61 行偏移:C 是 4x16，行步长 16
  %70 = fmul float %59, %64                              ; :65 A[m,k]*B[k,n]
  %71 = fadd float %69, %70                              ; :66 累加到 C[m,n]
  ret { ptr, ptr, i64, [2 x i64], [2 x i64] } %42        ; :84 返回 C 的 descriptor（bufferize 复用了 C）
```

- **入参 21 个** = 3 个 memref × 7 字段(descriptor 被摊成标量参数)。
- **返回值是个 struct** —— 因为函数返回一个 memref(③ 里那个 descriptor),tensor 源 `return %0` 一路活到这里,只是 `%0` 早已变成「C 的 buffer」。
- 三层 `scf.for` → 三组 `br i1` 条件跳转(`:31/:39/:47`)。
- `memref.load A[m,k]` 的二维下标 → 一维线性地址 `行号×行步长 + 列号`,所以满屏 `mul nuw nsw …, 8` / `…, 16`(8、16 正是 A、C 的行步长)。
- 内层那拍 → `fmul float` / `fadd float`,和直接写 C 编出来的 `.ll` 已一模一样。

---

## 读这些产物时盯什么

- `linalg.generic` 的 **indexing_maps + iterator_types** —— named op 的语义全在这;`reduction` 标的就是归约维。
- **bufferize 前后**:tensor 的 `%0`/`return %0` 怎么坍缩成 memref 的原地写 + `return %arg2`;能复用 C 就不 alloc,不能复用才长出 `alloc`+`fill`。**memref 是这一步生成的,不是天上掉的。**
- `--convert-linalg-to-loops` 后,map 变下标、iterator 变循环嵌套 —— 抽象到循环的对应关系。
- LLVM dialect 里的 **descriptor struct** `(ptr,ptr,i64,array,array)` —— memref 的运行时表示(指针+offset+sizes+strides)。
- `.ll` 里 `@matmul` 的**参数个数**(memref 数 × 7)、**返回 struct**、满屏 `mul …, <行步长>` —— 二维 memref 怎么摊成一维地址、怎么按 ABI 传递。
- 同一拍 `fmul`/`fadd` 一路从 `arith.mulf`/`addf` 活到 LLVM IR —— 计算本身没变,变的全是「怎么寻址、怎么循环、用哪块内存」的外壳。

## 下一步能玩什么

这里走的是**最朴素**的降法(直降三层 for)。linalg 真正的看家本事是**调度**:
- `--linalg-tile`(分块)、`--linalg-vectorize`(向量化)—— 看同一个 `linalg.matmul` 怎么被调成 tiled / vectorized 的循环;
- bufferization 本身也是一大块(in-place 分析、`alloc`/`copy` 插入、函数边界),值得单独开一个例子细看。
- 这才是 MLIR 比直接手写 `.ll` 强的地方:语义(matmul)和调度(怎么跑)分开,各自独立变换。

## 环境

自编 `mlir-opt` / `mlir-translate`(`llvm-project/build/bin/`,LLVM `23.0.0git` + assertions,与 submodule 同 commit)。
`make clean` 删全部生成物(只留 `matmul.mlir`),`make artifacts` 重生成。
