local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local act = wezterm.action
local callback = wezterm.action_callback

local SUPER = 'SUPER'
local SUPER_SHIFT = 'SUPER|SHIFT'

local function map(key, mods, action)
   return {
      key = key,
      mods = mods,
      action = action,
   }
end

local function concat_groups(...)
   local groups = { ... }
   local result = {}

   for _, group in ipairs(groups) do
      for _, entry in ipairs(group) do
         table.insert(result, entry)
      end
   end

   return result
end

local function open_selected_url(window, pane)
   local url = window:get_selection_text_for_pane(pane)
   wezterm.log_info('opening: ' .. url)
   wezterm.open_with(url)
end

local function pick_random_backdrop(window)
   backdrops:random(window)
end

local function choose_backdrop(window, _, idx)
   ---@diagnostic disable-next-line: param-type-mismatch
   backdrops:set_img(window, tonumber(idx))
end

local utility_keys = {
   map('u', SUPER, act.QuickSelectArgs({
      label = 'open url',
      patterns = { 'https?://\\S+' },
      action = callback(open_selected_url),
   })),
   map('Enter', 'SHIFT', wezterm.action({ SendString = '\x1b\r' })),
}

local clipboard_keys = {
   map('c', SUPER, act.CopyTo('Clipboard')),
   map('v', SUPER, act.PasteFrom('Clipboard')),
}

local window_keys = {
   map('n', SUPER, act.SpawnWindow),
}

local tab_keys = {
   map('t', SUPER, act.SpawnTab('DefaultDomain')),
   map('w', SUPER_SHIFT, act.CloseCurrentTab({ confirm = false })),
   map('[', SUPER, act.ActivateTabRelative(-1)),
   map(']', SUPER, act.ActivateTabRelative(1)),
   map('[', SUPER_SHIFT, act.MoveTabRelative(-1)),
   map(']', SUPER_SHIFT, act.MoveTabRelative(1)),
   map('1', SUPER, act.ActivateTab(0)),
   map('2', SUPER, act.ActivateTab(1)),
   map('3', SUPER, act.ActivateTab(2)),
   map('4', SUPER, act.ActivateTab(3)),
   map('5', SUPER, act.ActivateTab(4)),
   map('6', SUPER, act.ActivateTab(5)),
   map('7', SUPER, act.ActivateTab(6)),
   map('8', SUPER, act.ActivateTab(7)),
   map('9', SUPER, act.ActivateTab(8)),
}

local pane_keys = {
   map('d', SUPER, act.SplitHorizontal({ domain = 'CurrentPaneDomain' })),
   map('D', SUPER, act.SplitVertical({ domain = 'CurrentPaneDomain' })),
   map('Enter', SUPER, act.TogglePaneZoomState),
   map('w', SUPER, act.CloseCurrentPane({ confirm = false })),
   map('h', SUPER_SHIFT, act.ActivatePaneDirection('Left')),
   map('j', SUPER_SHIFT, act.ActivatePaneDirection('Down')),
   map('k', SUPER_SHIFT, act.ActivatePaneDirection('Up')),
   map('l', SUPER_SHIFT, act.ActivatePaneDirection('Right')),
   map('p', SUPER_SHIFT, act.PaneSelect({
      alphabet = '1234567890',
      mode = 'SwapWithActiveKeepFocus',
   })),
}

local background_keys = {
   map('/', SUPER, callback(function(window, _)
      pick_random_backdrop(window)
   end)),
   map('/', SUPER_SHIFT, act.InputSelector({
      title = 'Select Background',
      choices = backdrops:choices(),
      fuzzy = true,
      fuzzy_description = 'Select Background: ',
      action = callback(choose_backdrop),
   })),
}

local keys = concat_groups(
   utility_keys,
   clipboard_keys,
   window_keys,
   tab_keys,
   pane_keys,
   background_keys
)

local mouse_bindings = {
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
