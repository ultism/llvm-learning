#!/usr/bin/env python3
"""从 `mlir-opt --gpu-module-to-binary=format=isa` 的输出里抠出干净 PTX。

PTX 被嵌在 gpu.binary 的 `assembly = "..."` 字符串里，换行等非打印字符被转义成
\\XX 十六进制（如换行 = \\0A）。本脚本读 stdin（gpu.binary 形式的 MLIR），
解转义后把纯 PTX 写到 stdout。
"""
import sys, re

data = sys.stdin.read()
m = re.search(r'assembly = "', data)
if not m:
    sys.exit("没在 gpu.binary 里找到 PTX（assembly 字符串）")
start = m.end()
end = data.index('"', start)   # 内部引号都被转义成 \22，故首个「裸 "」即字符串终止
body = data[start:end]
# 解 \XX 十六进制转义（\0A→换行、\09→制表符 等）
sys.stdout.write(re.sub(r'\\([0-9A-Fa-f]{2})', lambda mm: chr(int(mm.group(1), 16)), body))
