# ----------------------------------------------------------------------
# 自定义函数
# ----------------------------------------------------------------------

# zellij：用当前目录名作为 session 名；在 $HOME 时叫 home
zj() {
  # 已经在 zellij 里就不再嵌套
  if [[ -n "$ZELLIJ" ]]; then
    echo "已经在 zellij session 里了：$ZELLIJ_SESSION_NAME"
    return
  fi

  local dir="$PWD"
  local name

  if [[ "$dir" == "$HOME" ]]; then
    name="home"
  else
    name="${dir##*/}"
  fi

  name="${name// /_}"

  command zellij --session "$name" "$@"
}