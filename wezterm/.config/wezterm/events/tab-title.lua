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
      local process_name = pane_utils.get_title_label(pane, active_state)
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

      -- 进程名
      table.insert(cells, { Text = process_name })

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
