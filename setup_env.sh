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

# 修改点：在创建环境时，顺便安装 nodejs 和 configurable-http-proxy (来自 conda-forge)
conda create -y -n "${ENV_NAME}" "python=${PYTHON_VERSION}" nodejs configurable-http-proxy -c conda-forge
conda activate "${ENV_NAME}"

cd "${REPO_DIR}"

# Keep packaging tooling compatible with older dependencies.
pip install --upgrade "pip<24" "setuptools<70" "wheel"

# Install runtime and development requirements for testing with SQLAlchemy pinned to 1.x.
# 顺便追加安装了 pycurl 解决你之前日志里的 pycurl 缺失警告
pip install -r requirements.txt -r dev-requirements.txt "SQLAlchemy<2.0" "greenlet<2" pycurl

# Install the repository in editable mode.
pip install -e .

echo "Environment ${ENV_NAME} ready."