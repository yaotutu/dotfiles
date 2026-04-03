# === Zellij 会话管理 ===
# 注意：zj 命令在 functions.zsh 中定义为函数（以目录名自动命名会话）

alias zjl='zellij ls'              # 列出所有会话
alias zjk='zellij kill-session main'  # 杀掉 main 会话
alias zjka='zellij kill-all-sessions' # 杀掉所有会话

# === 文件操作 ===
if command -v eza &>/dev/null; then
    alias ls='eza'                     # 用 eza 替代 ls
    alias ll='eza -lh'                 # 长格式，人类可读大小
    alias la='eza -lAh'                # 长格式，含隐藏文件
    alias lt='eza -lht'                # 按修改时间排序
    alias lt='eza --tree --level=2'    # 目录树
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

# === 目录跳转 ===
alias ...='cd ../..'
alias ....='cd ../../..'

# === 其他 ===
alias cls='clear'
alias which='command -v'           # 更可靠的 which
