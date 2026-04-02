-- 自定义右侧状态栏
-- 显示: 位置(domain+workspace) │ agent计数 │ 模式 │ 时钟
-- 颜色从 resolved_palette 动态读取，跟随主题

local wezterm = require('wezterm')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local pane_utils = require('utils.pane')

local M = {}

-- 添加一个状态栏段落（自动插入分隔符）
local function add_part(items, text, color)
   if #items > 1 then
      table.insert(items, { Foreground = { Color = color.dim } })
      table.insert(items, { Text = '   │   ' })
   end

   table.insert(items, { Foreground = { Color = color.fg } })
   table.insert(items, { Text = text })
end

local function build_right_status(window, pane, palette)
   pane_utils.refresh_agent_states(window, agent_deck)

   -- 状态栏颜色从 palette 读取
   local color = {
      fg = palette.foreground,
      dim = palette.ansi[8],     -- 灰色，用于分隔符
      quiet = palette.ansi[8],   -- 灰色，用于时钟
      wait = palette.ansi[4],    -- 蓝色，用于 waiting
      work = palette.ansi[3],    -- 绿色，用于 working
      mode = palette.ansi[5],    -- 洋红，用于模式
   }

   local items = {
      { Text = '   ' },
   }

   -- 位置标签（domain + workspace）
   add_part(items, pane_utils.get_location_label(pane, window), { fg = color.fg, dim = color.dim })

   -- agent 计数
   local counts = agent_deck.count_agents_by_status()
   if counts then
      local waiting = counts.waiting or 0
      local working = counts.working or 0

      if waiting > 0 then
         add_part(items, '◔ ' .. waiting, { fg = color.wait, dim = color.dim })
      end

      if working > 0 then
         add_part(items, '● ' .. working, { fg = color.work, dim = color.dim })
      end
   end

   -- 模式标签
   local mode = pane_utils.get_mode_label(window)
   if mode then
      add_part(items, mode, { fg = color.mode, dim = color.dim })
   end

   -- 时钟
   add_part(items, wezterm.strftime('%H:%M'), { fg = color.quiet, dim = color.dim })
   table.insert(items, { Text = '   ' })

   return wezterm.format(items)
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local ok, conf = pcall(window.effective_config, window)
      if not ok then
         return
      end

      local palette = conf.resolved_palette
      local ok2, formatted = pcall(build_right_status, window, pane, palette)

      local text
      if ok2 then
         text = formatted
      else
         wezterm.log_error('right-status error: ' .. tostring(formatted))
         text = wezterm.format({ { Text = ' [err] ' } })
      end

      window:set_right_status(text)
   end)
end

return M
