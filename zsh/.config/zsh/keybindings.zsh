# ----------------------------------------------------------------------
# keybindings.zsh - ZLE / bindkey（放在 zshrc 最后 source，避免被插件覆盖）
# ----------------------------------------------------------------------

# ↑/↓：按当前输入前缀搜索历史（例如输入 "ssh -i" 再按↑）
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

# 兼容部分终端（可选，但留着不碍事）
bindkey '\eOA' history-beginning-search-backward
bindkey '\eOB' history-beginning-search-forward