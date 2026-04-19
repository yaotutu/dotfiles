# === Zellij 会话管理 ===
# 注意：zj 命令在 functions.zsh 中定义为函数（以目录名自动命名会话）

alias zjl='zellij ls'              # 列出所有会话
alias zjk='zellij kill-session main'  # 杀掉 main 会话
alias zjka='zellij kill-all-sessions' # 杀掉所有会话

# === 文件操作 ===
if command -v eza &>/dev/null; then
    alias ls='eza --icons'                        # 用 eza 替代 ls，带图标
    alias ll='eza -lh --icons --git'               # 长格式，人类可读大小，带图标和 git 状态
    alias la='eza -lAh --icons --git'              # 长格式，含隐藏文件，带图标和 git 状态
    alias lt='eza -lh --sort=modified --icons'     # 按修改时间排序，带图标
    alias tree='eza --tree --level=2 --icons'      # 目录树，带图标
else
    alias ll='ls -lh'
    alias la='ls -lAh'
    alias lt='ls -lht'
fi

# === Git 快捷键 ===
alias gs='git status'
alias gl='git log --oneline -15'
alias gd='git diff'
alias ga='git add'
alias gp='git push'

# === 目录操作 ===
alias mkcd='mkdir -p && cd'         # 创建目录并进入（用法: mkcd dir）

# === 目录跳转 ===
alias ...='cd ../..'
alias ....='cd ../../..'

# === 其他 ===
alias cls='clear'
alias which='command -v'           # 更可靠的 which
