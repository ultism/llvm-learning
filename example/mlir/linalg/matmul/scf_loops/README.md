# scf_loops —— `--convert-linalg-to-loops`(基线)

最朴素的降法,和 [`../../matmul_hello_world/`](../../matmul_hello_world/README.md) 主链同一条。放在这里当**对照基线**:
其余三条路径都拿「和它差在哪」来讲。

分叉用的 pass:**`--convert-linalg-to-loops`**(bufferize 之后)。

特征中间形态 `loops.mlir`:三层 **`scf.for`**,`%arg3`=m∈[0,4)、`%arg4`=n∈[0,16)、`%arg5`=k∈[0,8) 最内层(归约):

```mlir
scf.for %arg3 = %c0 to %c4 step %c1 {           // m
  scf.for %arg4 = %c0 to %c16 step %c1 {        // n
    scf.for %arg5 = %c0 to %c8 step %c1 {       // k（归约，最内）
      %0 = memref.load %arg0[%arg3, %arg5]      // A[m,k]
      %1 = memref.load %arg1[%arg5, %arg4]      // B[k,n]
      %2 = memref.load %arg2[%arg3, %arg4]      // C[m,n]
      %3 = arith.mulf %0, %1 : f32
      %4 = arith.addf %2, %3 : f32
      memref.store %4, %arg2[%arg3, %arg4]      // 写回 C[m,n]
} } }
```

最终 `matmul.ll`(89 行):标量 `fmul float`/`fadd float`,`scf.for` → 三组 `br i1` 条件跳转。
**`affine_loops`、`parallel_loops` 两条的 `.ll` 与本文件逐字节相同**(见上级 README 的结论)。
