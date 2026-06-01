# affine_loops —— `--convert-linalg-to-affine-loops` + `--lower-affine`

和基线 [`../scf_loops/`](../scf_loops/README.md) 同样是三层标量循环,**只是先落在 `affine` 方言**。

分叉用的 pass:**`--convert-linalg-to-affine-loops`**;之后多一步 **`--lower-affine`** 把 affine 拆成 `arith`+`scf`,再走共用收尾。

特征中间形态 `affine.mlir`:三层 **`affine.for`**,访存是 **`affine.load`/`affine.store`**(上下界、下标都直接写成整数仿射式):

```mlir
affine.for %arg3 = 0 to 4 {            // 注意：上下界是字面量，不像 scf 要先 arith.constant
  affine.for %arg4 = 0 to 16 {
    affine.for %arg5 = 0 to 8 {
      %0 = affine.load %arg0[%arg3, %arg5] : memref<4x8xf32>   // 下标是仿射表达式，不是普通 SSA 值
      ...
      affine.store %4, %arg2[%arg3, %arg4] : memref<4x16xf32>
} } }
```

与 scf 的真正区别**不在最终代码**(`matmul.ll` 与 `scf_loops/matmul.ll` 逐字节相同),而在**这一层能做什么**:
`affine` 把循环边界和下标限定成仿射式,于是可以上**多面体分析**——分块(`--affine-loop-tile`)、向量化
(`--affine-super-vectorize`,见 [`../affine_vectorize/`](../affine_vectorize/README.md))都建在这层之上。
`--lower-affine` 一拆,这些结构信息就没了,降到 `.ll` 自然和 scf 收敛到同一份。
