# ----------------------------------------------------------------------
# PATH & 各种工具初始化
# ----------------------------------------------------------------------

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && . "$NVM_DIR/bash_completion"

# FVM
export PATH="$HOME/fvm/default/bin:$PATH"

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/bin/_bun" ]] && source "$BUN_INSTALL/bin/_bun"

# 本地工具
export PATH="$HOME/.local/bin:$PATH"

# Dart CLI completion
[[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]] && . "$HOME/.dart-cli-completion/zsh-config.zsh"

# Angular CLI completion（没装 ng 就别报错）
if command -v ng >/dev/null 2>&1; then
  source <(ng completion script)
fi