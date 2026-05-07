local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local remote_picker = require('core.remote-picker')
local act = wezterm.action
local callback = wezterm.action_callback

local SUPER = 'SUPER'
local SUPER_ALT = 'SUPER|ALT'
local SUPER_SHIFT = 'SUPER|SHIFT'
local LOCAL_DOMAIN = 'local'

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

local function get_current_tab_title(window)
   local tab = window:active_tab()
   if not tab then
      return ''
   end

   local ok, title = pcall(function()
      return tab:get_title()
   end)

   if ok and title then
      return title
   end

   return ''
end

local function rename_current_tab(window, pane)
   window:perform_action(act.PromptInputLine({
      description = 'Rename current tab (empty restores automatic title)',
      initial_value = get_current_tab_title(window),
      action = callback(function(prompt_window, _, line)
         if line ~= nil then
            local tab = prompt_window:active_tab()
            if tab then
               tab:set_title(line)
            end
         end
      end),
   }), pane)
end

local utility_keys = {
   -- 快速选择并打开 URL
   map('u', SUPER, act.QuickSelectArgs({
      label = 'open url',
      patterns = { 'https?://\\S+' },
      action = callback(open_selected_url),
   })),
   -- 发送换行符（解决某些终端需要 Shift+Enter 的情况）
   map('Enter', 'SHIFT', wezterm.action({ SendString = '\x1b\r' })),
   -- 重新加载配置
   map('r', SUPER_ALT, act.ReloadConfiguration),
   -- 打开 Launcher 菜单（快速选择 SSH 主机/Shell）
   map('t', SUPER_ALT, act.ShowLauncher),
   -- 打开命令面板，便于发现和搜索 WezTerm 动作
   map('p', SUPER_SHIFT, act.ActivateCommandPalette),
   -- 手动重命名当前标签页
   map('r', SUPER_SHIFT, callback(rename_current_tab)),
   -- 远程连接选择器（WezTerm mux domain + ~/.ssh/config）
   map('s', SUPER_SHIFT, remote_picker.action()),
}

local clipboard_keys = {
   map('c', SUPER, act.CopyTo('Clipboard')),
   map('v', SUPER, act.PasteFrom('Clipboard')),
}

local window_keys = {
   map('n', SUPER, act.SpawnWindow),
   -- 切换 macOS 原生全屏
   map('f', SUPER, act.ToggleFullScreen),
}

-- 新建标签页时，自动继承当前 pane 的 domain（SSH 远程则继续连接远程）
local function spawn_tab_in_current_domain(window, pane)
   local domain = pane:get_domain_name()
   if domain and domain ~= LOCAL_DOMAIN then
      window:perform_action(act.SpawnTab({ DomainName = domain }), pane)
   else
      window:perform_action(act.SpawnTab({ DomainName = LOCAL_DOMAIN }), pane)
   end
end

-- 不继承当前远程 domain，强制打开本地标签页
local function spawn_local_tab(window, pane)
   window:perform_action(act.SpawnTab({ DomainName = LOCAL_DOMAIN }), pane)
end

local tab_keys = {
   map('t', SUPER, callback(spawn_tab_in_current_domain)),
   map('t', SUPER_SHIFT, callback(spawn_local_tab)),
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
   map('o', SUPER_SHIFT, act.PaneSelect({
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
