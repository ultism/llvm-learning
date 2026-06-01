// transform 调度：把 matmul.mlir 里的 linalg.matmul 向量化成 vector.contract。
// 用 --transform-preload-library=transform-library-paths=schedule.mlir 外挂，
// 再 --transform-interpreter 执行（入口默认 @__transform_main）。
//
// 关键点：transform.structured.vectorize 默认只把 matmul 向量化到 vector.multi_reduction，
// convert-vector-to-gpu 不认。必须再 apply 一组 "prepare patterns"——尤其
// reduction_to_contract——把 multi_reduction 抬成 vector.contract，WMMA 转换才接得上。
module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%root: !transform.any_op {transform.readonly}) {
    %m = transform.structured.match ops{["linalg.matmul"]} in %root
         : (!transform.any_op) -> !transform.any_op
    %f = transform.get_parent_op %m {op_name = "func.func"}
         : (!transform.any_op) -> !transform.any_op
    transform.structured.vectorize %m : !transform.any_op
    transform.apply_patterns to %f {
      transform.apply_patterns.vector.reduction_to_contract          // ← multi_reduction → vector.contract（关键）
      transform.apply_patterns.vector.transfer_permutation_patterns
      transform.apply_patterns.vector.lower_masked_transfers
    } : !transform.any_op
    transform.yield
  }
}
