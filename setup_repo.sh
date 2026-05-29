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

echo ">>> Checking out commit: 43c02740abfaf87451063e5f69ff33a9fa9943be..."
cd /testbed/jupyterhub
git checkout 43c02740abfaf87451063e5f69ff33a9fa9943be

echo ">>> Repository setup complete."
