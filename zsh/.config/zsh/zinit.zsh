# ----------------------------------------------------------------------
# Zinit 最小化安装 + 立即显示界面
# ----------------------------------------------------------------------

# Zinit 安装目录
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# 仅在需要时才自动安装 Zinit
if [[ ! -d $ZINIT_HOME ]]; then
  print -P "%F{red}--- Zinit not found. Installing... ---%f"
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# 🚀 立即加载 Zinit 主程序
source "${ZINIT_HOME}/zinit.zsh"

# 🎨 立即加载漂亮主题 (Pure 主题)
zinit light sindresorhus/pure
_PRETTY_THEME_LOADED=true

# 🚀 异步加载其他插件 - 正确的加载顺序避免ZLE警告
zinit wait lucid for \
    zsh-users/zsh-autosuggestions \
    zdharma-continuum/fast-syntax-highlighting \
    zsh-users/zsh-history-substring-search

# 补全系统
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# --- autojump ---
# 推荐做法：用 brew 装 autojump，然后用 OMZ 插件包装
#   brew install autojump
# 二选一，用你喜欢的方式：

# 方式 A：用 OMZ 的 autojump 插件（推荐）
# zinit light OMZ::plugins/autojump/autojump.plugin.zsh

# 方式 B：跨平台 autojump 加载
if [[ "$OSTYPE" == darwin* ]]; then
    # macOS
    [ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh
elif [[ "$OSTYPE" == linux-gnu* ]]; then
    # Linux (Ubuntu)
    [ -f /usr/share/autojump/autojump.sh ] && . /usr/share/autojump/autojump.sh
    [ -f /etc/profile.d/autojump.sh ] && . /etc/profile.d/autojump.sh
fi

