#!/bin/bash

# 如果不在 Git 仓库中，直接退出
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    exit 0
fi

# 获取当前分支名
BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

# 检查是否有未提交的修改 (Dirty 状态)
if [ -n "$(git status --porcelain)" ]; then
    DIRTY=" 󰄬" # 显示一个小钩子或星号，代表有改动
else
    DIRTY=""
fi

# 检查是否领先于远程分支 (未推送)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
if [ -n "$UPSTREAM" ]; then
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse "$UPSTREAM")
    if [ "$LOCAL" != "$REMOTE" ]; then
        UNPUSHED=" 󰑬" # 显示一个向上的箭头，代表待推送
    fi
fi

# 输出格式化内容 (例如: main 󰄬 󰑬)
echo " $BRANCH$DIRTY$UNPUSHED"