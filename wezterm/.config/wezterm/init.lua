local wezterm = require('wezterm')
local builder = require('builder')
local backdrops = require('utils.backdrops')

backdrops:set_files():random()

-- 加载插件（tabline 接管 tab bar 和 status bar）
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

-- 只加载 tabline 不管的事件（如右键菜单）
require('handlers.new-tab-button').setup()

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

return config
