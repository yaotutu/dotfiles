# ----------------------------------------------------------------------
# Zinit 安装 + 插件配置
# ----------------------------------------------------------------------

# Zinit 安装目录
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# 自动安装 Zinit
if [[ ! -d $ZINIT_HOME ]]; then
  print -P "%F{red}--- Zinit not found. Installing... ---%f"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 加载 Zinit 主程序
source "${ZINIT_HOME}/zinit.zsh"

# -------------------------
# Zinit 插件列表
# -------------------------

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-history-substring-search
zinit light sindresorhus/pure

# --- autojump ---
# 推荐做法：用 brew 装 autojump，然后用 OMZ 插件包装
#   brew install autojump
# 二选一，用你喜欢的方式：

# 方式 A：用 OMZ 的 autojump 插件（推荐）
# zinit light OMZ::plugins/autojump/autojump.plugin.zsh

# 方式 B：直接 source brew 安装的 autojump 脚本
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# ⚠️ 不再使用这个，避免重复和安装脚本没跑的问题
# zinit light wting/autojump