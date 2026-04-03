# ----------------------------------------------------------------------
# AI Agent 启动器 + WezTerm 终端标题管理
# 依赖 secrets.sh 中定义的环境变量（BIGMODEL_*, KIMI_* 等）
# ----------------------------------------------------------------------

# --- WezTerm 终端标题管理 ---
autoload -Uz add-zsh-hook

# 设置终端标题
_wez_agent_set_title() {
  [[ -t 1 ]] || return 0
  printf '\033]2;%s\007' "$1"
}

# 生成默认标题格式：主机名:路径
_wez_agent_default_title() {
  local host="${HOST:-$HOSTNAME}"
  local path="${PWD/#$HOME/~}"

  host="${host%%.*}"
  [[ -n "$host" ]] || host="shell"

  printf '%s:%s' "$host" "$path"
}

# 恢复默认标题（作为 precmd hook）
_wez_agent_restore_title() {
  _wez_agent_set_title "$(_wez_agent_default_title)"
}

add-zsh-hook -d precmd _wez_agent_restore_title 2>/dev/null
add-zsh-hook precmd _wez_agent_restore_title

# --- AI Agent 启动器 ---
unalias ccz cck codex 2>/dev/null

# 智谱 GLM（通过 Anthropic API 协议）
ccz() {
  _wez_agent_set_title 'claude'
  ANTHROPIC_BASE_URL="$BIGMODEL_BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$BIGMODEL_AUTH_TOKEN" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL=GLM-4.5-air \
  ANTHROPIC_DEFAULT_SONNET_MODEL=GLM-5.1 \
  ANTHROPIC_DEFAULT_OPUS_MODEL=GLM-5.1 \
  CLAUDE_CODE_NO_FLICKER=1 \
  command claude --dangerously-skip-permissions "$@"
  local rc=$?
  _wez_agent_restore_title
  return $rc
}

# Kimi（通过 Anthropic API 协议）
cck() {
  _wez_agent_set_title 'claude'
  ANTHROPIC_BASE_URL="$KIMI_BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$KIMI_AUTH_TOKEN" \
  CLAUDE_CODE_NO_FLICKER=1 \
  command claude --model default --dangerously-skip-permissions "$@"
  local rc=$?
  _wez_agent_restore_title
  return $rc
}

# OpenAI Codex
codex() {
  _wez_agent_set_title 'codex'
  command codex "$@"
  local rc=$?
  _wez_agent_restore_title
  return $rc
}
