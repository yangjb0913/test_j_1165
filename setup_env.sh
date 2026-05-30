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
# 验证版本
# python -V

#设置国内镜像，加速，发布时请注释掉
mkdir -p ~/.pip
echo -e "[global]\nindex-url = https://mirrors.aliyun.com/pypi/simple/" > ~/.pip/pip.conf
# mkdir -p ~/.config/uv
# echo -e '[[index]]\nurl = "https://mirrors.aliyun.com/pypi/simple" \ndefault=true ' > ~/.config/uv/uv.toml

#进入项目目录
cd /testbed/pymatgen

print_status "安装基础编译与环境依赖..."
pip install --upgrade pip setuptools wheel
pip install cython

# 提前安装 pymongo 补全 bson 支持
pip install pymongo

print_status "同时安装项目与约束依赖（方案A）..."
# 关键修复点：将项目安装与 monty 的旧版本约束合并到同一条 pip 命令中。
# 这样 pip 依赖解析器会同时计算两个条件，迫使安装满足要求的旧版 monty，绝对不会升级到最新版。
pip install -e . "monty<2024.10.21"

print_status "安装剩余测试包..."
pip install ase
pip install pytest

# print_status "增加源码目录设置!"
# echo 'export PYTHONPATH=$PYTHONPATH:/testbed/pymatgen/src' >> /root/.bashrc
