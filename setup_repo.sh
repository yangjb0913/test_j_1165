#!/bin/bash
set -e

mkdir -p /testbed
git clone --filter=blob:none --no-checkout https://github.com/jupyterhub/jupyterhub /testbed/jupyterhub
cd /testbed/jupyterhub
git checkout "6810aba5e9105b97a2d04eea705a4aef9f944ebb"
cd ..
