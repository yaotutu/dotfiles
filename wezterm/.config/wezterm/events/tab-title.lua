local wezterm = require('wezterm')

local M = {}

-- 图标
local ICON_LOCAL = ''
local ICON_REMOTE = '󰢹'
local GLYPH_LEFT = ''
local GLYPH_RIGHT = ''
local GLYPH_UNSEEN = ''

M.setup = function()
   wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
      -- 通过 pane_id 获取真正的 Pane 对象
      local pane = wezterm.mux.get_pane(tab.active_pane.pane_id)
      if not pane then
         return { { Text = '…' } }
      end

      -- 获取域名（区分本地和远程）
      local domain = pane:get_domain_name() or 'local'
      local is_local = domain == 'local'

      -- 获取进程名
      local process = pane:get_foreground_process_name() or ''
      local proc_name = process:match('([^/\\]+)$') or 'zsh'
      proc_name = proc_name:gsub('%.exe$', '')

      -- 构建标题
      local icon = is_local and ICON_LOCAL or ICON_REMOTE
      local label = is_local and proc_name or domain
      local text = icon .. ' ' .. label

      -- 颜色
      local bg, fg
      if tab.is_active then
         bg = '#7FB4CA'
         fg = '#11111b'
      elseif hover then
         bg = '#587d8c'
         fg = '#1c1b19'
      else
         bg = '#45475a'
         fg = '#cdd6f4'
      end

      -- 检查未读输出
      local has_unseen = false
      for _, p in ipairs(tab.panes) do
         if p.has_unseen_output then
            has_unseen = true
            break
         end
      end

      -- 构建单元格
      local cells = {
         { Background = { Color = 'rgba(0,0,0,0.4)' } },
         { Foreground = { Color = bg } },
         { Text = GLYPH_LEFT },
         { Background = { Color = bg } },
         { Foreground = { Color = fg } },
         { Attribute = { Intensity = 'Bold' } },
         { Text = ' ' .. text },
      }

      if has_unseen then
         table.insert(cells, { Foreground = { Color = '#FFA066' } })
         table.insert(cells, { Text = ' ' .. GLYPH_UNSEEN })
      end

      table.insert(cells, { Foreground = { Color = fg } })
      table.insert(cells, { Text = ' ' })
      table.insert(cells, { Background = { Color = 'rgba(0,0,0,0.4)' } })
      table.insert(cells, { Foreground = { Color = bg } })
      table.insert(cells, { Text = GLYPH_RIGHT })

      return cells
   end)
end

return M
