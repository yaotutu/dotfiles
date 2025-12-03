#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECRET="$DIR/../secrets.sh"
ENC="$DIR/../secrets.enc"
PASSFILE="$DIR/.secret_password"

# 1) 保存密码（本机一次）
ensure_password() {
  if [[ ! -f "$PASSFILE" ]]; then
    echo "🔑 第一次使用，请输入加密密码（会保存在本机，不同步）:"
    read -s PASSWORD
    echo
    echo "$PASSWORD" > "$PASSFILE"
    chmod 600 "$PASSFILE"
    echo "🔐 密码已保存到: $PASSFILE"
  fi
}

# 2) 加密： secrets.sh → secrets.enc
encrypt() {
  ensure_password
  PASSWORD=$(cat "$PASSFILE")

  if [[ ! -f "$SECRET" ]]; then
    echo "❌ 找不到待加密文件: $SECRET"
    exit 1
  fi

  # 如果已有 enc 且比 secrets.sh 新，就认为没变化
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

# 3) 解密： secrets.enc → secrets.sh
decrypt() {
  ensure_password
  PASSWORD=$(cat "$PASSFILE")

  # 要求 secrets.sh 必须不存在，避免误覆盖
  if [[ -f "$SECRET" ]]; then
    echo "❌ $SECRET 已存在，为避免覆盖中止解密"
    echo "   如果你确定要用 enc 覆盖，请先手动备份/删除 secrets.sh 再重试。"
    exit 1
  fi

  if [[ ! -f "$ENC" ]]; then
    echo "❌ 找不到加密文件: $ENC"
    exit 1
  fi

  echo "🔓 解密 secrets.enc → secrets.sh ..."
  if ! openssl enc -d -aes-256-cbc -salt -pbkdf2 \
      -in "$ENC" -out "$SECRET" -pass pass:"$PASSWORD"; then
    echo "❌ 解密失败，可能是密码错误或文件损坏"
    # 防止写出半截的 secrets.sh
    rm -f "$SECRET"
    exit 1
  fi

  echo "✅ 解密完成：$SECRET 已生成"
}

# 4) 命令行入口
# 默认是加密；只有传入 decrypt 才解密
case "${1-}" in
  ""|encrypt)
    encrypt
    ;;
  decrypt)
    decrypt
    ;;
  *)
    echo "用法: $0 [encrypt|decrypt]"
    exit 1
    ;;
esac