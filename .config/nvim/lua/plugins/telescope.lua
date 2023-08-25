return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    config = function()
        require("telescope").setup({
            defaults = {
                -- vertical , center , cursor
                layout_strategy = "vertical",
                mappings = {
                    i = {
                        -- 上下移动
                        ["<C-j>"] = "move_selection_next",
                        ["<C-k>"] = "move_selection_previous",
                        -- 历史记录
                        -- ["<C-n>"] = "cycle_history_next",
                        -- ["<C-p>"] = "cycle_history_prev",
                        -- 关闭窗口
                        ["<Esc"] = "close",
                        -- 预览窗口上下滚动
                        ["<C-u>"] = "preview_scrolling_up",
                        ["<C-d>"] = "preview_scrolling_down",
                    },
                }
            }
        })
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>fr', builtin.lsp_references, {})
        vim.keymap.set('n', '<leader>fa', builtin.git_commits, {})
    end
}
