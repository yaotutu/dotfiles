#!/bin/sh

# Google的Nerd Fonts图标
google_icon=""
no_connection_icon=""  # 使用 Nerd Fonts 的断网图标

# 颜色定义
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
RESET="\033[0m"

# 输出文件定义
output_file="check_google.log"

# 获取当前时间 (只需要小时和分钟)
current_time=$(date "+%H:%M")

# 检测 Google 的可访问性，并跟随重定向
curl_result=$(curl -s -L -I -o /dev/null -w "%{http_code}:%{time_total}" https://www.google.com)

# 提取状态码和延迟时间
http_code=$(echo "$curl_result" | cut -d':' -f1)
rtt=$(echo "$curl_result" | cut -d':' -f2)

# 函数：根据延迟时间设置颜色
get_color_based_on_rtt() {
  local rtt_ms=$1
  if (( $(echo "$rtt_ms < 100" | bc -l) )); then
    echo "$GREEN"
  elif (( $(echo "$rtt_ms < 500" | bc -l) )); then
    echo "$YELLOW"
  else
    echo "$RED"
  fi
}

if [ "$http_code" = "200" ]; then
  # 将延迟时间转换为毫秒
  rtt_ms=$(printf "%.3f" $(echo "$rtt * 1000" | bc -l))
  color=$(get_color_based_on_rtt $rtt_ms)
  output="${color}${google_icon} ${rtt_ms} ms${RESET}"
  echo -e "$output"
  echo  "$current_time - $output" >> "$output_file"
else
  # curl 失败，显示没有连接状态
  output="${RED}${no_connection_icon} No connection${RESET}"
  echo -e "$output"
  echo  "$current_time - $output" >> "$output_file"
fi
