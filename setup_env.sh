#!/bin/bash
set -e
set -x

WORK_DIR="/testbed"
REPO_NAME="jupyterhub"
REPO_WORK_DIR="$WORK_DIR/$REPO_NAME/"

#export PYTHONPATH="$REPO_WORK_DIR"

cd "$WORK_DIR"

# Configure conda mirror
cat > ~/.condarc << 'EOF'
channels:
  - conda-forge
channel_priority: strict
show_channel_urls: true
channel_alias: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF

# --- activate Python conda env ---
source activate
# conda create -n testbed -y python=3.6
conda activate base
pip install --upgrade pip

# fix old jupyter install newest version dependency
pip install MarkupSafe==0.23 jinja2==2.8 pamela==0.3.0 requests==2.10.0 --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple
# fix newest notebook download slow and need old notebook
pip install notebook==4.2.0 --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple

# Install project dependencies
# install correct version
req_files=(
    "$WORK_DIR/$REPO_NAME/requirements.txt"
    "$WORK_DIR/$REPO_NAME/dev-requirements.txt"
    "$WORK_DIR/$REPO_NAME/editable-requirements.txt"
)


for file in "${req_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "文件不存在，跳过: $file"
        continue
    fi

    cp "$file" "$file.bak"
    echo "备份完成: $file -> $file.bak"
	# requests>=2.0.1 ==> requests==2.0.1
    sed -E -i 's/^([a-zA-Z0-9_.-]+(\[[^]]+\])?)\s*(>=|~=)\s*([^,<;\s]+).*/\1==\4/' "$file"
    echo "处理完成: $file"
done

# install dependency
cd "$WORK_DIR/$REPO_NAME/"

[ -f "$WORK_DIR/$REPO_NAME/requirements.txt" ] && \
pip install -r "$WORK_DIR/$REPO_NAME/requirements.txt" --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple

[ -f "$WORK_DIR/$REPO_NAME/dev-requirements.txt" ] && \
pip install -r "$WORK_DIR/$REPO_NAME/dev-requirements.txt" --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple

[ -f "$WORK_DIR/$REPO_NAME/editable-requirements.txt" ] && \
pip install -r "$WORK_DIR/$REPO_NAME/editable-requirements.txt" --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple

# install project
cd "$REPO_WORK_DIR"
pip install -e "$REPO_WORK_DIR" --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple

# fix pytest too old
pip install pytest==3.10.1 mock==4.0.3 --trusted-host pypi.tuna.tsinghua.edu.cn -i https://pypi.tuna.tsinghua.edu.cn/simple
# fix dependencies conflict error
pip install --force-reinstall nbformat==5.0.2 -i https://pypi.tuna.tsinghua.edu.cn/simple  --no-deps
# fix start main process error
pip install --force-reinstall tornado==4.5.3 -i https://pypi.tuna.tsinghua.edu.cn/simple  --no-deps
# fix error start no http_uri
pip install --force-reinstall traitlets==4.3.1 -i https://pypi.tuna.tsinghua.edu.cn/simple  --no-deps
# fix error start main process error
pip install --force-reinstall sqlalchemy==1.0.12 -i https://pypi.tuna.tsinghua.edu.cn/simple  --no-deps
# fix dependencies conflict error
pip install --force-reinstall ipython==4.0.2 -i https://pypi.tuna.tsinghua.edu.cn/simple --no-deps
 

# install js dependencies
rm -rf ~/.cache ~/.npm

cd "$WORK_DIR/$REPO_NAME/"