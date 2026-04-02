local wezterm = require('wezterm')

-- tabline.wez 配置
-- 文档: https://github.com/michaelbrusegard/tabline.wez

-- 自定义 agent 状态组件（使用 agent-deck 数据）
local function agent_status(tab)
   local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
   local state = agent_deck.get_agent_state(tab.active_pane.pane_id)

   if not state or state.status == 'inactive' or not state.agent_type then
      return ''
   end

   local icon = agent_deck.get_status_icon(state.status) or '●'
   return string.format('%s %s', icon, state.agent_type)
end

-- 自定义标题：远程显示域名+agent，本地显示进程
local function custom_title(tab)
   local pane = tab.active_pane
   local domain = pane.domain_name or 'local'

   if domain ~= 'local' then
      -- 远程：尝试获取 agent 状态
      local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
      local state = agent_deck.get_agent_state(pane.pane_id)
      if state and state.agent_type and state.status ~= 'inactive' then
         return string.format('%s · %s', domain, state.agent_type)
      end
      return domain
   end

   -- 本地：显示进程名
   local process = pane.foreground_process_name or ''
   return process:match('([^/\\]+)$') or 'zsh'
end

return {
   options = {
      -- 使用内置主题
      theme = 'Catppuccin Mocha',

      -- 无分隔符，简洁风格
      section_separators = { left = '', right = '' },
      component_separators = { left = '│', right = '│' },
      tab_separators = { left = '', right = '' },

      -- 启用图标
      icons_enabled = true,

      -- tab 在顶部
      tab_bar_at_bottom = false,
   },

   sections = {
      -- 左侧
      tabline_a = { 'mode' },
      tabline_b = { 'workspace' },
      tabline_c = {},

      -- 中间：tab 标题
      tab_active = {
         'index',
         { custom_title, padding = { left = 1, right = 1 } },
         { agent_status, padding = { left = 1 } },
      },
      tab_inactive = {
         'index',
         { custom_title, padding = { left = 1, right = 1 } },
      },

      -- 右侧
      tabline_x = {},
      tabline_y = { 'datetime', { 'hostname', ssh_only = true } },
      tabline_z = { 'domain' },
   },
}
