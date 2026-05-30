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

echo "Fixing potentially broken apt packages..."
apt-get install -f -y || true

if conda env list | awk '{print $1}' | grep -qx "${ENV_NAME}"; then
  echo "Removing existing environment ${ENV_NAME}..."
  conda env remove -y -n "${ENV_NAME}"
fi

echo "Creating standard virtual environment via Conda..."
conda create -y -n "${ENV_NAME}" \
    "python=${PYTHON_VERSION}" \
    "nodejs>=18" \
    "configurable-http-proxy" \
    -c conda-forge

conda activate "${ENV_NAME}"

cd "${REPO_DIR}"

echo "Installing compatible testing framework versions..."
pip install --upgrade "pip<24" "setuptools<70" "wheel"
pip install "pytest<8.0" "anyio<4.0" "pytest-asyncio==0.21.1"

pip install -r requirements.txt -r dev-requirements.txt "SQLAlchemy<2.0" "greenlet<2" pycurl

pip install -e .

SINGLEUSER_ENTRY=$(which jupyterhub-singleuser)
if [[ -n "${SINGLEUSER_ENTRY}" ]]; then
    echo "Patching jupyterhub-singleuser entry to auto inject --allow-root"
    cp -f "${SINGLEUSER_ENTRY}" "${SINGLEUSER_ENTRY}.bak"

    cat > "${SINGLEUSER_ENTRY}" << 'PY_ENTRY'
#!/usr/bin/env python
import sys
if "--allow-root" not in sys.argv:
    sys.argv.insert(1, "--allow-root")

def main():
    import runpy
    runpy.run_module("jupyterhub.singleuser", run_name="__main__", alter_sys=True)

if __name__ == "__main__":
    main()
PY_ENTRY

    chmod +x "${SINGLEUSER_ENTRY}"
fi

export JUPYTERHUB_SPAWN_TIMEOUT=60
export PYTEST_TIMEOUT=60

echo "Environment ${ENV_NAME} ready."
