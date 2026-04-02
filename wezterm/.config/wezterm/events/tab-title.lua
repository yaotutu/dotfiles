-- 自定义 tab 标题渲染（Powerline 风格）
-- 灵感来自 KevinSilvester/wezterm-config
-- 使用半圆边框创建 pill 形 tab，支持 agent 状态和未读标记

local wezterm = require('wezterm')
local Cells = require('utils.cells')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local pane_utils = require('utils.pane')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

-- 半圆边框图标
local GLYPH_SCIRCLE_LEFT = nf.ple_left_half_circle_thick
local GLYPH_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick

-- Tab 标题内边距
local TITLE_INSET = {
   DEFAULT = 6, -- 半圆(2) + 间距(4)
   AGENT = 8, -- 含 agent 图标
   UNSEEN = 8, -- 含未读标记
}

-- Tab 颜色（Catppuccin Mocha 色板）
local TAB_BAR_BG = '#11111b' -- tab bar 背景（crust）

-- stylua: ignore
local colors = {
   -- Tab 内容颜色
   text_active   = { bg = '#74c7ec', fg = '#11111b' }, -- sapphire 激活
   text_hover    = { bg = '#585b70', fg = '#cdd6f4' }, -- surface2 悬停
   text_default  = { bg = '#45475a', fg = '#bac2de' }, -- surface1 默认

   -- 未读输出图标
   unseen_active  = { bg = '#74c7ec', fg = '#fab387' }, -- peach
   unseen_hover   = { bg = '#585b70', fg = '#fab387' },
   unseen_default = { bg = '#45475a', fg = '#fab387' },

   -- Agent 状态图标颜色
   agent_working = '#a6e3a1', -- green
   agent_waiting = '#f9e2af', -- yellow
   agent_idle    = '#89dceb', -- sky

   -- 半圆边框（bg=tab_bar背景，fg=tab背景，形成圆角效果）
   scircle_active  = { bg = TAB_BAR_BG, fg = '#74c7ec' },
   scircle_hover   = { bg = TAB_BAR_BG, fg = '#585b70' },
   scircle_default = { bg = TAB_BAR_BG, fg = '#45475a' },
}

-- 渲染变体：根据 agent 和 unseen 状态选择不同的段序列
local RENDER_VARIANTS = {
   { 'scircle_left', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'title', 'unseen', 'padding', 'scircle_right' },
   { 'scircle_left', 'agent', 'title', 'padding', 'scircle_right' },
   { 'scircle_left', 'agent', 'title', 'unseen', 'padding', 'scircle_right' },
}

-- 从 agent_deck 获取状态信息
local function get_agent_info(pane_id)
   local state = agent_deck.get_agent_state(pane_id)
   if not state or not state.status or state.status == 'inactive' then
      return nil, nil
   end

   local icon, color
   if state.status == 'working' then
      icon, color = '●', colors.agent_working
   elseif state.status == 'waiting' then
      icon, color = '◔', colors.agent_waiting
   elseif state.status == 'idle' then
      icon, color = '○', colors.agent_idle
   else
      return nil, nil
   end

   return icon, color
end

-- 截断或填充标题到固定宽度
local function format_title(title, max_width, inset)
   if title:len() > max_width - inset then
      title = title:sub(1, max_width - inset - 1) .. '…'
   else
      local padding = max_width - title:len() - inset
      if padding > 0 then
         title = title .. string.rep(' ', padding)
      end
   end
   return title
end

-- 检查 tab 是否有未读输出
local function check_unseen_output(panes)
   for _, p in ipairs(panes) do
      if p.has_unseen_output then
         return true
      end
   end
   return false
end

---@class Tab
---@field cells FormatCells
---@field title string
---@field has_agent boolean
---@field agent_icon string
---@field agent_color string
---@field unseen_output boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
   return setmetatable({
      cells = Cells:new(),
      title = '',
      has_agent = false,
      agent_icon = '',
      agent_color = '',
      unseen_output = false,
   }, self)
end

---更新 tab 信息
---@param tab table WezTerm tab 对象
---@param max_width number 最大宽度
function Tab:set_info(tab, max_width)
   local pane = pane_utils.get_active_pane(tab)
   if not pane then
      self.title = '…'
      self.has_agent = false
      self.unseen_output = false
      return
   end

   -- 更新 agent 状态
   pcall(agent_deck.update_pane, pane)

   -- 获取标题
   local active_state = agent_deck.get_agent_state(tab.active_pane.pane_id)
   local process_name = pane_utils.get_title_label(pane, active_state)
   local index = tab.tab_index + 1
   local raw_title = index .. ' ' .. process_name

   -- 获取 agent 信息
   local icon, color = get_agent_info(tab.active_pane.pane_id)
   self.has_agent = icon ~= nil
   self.agent_icon = icon or ''
   self.agent_color = color or ''

   -- 检查未读
   self.unseen_output = check_unseen_output(tab.panes)

   -- 计算内边距
   local inset = TITLE_INSET.DEFAULT
   if self.has_agent then
      inset = inset + 2
   end
   if self.unseen_output then
      inset = inset + 2
   end

   self.title = format_title(raw_title, max_width, inset)
end

---创建格式化单元格（只需调用一次）
function Tab:create_cells()
   self.cells
      :add_segment('scircle_left', GLYPH_SCIRCLE_LEFT)
      :add_segment('agent', ' ', nil, attr(attr.intensity('Bold')))
      :add_segment('title', ' ', nil, attr(attr.intensity('Bold')))
      :add_segment('unseen', ' *')
      :add_segment('padding', ' ')
      :add_segment('scircle_right', GLYPH_SCIRCLE_RIGHT)
end

---更新单元格颜色和文本
---@param is_active boolean
---@param hover boolean
function Tab:update_cells(is_active, hover)
   local state = 'default'
   if is_active then
      state = 'active'
   elseif hover then
      state = 'hover'
   end

   -- 更新标题文本
   self.cells:update_segment_text('title', ' ' .. self.title)

   -- 更新颜色
   self.cells
      :update_segment_colors('scircle_left', colors['scircle_' .. state])
      :update_segment_colors('title', colors['text_' .. state])
      :update_segment_colors('padding', colors['text_' .. state])
      :update_segment_colors('scircle_right', colors['scircle_' .. state])

   -- Agent 图标：使用 agent 自身颜色，背景跟随 tab
   if self.has_agent then
      self.cells:update_segment_text('agent', ' ' .. self.agent_icon .. ' ')
      self.cells:update_segment_colors('agent', {
         bg = colors['text_' .. state].bg,
         fg = self.agent_color,
      })
   else
      self.cells:update_segment_text('agent', '')
   end

   -- 未读标记
   if self.unseen_output then
      self.cells:update_segment_text('unseen', ' *')
      self.cells:update_segment_colors('unseen', colors['unseen_' .. state])
   else
      self.cells:update_segment_text('unseen', '')
   end
end

---渲染 tab
---@return table[] FormatItem 数组
function Tab:render()
   -- 根据状态选择渲染变体
   local variant = 1
   if self.has_agent and self.unseen_output then
      variant = 4
   elseif self.has_agent then
      variant = 3
   elseif self.unseen_output then
      variant = 2
   end
   return self.cells:render(RENDER_VARIANTS[variant])
end

-- Tab 实例缓存
local tab_list = {}

M.setup = function()
   wezterm.on('format-tab-title', function(tab, _tabs, _panes, _conf, hover, max_width)
      if not tab_list[tab.tab_id] then
         tab_list[tab.tab_id] = Tab:new()
         tab_list[tab.tab_id]:set_info(tab, max_width)
         tab_list[tab.tab_id]:create_cells()
         return tab_list[tab.tab_id]:render()
      end

      tab_list[tab.tab_id]:set_info(tab, max_width)
      tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
      return tab_list[tab.tab_id]:render()
   end)
end

return M
