#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SECRET="$DIR/../secrets.sh"
ENC="$DIR/../secrets.enc"
PASSFILE="$DIR/.secret_password"
HASHFILE="$DIR/../.secrets.hash"

# 计算 secrets.sh 的 hash（只取内容，忽略末尾空行差异）
compute_hash() {
  sed 's/[[:space:]]*$//' "$SECRET" | shasum -a 256 | cut -d' ' -f1
}

# 保存当前 hash 到文件
save_hash() {
  compute_hash > "$HASHFILE"
  echo "📝 Hash 已保存到: $HASHFILE"
}

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

  # 检查 hash 是否有变化（如果有 hash 文件的话）
  if [[ -f "$HASHFILE" ]]; then
    CURRENT_HASH=$(compute_hash)
    STORED_HASH=$(cat "$HASHFILE")
    if [[ "$CURRENT_HASH" == "$STORED_HASH" ]]; then
      echo "⚡ secrets.sh 内容无变化，跳过加密"
      return 0
    fi
  fi

  echo "🔄 删除旧加密文件（如果有）..."
  rm -f "$ENC"

  echo "🔐 加密 secrets.sh → secrets.enc ..."
  openssl enc -aes-256-cbc -salt -pbkdf2 \
    -in "$SECRET" -out "$ENC" -pass pass:"$PASSWORD"

  # 加密成功后保存 hash
  save_hash

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

  # 解密成功后保存 hash，这样后续提交时不会误触发加密
  save_hash

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