#!/bin/bash
set -e

cd /testbed/jupyterhub

pip install --upgrade pip
pip install pytest==6.2.5 pytest-xdist

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
. /root/.nvm/nvm.sh
nvm install 6; nvm use 6
npm install
npm install -g configurable-http-proxy@1.3.0

pip install --pre -r dev-requirements.txt . "tornado<5.0"
