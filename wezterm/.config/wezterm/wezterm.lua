local wezterm = require('wezterm')
local builder = require('builder')
local backdrops = require('utils.backdrops')

backdrops:set_files():random()

-- 启动时自动进入 macOS 原生全屏
wezterm.on('gui-startup', function(cmd)
   local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
   window:gui_window():toggle_fullscreen()
end)

-- 加载插件
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')

-- 注册自定义事件（tab 标题 + 右侧状态栏）
require('events').setup()

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

return config
