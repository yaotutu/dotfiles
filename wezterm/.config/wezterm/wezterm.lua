local wezterm = require('wezterm')
local config_builder = require('config')
local backdrops = require('utils.backdrops')
local agent_deck_config = require('config.agent_deck')
local tabline_config = require('config.tabline')

backdrops:set_files():random()

-- 加载插件
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local tabline = wezterm.plugin.require('https://github.com/michaelbrusegard/tabline.wez')

-- 设置事件（tabline 会接管 tab 和 status，所以选择性加载）
require('events.tab-title').setup() -- 保留自定义 tab 标题逻辑

local config = config_builder.build({
   'config.appearance',
   'config.bindings',
   'config.domains',
   'config.fonts',
   'config.general',
   'config.launch',
})

-- agent-deck 配置
config.status_update_interval = agent_deck_config.update_interval
if agent_deck_config.notifications.suppress_osc_notifications then
   config.notification_handling = 'NeverShow'
end
agent_deck.setup(agent_deck_config)

-- tabline 配置（会接管 tab bar 和右侧状态栏）
tabline.setup(tabline_config)
tabline.apply_to_config(config)

return config
