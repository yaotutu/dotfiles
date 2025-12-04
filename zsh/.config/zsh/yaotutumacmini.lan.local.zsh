# ----------------------------------------------------------------------
# [HOSTNAME].local.zsh (HOST-SPECIFIC: Hardcoded Paths, Conda)
# ----------------------------------------------------------------------
# --- Opus 动态库路径 (Homebrew) ---
export DYLD_LIBRARY_PATH=/opt/homebrew/opt/opus/lib:$DYLD_LIBRARY_PATH

# --- Conda 初始化 (基于系统具体安装路径) ---
# >>> conda initialize >>>
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH="$HOME/fvm/default/bin:$PATH"

# ----------------------------------------------------------------------
# 延迟加载函数定义
# ----------------------------------------------------------------------

# SDKMAN 延迟加载
sdkman_lazy() {
  if [[ -n "$SDKMAN_LOADED" ]]; then
    return 0
  fi
  export SDKMAN_DIR="$HOME/.sdkman"
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
  export SDKMAN_LOADED=1
}

# NVM 延迟加载
nvm_lazy() {
  if [[ -n "$NVM_LOADED" ]]; then
    return 0
  fi
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"
  export NVM_LOADED=1
}

# Bun 延迟加载
bun_lazy() {
  if [[ -n "$BUN_LOADED" ]]; then
    return 0
  fi
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  [[ -s "$BUN_INSTALL/bin/_bun" ]] && source "$BUN_INSTALL/bin/_bun"
  export BUN_LOADED=1
}

# ----------------------------------------------------------------------
# 按需加载函数包装
# ----------------------------------------------------------------------
sdk() {
  sdkman_lazy
  command sdk "$@"
}

nvm() {
  nvm_lazy
  command nvm "$@"
}

node() {
  nvm_lazy
  command node "$@"
}

npm() {
  nvm_lazy
  command npm "$@"
}

npx() {
  nvm_lazy
  command npx "$@"
}

bun() {
  bun_lazy
  command bun "$@"
}

# ----------------------------------------------------------------------
# 延迟加载的补全系统
# ----------------------------------------------------------------------
dart() {
  if [[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]]; then
    . "$HOME/.dart-cli-completion/zsh-config.zsh"
    unfunction dart  # 删除包装函数
    dart "$@"  # 执行真实命令
  else
    command dart "$@"
  fi
}

ng() {
  if command -v ng >/dev/null 2>&1; then
    source <(ng completion script)
    unfunction ng  # 删除包装函数
    ng "$@"  # 执行真实命令
  else
    echo "Angular CLI not found"
    return 1
  fi
}

# ----------------------------------------------------------------------
# Python & pip 别名
# ----------------------------------------------------------------------
alias pip='python3 -m pip'
alias python='python3'
