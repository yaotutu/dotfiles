local wezterm = require('wezterm')

-- tabline.wez 配置（参考官方示例风格）
-- 文档: https://github.com/michaelbrusegard/tabline.wez

-- 自定义 tab 标签：本地/远程区分
local function tab_label(tab)
   local pane = tab.active_pane
   local domain = pane.domain_name or 'local'
   local process = pane.foreground_process_name or ''
   local proc_name = process:match('([^/\\]+)$') or 'zsh'

   if domain == 'local' then
      return wezterm.nerdfonts.md_laptop .. ' ' .. proc_name
   else
      return wezterm.nerdfonts.md_server .. ' ' .. domain .. ' · ' .. proc_name
   end
end

return {
   options = {
      -- 使用内置主题
      theme = 'Catppuccin Mocha',

      -- 箭头分隔符（官方示例风格）
      section_separators = {
         left = wezterm.nerdfonts.pl_left_hard_divider,
         right = wezterm.nerdfonts.pl_right_hard_divider,
      },
      component_separators = {
         left = wezterm.nerdfonts.pl_left_soft_divider,
         right = wezterm.nerdfonts.pl_right_soft_divider,
      },
      tab_separators = {
         left = wezterm.nerdfonts.pl_left_hard_divider,
         right = wezterm.nerdfonts.pl_right_hard_divider,
      },

      -- 启用图标
      icons_enabled = true,

      -- tab 在顶部
      tab_bar_at_bottom = false,
   },

   sections = {
      -- 左侧: 模式 + workspace
      tabline_a = { 'mode' },
      tabline_b = { 'workspace' },
      tabline_c = { ' ' },

      -- 中间: tab 列表（序号 + 本地/远程标签）
      tab_active = {
         'index',
         { tab_label, padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
         'index',
         { tab_label, padding = { left = 0, right = 1 } },
      },

      -- 右侧: 系统信息
      tabline_x = { 'ram', 'cpu' },
      tabline_y = { 'datetime', 'battery' },
      tabline_z = { 'hostname' },
   },
}
