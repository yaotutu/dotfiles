#!/bin/sh

# Ping Google DNS server to test connectivity
ping_result=$(ping -c 1 -W 1 8.8.8.8 2>&1)

if [ $? -eq 0 ]; then
  # 提取延迟时间
  rtt=$(echo "$ping_result" | grep 'time=' | awk -F 'time=' '{print $2}' | awk '{print $1}')
  if [ -z "$rtt" ]; then
    # 没有提取到延迟时间，显示超时状态
    echo " Disconnected"
  else
    # 将延迟时间转换为毫秒
    rtt_ms=$(printf "%.3f" $(echo "$rtt * 1000" | bc -l))

    # 根据延迟时间定义不同的网络状态
    if (( $(echo "$rtt > 100" | bc -l) )); then
      echo "󰤟 High latency, RTT: ${rtt_ms} ms"
    elif (( $(echo "$rtt > 50" | bc -l) )); then
      echo "󰤢 Moderate latency, RTT: ${rtt_ms} ms"
    elif (( $(echo "$rtt > 20" | bc -l) )); then
      echo "󰤥 Low latency, RTT: ${rtt_ms} ms"
    else
      echo "󰤨 Excellent latency, RTT: ${rtt_ms} ms"
    fi
  fi
else
  # ping 失败，显示没有连接状态
  echo '󰇨 No connection'
fi
