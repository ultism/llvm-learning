#include <stddef.h>

/*
 * 间接/聚集访问:每条 lane 的地址由 idx[i] 决定,互不相邻 → 必须 gather。
 * 这是生成"向量 GEP(<N x ptr>) + llvm.masked.gather"的最干净的数学模式。
 *
 * ★ restrict 是关键:不加的话编译器无法证明 x[idx[i]] 不和 y 别名,
 *   会以 "cannot identify array bounds" 拒绝向量化,退化成标量。
 */
void gather_index(const float *restrict x, const int *restrict idx,
                  float *restrict y, size_t n)
{
    for (size_t i = 0; i < n; i++)
        y[i] = x[idx[i]];
}
