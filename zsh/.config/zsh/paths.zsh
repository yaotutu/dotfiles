 # ----------------------------------------------------------------------
  # PATH & 各种工具初始化 (优化版 - 延迟加载)
  # ----------------------------------------------------------------------

  # 固定路径（不需要延迟加载的）
  export PATH="$HOME/fvm/default/bin:$PATH"
  export PATH="$HOME/.local/bin:$PATH"
  export PATH="$HOME/.pyenv/bin:$PATH"  # pyenv 的路径需要保留

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

  # pyenv 延迟加载
  pyenv_lazy() {
    if [[ -n "$PYENV_LOADED" ]]; then
      return 0
    fi
    if command -v pyenv >/dev/null 2>&1; then
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
      export PYENV_LOADED=1
    fi
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

  pyenv() {
    pyenv_lazy
    command pyenv "$@"
  }

  python() {
    pyenv_lazy
    command python "$@"
  }

  pip() {
    pyenv_lazy
    command pip "$@"
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