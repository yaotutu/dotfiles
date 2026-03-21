#!/bin/bash
# 获取 Mac 电池信息
BATT_INFO=$(pmset -g batt)
# 提取百分比数字
PERCENTAGE=$(echo "$BATT_INFO" | grep -o '[0-9]\{1,3\}%')

# 判断是否连接了电源 (AC Power)
if echo "$BATT_INFO" | grep -q "AC Power"; then
    echo "⚡ $PERCENTAGE"
else
    echo "🔋 $PERCENTAGE"
fi