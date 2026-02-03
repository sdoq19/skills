#!/bin/bash

# Claude Skills 备份脚本
# 用于将本地 ~/.claude/skills 同步到本仓库并推送到 GitHub

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "======================================"
echo "  Claude Skills 备份脚本"
echo "======================================"
echo ""

# 1. 复制本地 skills 到仓库
echo "[1/3] 复制本地 skills..."
cp -r ~/.claude/skills/* .

# 2. 更新 README 中的日期
echo "[2/3] 更新 README 日期..."
TODAY=$(date +%Y-%m-%d)
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/\*\*最后更新\*\*: [0-9]*/**最后更新**: $TODAY/" README.md
else
    # Linux/Git Bash
    sed -i "s/\*\*最后更新\*\*: [0-9]*/**最后更新**: $TODAY/" README.md
fi

# 3. 提交并推送
echo "[3/3] 提交并推送到 GitHub..."
git add .
git commit -m "Update skills backup - $TODAY

Co-Authored-By: Claude <noreply@anthropic.com>"
git push

echo ""
echo "======================================"
echo "  备份完成！"
echo "======================================"
