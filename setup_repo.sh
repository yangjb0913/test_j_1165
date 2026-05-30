#!/bin/bash
set -euo pipefail

REPO_URL="https://github.com/jupyterhub/jupyterhub.git"
REPO_DIR="/testbed/jupyterhub"
COMMIT_SHA="8a30f015c9a8ef4714a1e44dc9cdd87e23ab0abc"

mkdir -p "$(dirname "$REPO_DIR")"

if [ ! -d "$REPO_DIR/.git" ]; then
  echo ">>> Cloning repository: ${REPO_URL}..."
  git clone "$REPO_URL" "$REPO_DIR"
else
  echo ">>> Repository already exists. Refreshing remote origin..."
  git -C "$REPO_DIR" remote set-url origin "$REPO_URL"
fi

echo ">>> Fetching commit: ${COMMIT_SHA}..."
git -C "$REPO_DIR" fetch --tags --prune origin "$COMMIT_SHA"
git -C "$REPO_DIR" checkout --force "$COMMIT_SHA"
git -C "$REPO_DIR" reset --hard "$COMMIT_SHA"
git -C "$REPO_DIR" clean -fdx

echo "Repository ready at ${REPO_DIR}"
