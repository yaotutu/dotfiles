local wezterm = require('wezterm')

-- tabline.wez 极简配置
-- 文档: https://github.com/michaelbrusegard/tabline.wez

-- 简洁标题：本地只显示进程名，远程显示域名
local function short_title(tab)
   local pane = tab.active_pane
   local domain = pane.domain_name or 'local'

   if domain ~= 'local' then
      return domain
   end

   local process = pane.foreground_process_name or ''
   return process:match('([^/\\]+)$') or 'zsh'
end

return {
   options = {
      -- 使用内置主题
      theme = 'Catppuccin Mocha',

      -- 无分隔符
      section_separators = { left = '', right = '' },
      component_separators = { left = '', right = '' },
      tab_separators = { left = '', right = '' },

      -- 禁用图标，避免字体不支持
      icons_enabled = false,

      -- tab 在顶部
      tab_bar_at_bottom = false,
   },

   sections = {
      -- 左侧：只保留模式
      tabline_a = { 'mode' },
      tabline_b = {},
      tabline_c = {},

      -- 中间：极简 tab 标题
      tab_active = {
         { short_title, padding = { left = 1, right = 1 } },
      },
      tab_inactive = {
         { short_title, padding = { left = 1, right = 1 } },
      },

      -- 右侧：只保留时间
      tabline_x = {},
      tabline_y = {},
      tabline_z = { 'datetime' },
   },
}
