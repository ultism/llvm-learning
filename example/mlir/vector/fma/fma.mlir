// 两个数学上等价（都算 a*b+c）、但「融合性」表达不同的函数。
//   @fused    : 用 vector.fma —— 结构化地表达「这是一个融合乘加」
//   @separate : 用 arith.mulf + arith.addf —— 两个相互独立的运算
//
// 看点：同样降到 x86，
//   @fused    严格 FP 下也能拿到一条 vfmadd（因为 vector.fma 自带「可融合」语义）；
//   @separate 严格 FP 下后端不敢融（会改舍入），拆成 vmulps + vaddps。
//
// vector<16xf32> = 512 bit = 一个 zmm 寄存器。

func.func @fused(%a: vector<16xf32>, %b: vector<16xf32>, %c: vector<16xf32>) -> vector<16xf32> {
  %0 = vector.fma %a, %b, %c : vector<16xf32>
  return %0 : vector<16xf32>
}

func.func @separate(%a: vector<16xf32>, %b: vector<16xf32>, %c: vector<16xf32>) -> vector<16xf32> {
  %0 = arith.mulf %a, %b : vector<16xf32>
  %1 = arith.addf %0, %c : vector<16xf32>
  return %1 : vector<16xf32>
}
