local wezterm = require('wezterm')
local platform = require('utils.platform')()
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
   mod.SUPER = 'SUPER'
   mod.SUPER_REV = 'SUPER|SHIFT'
elseif platform.is_win or platform.is_linux then
   mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
   mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
local keys = {

   {
      key = 'u',
      mods = mod.SUPER,
      action = wezterm.action.QuickSelectArgs({
         label = 'open url',
         patterns = {
            'https?://\\S+',
         },
         action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.log_info('opening: ' .. url)
            wezterm.open_with(url)
         end),
      }),
   },

   -- copy/paste --
   { key = 'c',     mods = mod.SUPER,     action = act.CopyTo('Clipboard') },
   { key = 'v',     mods = mod.SUPER,     action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',     mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
   -- { key = 't', mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'WSL:Ubuntu' }) },
   { key = 'w',     mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '[',     mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
   { key = ']',     mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
   { key = '[',     mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
   { key = ']',     mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

   -- tabs: switch by number (1-9)
   { key = '1',     mods = mod.SUPER,     action = act.ActivateTab(0) },
   { key = '2',     mods = mod.SUPER,     action = act.ActivateTab(1) },
   { key = '3',     mods = mod.SUPER,     action = act.ActivateTab(2) },
   { key = '4',     mods = mod.SUPER,     action = act.ActivateTab(3) },
   { key = '5',     mods = mod.SUPER,     action = act.ActivateTab(4) },
   { key = '6',     mods = mod.SUPER,     action = act.ActivateTab(5) },
   { key = '7',     mods = mod.SUPER,     action = act.ActivateTab(6) },
   { key = '8',     mods = mod.SUPER,     action = act.ActivateTab(7) },
   { key = '9',     mods = mod.SUPER,     action = act.ActivateTab(8) },
   { key = "Enter", mods = "SHIFT",       action = wezterm.action { SendString = "\x1b\r" } },
   -- window --
   -- spawn windows
   { key = 'n',     mods = mod.SUPER,     action = act.SpawnWindow },

   -- background controls --
   {
      key = [[/]],
      mods = mod.SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[/]],
      mods = mod.SUPER_REV,
      action = act.InputSelector({
         title = 'Select Background',
         choices = backdrops:choices(),
         fuzzy = true,
         fuzzy_description = 'Select Background: ',
         action = wezterm.action_callback(function(window, _pane, idx)
            ---@diagnostic disable-next-line: param-type-mismatch
            backdrops:set_img(window, tonumber(idx))
         end),
      }),
   },

   -- panes --
   -- 添加 Cmd+D 水平分割
   {
      key = 'd',
      mods = mod.SUPER,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },
   -- 修改 Cmd+D 为垂直分割
   {
      key = 'D',
      mods = mod.SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   -- panes: zoom+close pane
   { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
   { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
   {
      key = 'p',
      mods = mod.SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },

   -- key-tables --
   -- resizes fonts
   {
      key = 'f',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_font',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
   -- resize panes
   {
      key = 'p',
      mods = 'LEADER',
      action = act.ActivateKeyTable({
         name = 'resize_pane',
         one_shot = false,
         timemout_miliseconds = 1000,
      }),
   },
}

-- stylua: ignore
local key_tables = {
   resize_font = {
      { key = 'k',      action = act.IncreaseFontSize },
      { key = 'j',      action = act.DecreaseFontSize },
      { key = 'r',      action = act.ResetFontSize },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
   resize_pane = {
      { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },
      { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },
      { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },
      { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) },
      { key = 'Escape', action = 'PopKeyTable' },
      { key = 'q',      action = 'PopKeyTable' },
   },
}

local mouse_bindings = {
   -- Ctrl-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = mod.SUPER,
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   -- leader = { key = 'a', mods = 'CTRL' },
   keys = keys,
   key_tables = key_tables,
   mouse_bindings = mouse_bindings,
}
