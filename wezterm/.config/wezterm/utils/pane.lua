local wezterm = require('wezterm')
local nf = wezterm.nerdfonts

local M = {}

local KNOWN_AGENT_TITLES = {
   ['claude'] = true,
   ['claude code'] = true,
   ['codex'] = true,
   ['opencode'] = true,
   ['aider'] = true,
   ['gemini'] = true,
}

function M.get_active_pane(tab)
   return wezterm.mux.get_pane(tab.active_pane.pane_id)
end

function M.get_domain_name(pane)
   local ok, name = pcall(function()
      return pane:get_domain_name()
   end)

   if not ok or not name or name == '' then
      return 'local'
   end

   return name
end

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

function M.get_title_label(pane, agent_state)
   local domain = M.get_domain_name(pane)
   if domain ~= 'local' then
      local agent_name = nil

      if agent_state and agent_state.status and agent_state.status ~= 'inactive' then
         agent_name = agent_state.agent_type
      end

      if not agent_name then
         agent_name = title_agent_hint(M.get_pane_title(pane))
      end

      if agent_name and agent_name ~= '' then
         return (nf.md_server or '󰢹') .. ' ' .. domain .. ' · ' .. agent_name
      end

      return (nf.md_server or '󰢹') .. ' ' .. domain
   end

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

   return (nf.md_laptop or '') .. ' ' .. proc_name:gsub('%.exe$', '')
end

function M.get_location_label(pane, window)
   local domain = M.get_domain_name(pane)
   local icon
   if domain == 'local' then
      icon = nf.md_laptop or ''
   else
      icon = nf.md_server or '󰢹'
   end

   local label = icon .. ' ' .. domain
   local workspace = window:active_workspace()
   if workspace and workspace ~= 'default' then
      label = label .. ' · ' .. workspace
   end

   return label
end

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
