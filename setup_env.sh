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

conda create -y -n "${ENV_NAME}" "python=${PYTHON_VERSION}"
conda activate "${ENV_NAME}"

cd "${REPO_DIR}"

# Keep packaging tooling compatible with older dependencies.
pip install --upgrade "pip<24" "setuptools<70" "wheel"

# Install runtime and development requirements for testing with SQLAlchemy pinned to 1.x.
pip install -r requirements.txt -r dev-requirements.txt "SQLAlchemy<2.0" "greenlet<2"

# Install the repository in editable mode.
pip install -e .

echo "Environment ${ENV_NAME} ready."
