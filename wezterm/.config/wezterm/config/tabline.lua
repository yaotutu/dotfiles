local wezterm = require('wezterm')

-- tabline.wez 配置（参考官方示例风格）
-- 文档: https://github.com/michaelbrusegard/tabline.wez

-- 自定义 agent 状态组件
local function agent_status(tab)
   local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
   local state = agent_deck.get_agent_state(tab.active_pane.pane_id)

   if not state or state.status == 'inactive' or not state.agent_type then
      return ''
   end

   local icon = agent_deck.get_status_icon(state.status) or '●'
   -- 返回带颜色的 format item 数组
   return {
      { Foreground = { Color = agent_deck.get_status_color(state.status) } },
      { Text = icon .. ' ' .. state.agent_type },
      'ResetAttributes',
   }
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

      -- 中间: tab 列表（序号 + 目录/进程 + agent 状态）
      tab_active = {
         'index',
         { 'parent', padding = 0 },
         '/',
         { 'cwd', padding = { left = 0, right = 1 } },
         { agent_status, padding = { left = 0, right = 1 } },
      },
      tab_inactive = {
         'index',
         { 'process', padding = { left = 0, right = 1 } },
         { agent_status, padding = { left = 0, right = 1 } },
      },

      -- 右侧: 系统信息
      tabline_x = { 'ram', 'cpu' },
      tabline_y = { 'datetime', 'battery' },
      tabline_z = { 'hostname' },
   },
}
