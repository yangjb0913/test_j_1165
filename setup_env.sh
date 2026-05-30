#!/bin/bash
set -euo pipefail

ENV_NAME="testbed"
PYTHON_VERSION="3.9"
REPO_DIR="/testbed/jupyterhub"

if [ ! -d "/opt/miniconda3" ]; then
  echo "Miniconda not found at /opt/miniconda3"
  exit 1
fi

source /opt/miniconda3/etc/profile.d/conda.sh

# Recreate the environment to ensure consistency.
if conda env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  conda env remove -y -n "${ENV_NAME}"
fi

# 【2026.5.29-Edit】在创建环境时直接拉取 nodejs 和官方编译好的 proxy
conda create -y -n "${ENV_NAME}" "python=${PYTHON_VERSION}" nodejs configurable-http-proxy
conda activate "${ENV_NAME}"

cd "${REPO_DIR}"

# Keep packaging tooling compatible with older dependencies.
pip install --upgrade "pip<24" "setuptools<70" "wheel"

# Install runtime and development requirements for testing with SQLAlchemy pinned to 1.x.
pip install -r requirements.txt -r dev-requirements.txt "SQLAlchemy<2.0" "greenlet<2"

# ====================================================================
# 【新增修复】强制降级 pytest 到 7.4.x 版本，以兼容旧版 JupyterHub 的测试语法
# 这样可以防止 pytest 8.x 遇到 pytest.warns(None) 时抛出 TypeError 导致测试卡死
# ====================================================================
pip install "pytest<8.0.0" "pytest-asyncio<0.23.0"

# Install the repository in editable mode.
pip install -e .

echo "Environment ${ENV_NAME} ready."
