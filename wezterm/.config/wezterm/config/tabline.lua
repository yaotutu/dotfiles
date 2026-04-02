local wezterm = require('wezterm')

-- tabline.wez 配置（参考官方示例风格）
-- 文档: https://github.com/michaelbrusegard/tabline.wez

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

      -- 中间: tab 列表（序号 + 本地/远程前缀 + 目录/进程）
      -- 使用 tabline 内置 domain 属性作为前缀
      tab_active = {
         'index',
         { 'domain', padding = { left = 0, right = 0 } },
         { Text = ' | ' },
         { 'parent', padding = 0 },
         '/',
         { 'cwd', padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
         'index',
         { 'domain', padding = { left = 0, right = 0 } },
         { Text = ' | ' },
         { 'process', padding = { left = 0, right = 1 } },
      },

      -- 右侧: 系统信息 + domain（显示 local 或 SSH 域名）
      tabline_x = { 'domain' },
      tabline_y = { 'ram', 'cpu' },
      tabline_z = { 'datetime', 'battery' },
   },
}
