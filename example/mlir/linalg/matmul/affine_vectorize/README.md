# affine_vectorize —— affine 循环 + `--affine-super-vectorize`(唯一改了 `.ll` 的路径)

建在 [`../affine_loops/`](../affine_loops/README.md) 之上:先 `--convert-linalg-to-affine-loops` 出 affine 循环,
再 **`--affine-super-vectorize="virtual-vector-size=8 vectorize-reductions=true"`** 把它向量化。
这是四条里**唯一**最终 `matmul.ll` 真正变样的——前三条都收敛成同一份标量 IR,这条才动了「调度」。

特征中间形态 `vector.mlir`:N 维(`%arg4`)按 **`step 8`** 切,算子全升成 **`vector<8xf32>`**:

```mlir
#map = affine_map<(d0, d1) -> (0)>                    // A 的广播映射：把标量摊成一整条向量
affine.for %arg4 = 0 to 16 step 8 {                   // N 维一次算 8 列
  affine.for %arg5 = 0 to 8 {
    %1 = vector.transfer_read %arg0[...] {permutation_map = #map} : ..., vector<8xf32>   // A[m,k] 广播成 splat
    %3 = vector.transfer_read %arg1[%arg5, %arg4] : ..., vector<8xf32>                    // B[k, n:n+8]
    %5 = vector.transfer_read %arg2[%arg3, %arg4] : ..., vector<8xf32>                    // C[m, n:n+8]
    %6 = arith.mulf %1, %3 : vector<8xf32>
    %7 = arith.addf %5, %6 : vector<8xf32>
    vector.transfer_write %7, %arg2[%arg3, %arg4] : vector<8xf32>, ...
} }
```

降到 `matmul.ll`(123 行,比标量多 30+ 行)多出来的两步与对应指令:

- `--convert-vector-to-scf`:`vector.transfer_read/write` 拆成带掩码的访存(填充用到 `ub.poison`,
  故收尾要加 `--convert-ub-to-llvm`);
- `--convert-vector-to-llvm`:落成真 SIMD。`.ll` 里能看到:
  - `fmul <8 x float>` / `fadd <8 x float>` —— 一拍算 8 个乘加;
  - `insertelement` + `shufflevector`(splat)—— A[m,k] 那个标量广播成 `<8 x float>`(对应 `#map` 的 `-> (0)`);
  - `@llvm.masked.load.v8f32` / `@llvm.masked.store.v8f32` —— B、C 的整条向量读写。

对照组意义:换循环方言(scf/affine/parallel)不改 `.ll`,**真正改写最终指令的是向量化这种「调度」变换**。
这就是 MLIR「语义与调度分离」的价值——同一个 `matmul.mlir`,不动语义,只换调度就能从标量切到 SIMD。
