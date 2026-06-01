# parallel_loops —— `--convert-linalg-to-parallel-loops`

和基线 [`../scf_loops/`](../scf_loops/README.md) 的差别:把 **m、n 两个 `parallel` 维**合成一个 **`scf.parallel`**
(显式声明「这两维可并行」),只有 k 这个 **`reduction` 维**仍是内层 `scf.for`。

分叉用的 pass:**`--convert-linalg-to-parallel-loops`**。

特征中间形态 `parallel.mlir`:

```mlir
scf.parallel (%arg3, %arg4) = (%c0, %c0) to (%c4, %c16) step (%c1, %c1) {   // m,n 一起并行
  scf.for %arg5 = %c0 to %c8 step %c1 {                                     // k 仍顺序归约
    ... arith.mulf / arith.addf ...
    memref.store %4, %arg2[%arg3, %arg4]
  }
  scf.reduce                                                               // scf.parallel 的终结符
}
```

回忆 `linalg.generic` 的 `iterator_types = ["parallel","parallel","reduction"]`——
**这条路径把那两个 `parallel` 直接兑现成了 `scf.parallel`**,语义上最贴近 named op 的原始标注。

但本例是**单线程降级**:`--convert-scf-to-cf` 把 `scf.parallel` 摊成普通顺序 CFG(不真起线程),
所以 `matmul.ll` 与 `scf_loops/matmul.ll` 逐字节相同。要真并行,得换 **`--convert-scf-to-openmp`**
(接 OpenMP runtime)或走 GPU 那套——并行信息留在中间形态里,等的就是这类后端。
