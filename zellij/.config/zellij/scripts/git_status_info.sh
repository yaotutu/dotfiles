#!/bin/bash
# 脚本用于计算 Git 的超前(Push)和滞后(Pull)数量，并使用 zjstatus 颜色代码格式化输出。

AHEAD=$(git rev-list --count @{u}..HEAD 2>/dev/null)
BEHIND=$(git rev-list --count HEAD..@{u} 2>/dev/null)

OUTPUT=""

if [ "$AHEAD" -gt 0 ]; then
  # 粉色 #f0c6c6 for PUSH (超前)
  OUTPUT="${OUTPUT} #[fg=#f0c6c6]↑${AHEAD}"
fi

if [ "$BEHIND" -gt 0 ]; then
  # 蓝色 #8aadf4 for PULL (滞后)
  OUTPUT="${OUTPUT} #[fg=#8aadf4]↓${BEHIND}"
fi

# 输出结果，如果为空则输出空字符串
echo -e "${OUTPUT}"