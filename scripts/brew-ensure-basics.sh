#!/usr/bin/env bash
set -euo pipefail

# 只在 macOS 或已安装 brew 的环境下干活
if ! command -v brew >/dev/null 2>&1; then
  echo "⚠️ 未找到 brew，跳过必备包检查。"
  echo "   （当前系统可能不是 macOS 或尚未安装 Homebrew）"
  exit 0
fi

PACKAGES=(
  autojump
  ffmpeg
  git
  lazygit
  stow
  tree
  wget
  zellij
)

missing=()

for pkg in "${PACKAGES[@]}"; do
  if ! brew list --formula "$pkg" >/dev/null 2>&1; then
    missing+=("$pkg")
  fi
done

if ((${#missing[@]} == 0)); then
  echo "✅ 必备 brew 包已全部安装。"
  exit 0
fi

echo "⬇️ 检测到缺少这些 brew 包，将自动安装： ${missing[*]}"
brew install "${missing[@]}"

echo "🍺 必备 brew 包已补齐。"