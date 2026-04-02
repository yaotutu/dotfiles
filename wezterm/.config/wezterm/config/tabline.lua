local wezterm = require('wezterm')
local theme = require('colors.theme')

-- tabline.wez 配置
-- 文档: https://github.com/michaelbrusegard/tabline.wez

return {
   options = {
      -- 使用与系统一致的主题色
      theme = 'Catppuccin Mocha', -- tabline 内置主题，接近我们的 palette

      -- 分隔符风格: 'slant', 'arrow', 'rounded', 'none'
      section_separators = { left = '', right = '' },
      component_separators = { left = '|', right = '|' },
      tab_separators = { left = '', right = '' },

      -- 不显示图标，保持简洁
      icons_enabled = false,

      -- tab 位置
      tab_bar_at_bottom = false,
   },

   sections = {
      -- 左侧: 当前模式 + workspace
      tabline_a = { 'mode' },
      tabline_b = { 'workspace' },
      tabline_c = { ' ' },

      -- 中间: tab 标题
      -- index = tab 序号, parent = 父目录, cwd = 当前目录, process = 进程名
      tab_active = {
         'index',
         { 'parent', padding = 0 },
         '/',
         { 'cwd', padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
         'index',
         { 'process', padding = { left = 0, right = 1 } },
      },

      -- 右侧: 时间 + domain
      tabline_x = {}, -- 空，给 agent-deck 留位置
      tabline_y = { 'datetime' },
      tabline_z = { 'domain' },
   },

   -- 扩展示例: 自定义 component 显示 agent 状态
   -- 如果需要集成 agent-deck，可以在这里添加自定义组件
}
