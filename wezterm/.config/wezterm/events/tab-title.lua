-- 自定义 tab 标题渲染（简洁色块风格）
-- 去除 powerline 半圆，使用纯色块 + 间距，视觉更干净

local wezterm = require('wezterm')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local pane_utils = require('utils.pane')

local M = {}

-- Tab bar 背景（半透明，让壁纸透出来）
local TAB_BAR_BG = 'rgba(0, 0, 0, 0.4)'

-- Tab 配色（Catppuccin Mocha 柔和色板）
local TAB_COLORS = {
   active  = { bg = '#cba6f7', fg = '#11111b' }, -- mauve / crust
   hover   = { bg = '#45475a', fg = '#cdd6f4' }, -- surface1 / text
   default = { bg = '#313244', fg = '#bac2de' }, -- surface0 / subtext1
}

-- Agent 状态颜色
local AGENT_COLORS = {
   working = '#a6e3a1', -- green
   waiting = '#f9e2af', -- yellow
   idle    = '#89dceb', -- sky
}

local UNSEEN_COLOR = '#fab387' -- peach

---获取 agent 状态图标和颜色
---@param pane_id number
---@return string|nil icon
---@return string|nil color
local function get_agent_info(pane_id)
   local state = agent_deck.get_agent_state(pane_id)
   if not state or not state.status or state.status == 'inactive' then
      return nil, nil
   end

   if state.status == 'working' then
      return '●', AGENT_COLORS.working
   elseif state.status == 'waiting' then
      return '◔', AGENT_COLORS.waiting
   elseif state.status == 'idle' then
      return '○', AGENT_COLORS.idle
   end
   return nil, nil
end

---检查 tab 是否有未读输出
local function check_unseen(panes)
   for _, p in ipairs(panes) do
      if p.has_unseen_output then
         return true
      end
   end
   return false
end

local function escape_pattern(text)
   return (text:gsub('([^%w])', '%%%1'))
end

local function trim(text)
   return text:match('^%s*(.-)%s*$')
end

local function basename(path)
   local value = trim(path or '')
   value = value:gsub('/+$', '')

   if value == '' then
      return ''
   end

   if value == '~' or value == '/' then
      return value
   end

   return value:match('([^/\\]+)$') or value
end

local function parse_remote_title(title)
   if not title or title == '' then
      return nil, nil
   end

   local value = trim(title)
   local user = os.getenv('USER') or ''

   if user ~= '' then
      local host, path = value:match('^(.-)%.' .. escape_pattern(user) .. ':(.+)$')
      if host and host ~= '' then
         return host, basename(path)
      end
   end

   local _ssh_user, host, path = value:match('^([^@:%s]+)@([^:]+):(.+)$')
   if host and host ~= '' then
      return host, basename(path)
   end

   return nil, nil
end

local function remote_prefix(domain, pane)
   if domain ~= 'local' then
      return domain
   end

   local host = parse_remote_title(pane_utils.get_pane_title(pane))
   return host
end

local function clean_auto_title(title)
   local _host, path = parse_remote_title(title)
   if path and path ~= '' then
      return path
   end

   return title
end

local function get_title_label(tab, pane, agent_state)
   local manual_title = tab.tab_title
   local domain = pane_utils.get_domain_name(pane)
   local prefix = remote_prefix(domain, pane)
   if prefix and prefix ~= '' then
      prefix = prefix .. ' · '
   else
      prefix = ''
   end

   if manual_title and manual_title ~= '' then
      return prefix .. manual_title
   end

   return prefix .. clean_auto_title(pane_utils.get_title_label(pane, agent_state))
end

M.setup = function()
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _conf, hover, max_width)
      local pane = pane_utils.get_active_pane(tab)
      if not pane then
         return {
            { Background = { Color = TAB_BAR_BG } },
            { Text = ' … ' },
         }
      end

      -- 更新 agent 状态
      pcall(agent_deck.update_pane, pane)

      local active_state = agent_deck.get_agent_state(tab.active_pane.pane_id)
      local title = get_title_label(tab, pane, active_state)
      local has_unseen = check_unseen(tab.panes)
      local index = tab.tab_index + 1

      -- 根据状态选择颜色
      local c = tab.is_active and TAB_COLORS.active
         or (hover and TAB_COLORS.hover or TAB_COLORS.default)

      -- 前置间距（tab bar 背景色）
      local cells = {
         { Background = { Color = TAB_BAR_BG } },
         { Text = ' ' },
      }

      -- Tab 内容（纯色块）
      table.insert(cells, { Background = { Color = c.bg } })
      table.insert(cells, { Foreground = { Color = c.fg } })
      table.insert(cells, { Text = ' ' .. index .. ' ' })

      -- Agent 状态图标
      local icon, icon_color = get_agent_info(tab.active_pane.pane_id)
      if icon then
         table.insert(cells, { Foreground = { Color = icon_color } })
         table.insert(cells, { Text = icon .. ' ' })
         table.insert(cells, { Foreground = { Color = c.fg } })
      end

      -- 标题文本：手动命名优先，否则使用原来的智能标题
      table.insert(cells, { Text = title })

      -- 未读标记
      if has_unseen then
         table.insert(cells, { Foreground = { Color = UNSEEN_COLOR } })
         table.insert(cells, { Text = ' ●' })
      end

      -- 右侧闭合
      table.insert(cells, { Foreground = { Color = c.fg } })
      table.insert(cells, { Text = ' ' })

      return cells
   end)
end

return M
