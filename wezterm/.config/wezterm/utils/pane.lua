local wezterm = require('wezterm')
local nf = wezterm.nerdfonts

local M = {}

-- 已知的 AI agent 进程名
local KNOWN_AGENT_TITLES = {
   ['claude'] = true,
   ['claude code'] = true,
   ['codex'] = true,
   ['opencode'] = true,
   ['aider'] = true,
   ['gemini'] = true,
}

-- 获取 tab 中活跃的 pane 对象（有方法可调用）
function M.get_active_pane(tab)
   return wezterm.mux.get_pane(tab.active_pane.pane_id)
end

-- 获取 pane 所属的 domain 名称
function M.get_domain_name(pane)
   local ok, name = pcall(function()
      return pane:get_domain_name()
   end)

   if not ok or not name or name == '' then
      return 'local'
   end

   return name
end

-- 获取 pane 的标题
function M.get_pane_title(pane)
   local ok, title = pcall(function()
      return pane:get_title()
   end)

   if ok and title and title ~= '' then
      return title
   end

   local prop_ok, prop_title = pcall(function()
      return pane.title
   end)

   if prop_ok and prop_title and prop_title ~= '' then
      return prop_title
   end

   return nil
end

-- 检测标题是否为已知 agent
local function title_agent_hint(title)
   if not title or title == '' then
      return nil
   end

   local normalized = title:lower():match('^%s*(.-)%s*$')
   if normalized and KNOWN_AGENT_TITLES[normalized] then
      return normalized
   end

   return nil
end

-- 获取 pane 的进程名
function M.get_process_name(pane)
   local ok, process = pcall(function()
      return pane:get_foreground_process_name()
   end)

   local proc_name = ''
   if ok and process then
      proc_name = process:match('([^/\\]+)$') or ''
   end

   if proc_name == '' then
      proc_name = 'zsh'
   end

   return proc_name:gsub('%.exe$', '')
end

-- 生成 tab 标题文本（智能检测：agent 状态 > pane 标题 > 进程名）
function M.get_title_label(pane, agent_state)
   -- 优先级 1：agent 状态报告
   if agent_state and agent_state.status and agent_state.status ~= 'inactive' then
      local agent_type = agent_state.agent_type
      if agent_type and agent_type ~= '' then
         return agent_type
      end
   end

   -- 优先级 2：pane 标题匹配已知 agent
   local title = M.get_pane_title(pane)
   local agent_hint = title_agent_hint(title)
   if agent_hint then
      return agent_hint
   end

   -- 优先级 3：如果 pane 标题有意义且不是默认值，直接用
   if title and title ~= '' and title ~= 'zsh' and not title:match('^%~') then
      return title
   end

   -- 优先级 4：回退到进程名
   return M.get_process_name(pane)
end

-- 生成右侧状态栏的位置标签（domain + workspace）
function M.get_location_label(pane, window)
   local domain = M.get_domain_name(pane)
   local icon
   if domain == 'local' then
      icon = nf.md_laptop or ''
   else
      icon = nf.md_server or ''
   end

   local label = icon .. ' ' .. domain
   local workspace = window:active_workspace()
   if workspace and workspace ~= 'default' then
      label = label .. ' · ' .. workspace
   end

   return label
end

-- 获取当前模式标签（key_table / leader）
function M.get_mode_label(window)
   local key_table = window:active_key_table()
   if key_table then
      return key_table:lower()
   end

   if window:leader_is_active() then
      return 'Ⓛ'
   end

   return nil
end

-- 刷新所有 pane 的 agent 状态
function M.refresh_agent_states(window, agent_deck)
   local mux_window = window:mux_window()
   if not mux_window then
      return
   end

   for _, tab in ipairs(mux_window:tabs()) do
      for _, pane in ipairs(tab:panes()) do
         pcall(agent_deck.update_pane, pane)
      end
   end
end

-- 收集 tab 中 agent 状态图标
function M.collect_tab_agent_cells(tab, agent_deck)
   local cells = {}

   for _, pane_info in ipairs(tab.panes or {}) do
      local state = agent_deck.get_agent_state(pane_info.pane_id)
      if state and state.status and state.status ~= 'inactive' then
         local icon = agent_deck.get_status_icon(state.status)
         if icon and icon ~= '' then
            table.insert(cells, {
               Foreground = { Color = agent_deck.get_status_color(state.status) },
            })
            table.insert(cells, { Text = icon })
         end
      end
   end

   return cells
end

return M
