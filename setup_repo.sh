#!/bin/bash
set -e
if [ -d "/testbed" ]; then
    rm -rf /testbed
fi
# 创建 testbed 目录
mkdir -p /testbed

echo ">>> Cloning repository: jupyterhub/jupyterhub..."
# Clone 代码到 /testbed/repo_name
git config --global http.sslVerify false
git clone https://github.com/jupyterhub/jupyterhub.git /testbed/jupyterhub

echo ">>> Checking out commit: 3bb82ea330a33bfaf5d117590d1a3bf212dca575..."
cd /testbed/jupyterhub
git checkout 3bb82ea330a33bfaf5d117590d1a3bf212dca575

echo ">>> Repository setup complete."
