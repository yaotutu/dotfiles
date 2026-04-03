-- 自定义右侧状态栏（标签风格）
-- 显示: 位置 │ agent 计数 │ 模式 │ 时钟
-- 彩色标签块 + 半透明背景，与 tab 风格统一

local wezterm = require('wezterm')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local pane_utils = require('utils.pane')

local M = {}

-- 与 tab-title 一致的 tab bar 背景
local TAB_BAR_BG = 'rgba(0, 0, 0, 0.4)'

-- 标签颜色
local TAG_COLORS = {
   location = { bg = '#313244', fg = '#cdd6f4' },  -- surface0 / text
   working  = { bg = '#313244', fg = '#a6e3a1' },  -- surface0 / green
   waiting  = { bg = '#313244', fg = '#f9e2af' },  -- surface0 / yellow
   mode     = { bg = '#cba6f7', fg = '#11111b' },  -- mauve / crust（与 active tab 呼应）
   clock    = { bg = '#313244', fg = '#a6adc8' },  -- surface0 / subtext0
}

---添加一个彩色标签
---@param items table 格式化数组
---@param text string 标签文本
---@param tag_bg string 标签背景色
---@param tag_fg string 标签前景色
local function add_tag(items, text, tag_bg, tag_fg)
   -- 间距（tab bar 背景色）
   table.insert(items, { Background = { Color = TAB_BAR_BG } })
   table.insert(items, { Text = ' ' })
   -- 标签内容
   table.insert(items, { Background = { Color = tag_bg } })
   table.insert(items, { Foreground = { Color = tag_fg } })
   table.insert(items, { Text = ' ' .. text .. ' ' })
end

local function build_right_status(window, pane)
   pane_utils.refresh_agent_states(window, agent_deck)

   local items = {}

   -- 位置标签（domain + workspace）
   add_tag(items, pane_utils.get_location_label(pane, window),
      TAG_COLORS.location.bg, TAG_COLORS.location.fg)

   -- Agent 计数
   local counts = agent_deck.count_agents_by_status()
   if counts then
      local waiting = counts.waiting or 0
      local working = counts.working or 0
      if waiting > 0 then
         add_tag(items, '◔ ' .. waiting, TAG_COLORS.waiting.bg, TAG_COLORS.waiting.fg)
      end
      if working > 0 then
         add_tag(items, '● ' .. working, TAG_COLORS.working.bg, TAG_COLORS.working.fg)
      end
   end

   -- 模式标签
   local mode = pane_utils.get_mode_label(window)
   if mode then
      add_tag(items, mode, TAG_COLORS.mode.bg, TAG_COLORS.mode.fg)
   end

   -- 时钟
   add_tag(items, wezterm.strftime('%H:%M'), TAG_COLORS.clock.bg, TAG_COLORS.clock.fg)

   -- 右侧闭合间距
   table.insert(items, { Background = { Color = TAB_BAR_BG } })
   table.insert(items, { Text = ' ' })

   return wezterm.format(items)
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local ok, formatted = pcall(build_right_status, window, pane)
      local text
      if ok then
         text = formatted
      else
         wezterm.log_error('right-status error: ' .. tostring(formatted))
         text = wezterm.format({ { Text = ' [err] ' } })
      end
      window:set_right_status(text)
   end)
end

return M
