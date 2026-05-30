#!/bin/bash

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "安装系统依赖..."
apt-get update && apt-get install -y gcc build-essential python3-dev

print_status "安装python3.12..."
conda create -n testbed python=3.12 -y

print_status "激活环境.."
source activate testbed

# 设置国内镜像（加速，可按需注释）
mkdir -p ~/.pip
echo -e "[global]\nindex-url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pip/pip.conf

# 进入项目目录
cd /testbed/pymatgen

print_status "步骤 1: 优先应用 code.patch 和 test.patch 补丁..."
# 检查根目录下是否存在补丁文件，若存在则优先 apply 
if [ -f "/testbed/code.patch" ]; then
    print_status "应用代码修复补丁 code.patch..."
    git apply /testbed/code.patch
fi

if [ -f "/testbed/test.patch" ]; then
    print_status "应用测试用例补丁 test.patch..."
    git apply /testbed/test.patch
fi

print_status "步骤 2: 执行源码热补丁，根治旧代码与新版 monty.zopen() 的不兼容问题..."
# 补丁应用完成后，对所有相关源码执行 sed 替换，确保完全兼容新版 monty
# 1. 修复 structure.py 中的隐式 text 模式读取调用 (将 with zopen(filename) 显式改为 mode="rt")
sed -i 's/with zopen(filename) as file:/with zopen(filename, mode="rt") as file:/g' src/pymatgen/core/structure.py

# 2. 修复 io/gaussian.py 和 io/cif.py 等处写入时的隐式模式 (将 mode="w" 显式改为 mode="wt")
sed -i 's/with zopen(filename, mode="w") as file:/with zopen(filename, mode="wt") as file:/g' src/pymatgen/io/gaussian.py
sed -i 's/with zopen(filename, mode=mode) as file:/with zopen(filename, mode=mode if "t" in mode or "b" in mode else mode + "t") as file:/g' src/pymatgen/io/cif.py

print_status "步骤 3: 安装编译工具与依赖..."
pip install --upgrade pip setuptools wheel
pip install cython pymongo

print_status "步骤 4: 以可编辑模式安装 pymatgen 项目及其依赖..."
# 让 pip 自由安装 pyproject.toml 声明的最新合适 monty 版本，不会再引发依赖树冲突
pip install -e .

print_status "步骤 5: 安装测试所需的额外第三方库..."
pip install ase pytest

print_status "环境部署与补丁修复成功，准备执行 pytest 测试！"
