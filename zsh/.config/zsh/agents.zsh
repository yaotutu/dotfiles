# ----------------------------------------------------------------------
# AI Agent 启动器
# 依赖 secrets.sh 中定义的环境变量（BIGMODEL_*, KIMI_* 等）
# ----------------------------------------------------------------------

# --- 终端标题管理 ---
# kitty shell integration 已自动管理默认标题（显示目录/命令）
# 这里只处理 AI Agent 运行时的特殊标题切换
_agent_set_title() {
  [[ -t 1 ]] || return 0
  printf '\033]2;%s\007' "$1"
}

# --- AI Agent 启动器 ---
unalias ccz cck ccm codex 2>/dev/null

# 智谱 GLM（通过 Anthropic API 协议）
ccz() {
  _agent_set_title 'claude'
  ANTHROPIC_BASE_URL="$BIGMODEL_BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$BIGMODEL_AUTH_TOKEN" \
  CLAUDE_CODE_AUTO_COMPACT_WINDOW=1000000 \
  ANTHROPIC_DEFAULT_HAIKU_MODEL=GLM-4.5-air \
  ANTHROPIC_DEFAULT_SONNET_MODEL=glm-5.2[1m] \
  ANTHROPIC_DEFAULT_OPUS_MODEL=glm-5.2[1m] \
  CLAUDE_CODE_NO_FLICKER=1 \
  command claude --dangerously-skip-permissions "$@"
  local rc=$?
  _agent_set_title ''
  return $rc
}

# Kimi（通过 Anthropic API 协议）
cck() {
  _agent_set_title 'claude'
  ANTHROPIC_BASE_URL="$KIMI_BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$KIMI_AUTH_TOKEN" \
  CLAUDE_CODE_NO_FLICKER=1 \
  command claude --model default --dangerously-skip-permissions "$@"
  local rc=$?
  _agent_set_title ''
  return $rc
}

# MiniMax（通过 Anthropic API 协议）
ccm() {
  _agent_set_title 'claude'
  ANTHROPIC_BASE_URL="https://api.minimaxi.com/anthropic" \
  ANTHROPIC_AUTH_TOKEN="$MINIMAX_API_KEY" \
  API_TIMEOUT_MS="3000000" \
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
  ANTHROPIC_MODEL="MiniMax-M3" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="MiniMax-M3" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="MiniMax-M3" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="MiniMax-M3" \
  CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 \
  command claude --dangerously-skip-permissions "$@"
  local rc=$?
  _agent_set_title ''
  return $rc
}

# OpenAI Codex
codex() {
  _agent_set_title 'codex'
  command codex "$@"
  local rc=$?
  _agent_set_title ''
  return $rc
}
