# ----------------------------------------------------------------------
# 自定义函数
# ----------------------------------------------------------------------

function zj() {
    # 1. 获取当前目录的名称作为会话名
    local session_name="${PWD:t}"

    # 如果当前目录名为空，则使用 "root"
    if [[ -z "$session_name" ]]; then
        session_name="root"
    fi

    # 2. 检查会话是否存在
    # zellij list-sessions | grep -q "^$session_name$"
    # 另一种更健壮的检查方法是尝试附加，让 zellij 自己处理不存在的情况

    # 3. 使用 'attach -c' (Attach or Create) 逻辑
    # 这是最简洁和正确的做法：尝试附加，如果不存在则自动创建。
    echo "Attempting to attach/create Zellij session: $session_name"
    zellij attach --create "$session_name"
}



# === Zellij: 单会话工作流（固定 main）===

# 一键进入：有就 attach，没有就 create
alias zj='zellij attach --create main'

# 会话管理
alias zjl='zellij ls'             # list-sessions（短命令 ls）  [oai_citation:0‡zellij.dev](https://zellij.dev/documentation/commands.html)
alias zjk='zellij k main'         # kill-sessions（短命令 k）  [oai_citation:1‡zellij.dev](https://zellij.dev/documentation/commands.html)
alias zjka='zellij ka'            # kill-all-sessions（短命令 ka）  [oai_citation:2‡zellij.dev](https://zellij.dev/documentation/commands.html)
