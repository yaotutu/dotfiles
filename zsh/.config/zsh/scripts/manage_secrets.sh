#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECRET="$DIR/../secrets.sh"
ENC="$DIR/../secrets.enc"
PASSFILE="$DIR/.secret_password"

# 1) 保存密码
ensure_password() {
  if [[ ! -f "$PASSFILE" ]]; then
    echo "🔑 第一次使用，请输入加密密码（会保存在本机，不同步）:"
    read -s PASSWORD
    echo "$PASSWORD" > "$PASSFILE"
    chmod 600 "$PASSFILE"
    echo "🔐 密码已保存到: $PASSFILE"
  fi
}

# 2) 加密
encrypt() {
  ensure_password
  PASSWORD=$(cat "$PASSFILE")

  # 检查是否需要加密
  if [[ -f "$ENC" && "$SECRET" -ot "$ENC" ]]; then
    echo "⚡ secrets.sh 无变化，跳过加密"
    return 0
  fi

  echo "🔄 删除旧加密文件（如果有）..."
  rm -f "$ENC"

  echo "🔐 加密 secrets.sh → secrets.enc ..."
  openssl enc -aes-256-cbc -salt -pbkdf2 \
    -in "$SECRET" -out "$ENC" -pass pass:"$PASSWORD"

  echo "✅ 加密完成：$ENC 已更新"
}

encrypt