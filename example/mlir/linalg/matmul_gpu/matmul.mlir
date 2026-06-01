// linalg.matmul —— 命名 op（named op），tensor（值语义）版本
//
// ins  = 两个乘数 A、B
// outs = 累加目标 C（既是初值也是输出，所以语义是 C += A·B，不是 C = A·B）
// tensor 版返回一个新的 tensor（不原地改），契合 SSA / 值语义。
//
// 形状：A[4x8] · B[8x16] = C[4x16]，即 M=4, N=16, K=8。
func.func @matmul(%A: tensor<4x8xf32>, %B: tensor<8x16xf32>,
                  %C: tensor<4x16xf32>) -> tensor<4x16xf32> {
  %0 = linalg.matmul
         ins(%A, %B : tensor<4x8xf32>, tensor<8x16xf32>)
         outs(%C : tensor<4x16xf32>) -> tensor<4x16xf32>
  return %0 : tensor<4x16xf32>
}
