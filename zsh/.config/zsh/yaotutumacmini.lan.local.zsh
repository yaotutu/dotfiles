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
