local wezterm = require('wezterm')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local theme = require('colors.theme')
local pane_utils = require('utils.pane')

local M = {}

-- 高辨识度、无装饰风格
local GLYPH_LEFT = '['
local GLYPH_RIGHT = ']'
local GLYPH_UNSEEN = '*'

M.setup = function()
   wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
      local pane = pane_utils.get_active_pane(tab)
      if not pane then
         return { { Text = '…' } }
      end

      pcall(agent_deck.update_pane, pane)

      local active_state = agent_deck.get_agent_state(tab.active_pane.pane_id)
      local text = pane_utils.get_title_label(pane, active_state)
      local agent_cells = pane_utils.collect_tab_agent_cells(tab, agent_deck)

      local bg, fg
      if tab.is_active then
         bg = theme.chrome.tab.active.bg
         fg = theme.chrome.tab.active.fg
      elseif hover then
         bg = theme.chrome.tab.hover.bg
         fg = theme.chrome.tab.hover.fg
      else
         bg = theme.chrome.tab.inactive.bg
         fg = theme.chrome.tab.inactive.fg
      end

      -- 检查未读输出
      local has_unseen = false
      for _, p in ipairs(tab.panes) do
         if p.has_unseen_output then
            has_unseen = true
            break
         end
      end

      -- 高辨识度样式：[内容] 或 [*内容]（有未读时）
      local cells = {
         { Background = { Color = theme.chrome.glass } },
         { Foreground = { Color = bg } },
         { Text = GLYPH_LEFT },
         { Background = { Color = bg } },
         { Foreground = { Color = fg } },
      }

      if #agent_cells > 0 then
         for _, cell in ipairs(agent_cells) do
            table.insert(cells, cell)
         end
      end

      if has_unseen then
         table.insert(cells, { Foreground = { Color = theme.chrome.tab.unseen } })
         table.insert(cells, { Text = GLYPH_UNSEEN })
         table.insert(cells, { Foreground = { Color = fg } })
      end

      table.insert(cells, { Text = text })
      table.insert(cells, { Background = { Color = theme.chrome.glass } })
      table.insert(cells, { Foreground = { Color = bg } })
      table.insert(cells, { Text = GLYPH_RIGHT })

      return cells
   end)
end

return M
