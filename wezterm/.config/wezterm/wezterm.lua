local wezterm = require('wezterm')
local builder = require('builder')
local backdrops = require('utils.backdrops')

backdrops:set_files():random()

-- 启动时自动进入 macOS 原生全屏
wezterm.on('gui-startup', function(cmd)
   local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
   window:gui_window():toggle_fullscreen()
end)

-- 加载插件（tabline 接管 tab bar 和 status bar）
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

local config = builder.build({
   'core.appearance',
   'core.bindings',
   'core.domains',
   'core.fonts',
   'core.general',
   'core.launch',
})

-- agent-deck 配置
local agent_deck_config = require('plugins.agent-deck')
config.status_update_interval = agent_deck_config.update_interval
if agent_deck_config.notifications.suppress_osc_notifications then
   config.notification_handling = 'NeverShow'
end
agent_deck.setup(agent_deck_config)

-- tabline 接管 tab bar 和 status bar
local tabline_config = require('plugins.tabline')
tabline.setup(tabline_config)
tabline.apply_to_config(config)

-- tabline.apply_to_config 会把 window_padding 覆盖为 0，需要重新设置
local theme = require('theme.catppuccin')
config.window_padding = {
   left = theme.chrome.padding.left,
   right = theme.chrome.padding.right,
   top = theme.chrome.padding.top,
   bottom = theme.chrome.padding.bottom,
}

return config
