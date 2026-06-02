module {
  llvm.func @fused(%arg0: vector<16xf32>, %arg1: vector<16xf32>, %arg2: vector<16xf32>) -> vector<16xf32> {
    %0 = llvm.intr.fmuladd(%arg0, %arg1, %arg2) : (vector<16xf32>, vector<16xf32>, vector<16xf32>) -> vector<16xf32>
    llvm.return %0 : vector<16xf32>
  }
  llvm.func @separate(%arg0: vector<16xf32>, %arg1: vector<16xf32>, %arg2: vector<16xf32>) -> vector<16xf32> {
    %0 = llvm.fmul %arg0, %arg1 : vector<16xf32>
    %1 = llvm.fadd %0, %arg2 : vector<16xf32>
    llvm.return %1 : vector<16xf32>
  }
}

