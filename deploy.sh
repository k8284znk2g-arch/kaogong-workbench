#!/usr/bin/env bash
# 一键部署考公工作台到 GitHub Pages
# 用法：bash deploy.sh
set -e

REPO_NAME="kaogong-workbench"

echo "==> 检查 GitHub 登录状态..."
if ! gh auth status >/dev/null 2>&1; then
  echo "尚未登录 GitHub，正在启动登录流程..."
  gh auth login --web --git-protocol https
fi

USER=$(gh api user --jq .login)
echo "==> 当前账号：$USER"

echo "==> 创建仓库 $REPO_NAME（公开）..."
gh repo create "$REPO_NAME" --public --confirm 2>/dev/null || echo "仓库已存在，继续"

echo "==> 初始化并推送代码..."
rm -rf .git
git init -b main
git add .
git commit -m "feat: 考公工作台 PWA 首次部署"
git remote add origin "https://github.com/$USER/$REPO_NAME.git"
git push -u origin main --force

echo "==> 开启 GitHub Pages（Actions 模式）..."
gh api -X POST "/repos/$USER/$REPO_NAME/pages" \
  -f build_type=workflow 2>/dev/null || \
gh api -X PUT "/repos/$USER/$REPO_NAME/pages" \
  -f build_type=workflow

echo "==> 触发首次部署..."
gh workflow run deploy.yml -R "$USER/$REPO_NAME" || true

echo
echo "==============================================="
echo "✅ 部署已启动！"
echo "公开链接（1~2 分钟后生效）："
echo "  https://$USER.github.io/$REPO_NAME/"
echo "==============================================="
echo
echo "查看部署进度："
echo "  gh run watch -R $USER/$REPO_NAME"
