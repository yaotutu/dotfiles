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