return {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    config = function()
        local null_ls = require("null-ls")
        require("null-ls").setup({
            sources = {
                null_ls.builtins.formatting.prettier
            },

        })
    end,
}
