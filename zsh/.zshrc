[ -f "$HOME/.config/zsh/zshrc" ] && source "$HOME/.config/zsh/zshrc"

# taobao-native CLI
TBN_CLI_BIN="/Users/yaotutu/Library/Application Support/taobao/cli/bin"
case ":$PATH:" in *":$TBN_CLI_BIN:"*) ;; *) export PATH="$PATH:$TBN_CLI_BIN" ;; esac
