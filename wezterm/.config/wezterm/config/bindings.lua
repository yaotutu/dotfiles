local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local act = wezterm.action

-- macOS only: 直接使用 SUPER (Cmd) 键
local SUPER = 'SUPER'
local SUPER_REV = 'SUPER|SHIFT'

-- stylua: ignore
local keys = {

   {
      key = 'u',
      mods = SUPER,
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
   { key = 'c',     mods = SUPER,     action = act.CopyTo('Clipboard') },
   { key = 'v',     mods = SUPER,     action = act.PasteFrom('Clipboard') },

   -- tabs --
   -- tabs: spawn+close
   { key = 't',     mods = SUPER,     action = act.SpawnTab('DefaultDomain') },
   { key = 'w',     mods = SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

   -- tabs: navigation
   { key = '[',     mods = SUPER,     action = act.ActivateTabRelative(-1) },
   { key = ']',     mods = SUPER,     action = act.ActivateTabRelative(1) },
   { key = '[',     mods = SUPER_REV, action = act.MoveTabRelative(-1) },
   { key = ']',     mods = SUPER_REV, action = act.MoveTabRelative(1) },

   -- tabs: switch by number (1-9)
   { key = '1',     mods = SUPER,     action = act.ActivateTab(0) },
   { key = '2',     mods = SUPER,     action = act.ActivateTab(1) },
   { key = '3',     mods = SUPER,     action = act.ActivateTab(2) },
   { key = '4',     mods = SUPER,     action = act.ActivateTab(3) },
   { key = '5',     mods = SUPER,     action = act.ActivateTab(4) },
   { key = '6',     mods = SUPER,     action = act.ActivateTab(5) },
   { key = '7',     mods = SUPER,     action = act.ActivateTab(6) },
   { key = '8',     mods = SUPER,     action = act.ActivateTab(7) },
   { key = '9',     mods = SUPER,     action = act.ActivateTab(8) },
   { key = 'Enter', mods = 'SHIFT',    action = wezterm.action { SendString = "\x1b\r" } },

   -- window --
   -- spawn windows
   { key = 'n',     mods = SUPER,     action = act.SpawnWindow },

   -- background controls --
   {
      key = [[/]],
      mods = SUPER,
      action = wezterm.action_callback(function(window, _pane)
         backdrops:random(window)
      end),
   },
   {
      key = [[/]],
      mods = SUPER_REV,
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
   -- Cmd+D: 水平分割 (左右分屏)
   {
      key = 'd',
      mods = SUPER,
      action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
   },
   -- Cmd+Shift+D: 垂直分割 (上下分屏)
   {
      key = 'D',
      mods = SUPER,
      action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
   },
   -- panes: zoom+close pane
   { key = 'Enter', mods = SUPER,     action = act.TogglePaneZoomState },
   { key = 'w',     mods = SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

   -- panes: navigation
   { key = 'k',     mods = SUPER_REV, action = act.ActivatePaneDirection('Up') },
   { key = 'j',     mods = SUPER_REV, action = act.ActivatePaneDirection('Down') },
   { key = 'h',     mods = SUPER_REV, action = act.ActivatePaneDirection('Left') },
   { key = 'l',     mods = SUPER_REV, action = act.ActivatePaneDirection('Right') },
   {
      key = 'p',
      mods = SUPER_REV,
      action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
   },
}

local mouse_bindings = {
   -- Cmd-click will open the link under the mouse cursor
   {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = SUPER,
      action = act.OpenLinkAtMouseCursor,
   },
}

return {
   disable_default_key_bindings = true,
   keys = keys,
   mouse_bindings = mouse_bindings,
}
