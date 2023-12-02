local M = {}

local cwd = vim.fn.getcwd()
local util = require("lspconfig.util")
local project_root = util.find_node_modules_ancestor(cwd)

local vue_path = util.path.join(project_root, "node_modules", "vue")
local is_vue = vim.fn.isdirectory(vue_path) == 1


M.setup = function()
  if is_vue then
    require("lspconfig").volar.setup({
      filetypes = { "typescript", "javascript", "vue", "json" },
    })
  end
end

return M
