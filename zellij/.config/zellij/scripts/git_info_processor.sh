#!/bin/bash
# 脚本用于组合分支名和修改状态计数，并去除多余空格。
# 输出示例：#[fg=#f9e2af] main #[fg=#a6e3a1]●1 #[fg=#fe640b]M2

# 获取分支名
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# 如果不在 Git 仓库中，输出空字符串
if [ -z "$BRANCH" ]; then
    printf ""
    exit 0
fi

# 获取状态计数，并使用 tr -d '[:space:]' 清除 wc -l 输出的空格
STAGED_COUNT=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d '[:space:]')
UNSTAGED_COUNT=$(git diff --numstat 2>/dev/null | wc -l | tr -d '[:space:]')
UNTRACKED_COUNT=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d '[:space:]')

OUTPUT=""

# 1. 拼接分支名 (使用 Catppuccin Yellow #f9e2af)
# 开头有一个空格，用于与左侧区块分隔
OUTPUT="${OUTPUT} #[fg=#f9e2af] ${BRANCH}"

# 2. 拼接已暂存状态 (●)
if [ "$STAGED_COUNT" -gt 0 ]; then
    # 使用绿色 #a6e3a1
    OUTPUT="${OUTPUT} #[fg=#a6e3a1]●${STAGED_COUNT}"
fi

# 3. 拼接未暂存状态 (M)
if [ "$UNSTAGED_COUNT" -gt 0 ]; then
    # 使用橙色 #fe640b
    OUTPUT="${OUTPUT} #[fg=#fe640b]M${UNSTAGED_COUNT}"
fi

# 4. 拼接未跟踪状态 (?)
if [ "$UNTRACKED_COUNT" -gt 0 ]; then
    # 使用红色 #f38ba8
    OUTPUT="${OUTPUT} #[fg=#f38ba8]?${UNTRACKED_COUNT}"
fi

# 最终输出：使用 printf "%s" 确保没有尾随换行符或空格
printf "%s" "$OUTPUT"