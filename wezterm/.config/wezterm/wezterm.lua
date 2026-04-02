local wezterm = require('wezterm')
local config_builder = require('config')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local backdrops = require('utils.backdrops')
local agent_deck_config = require('config.agent_deck')

backdrops:set_files():random()

require('events').setup()

local config = config_builder.build({
   'config.appearance',
   'config.bindings',
   'config.domains',
   'config.fonts',
   'config.general',
   'config.launch',
})

config.status_update_interval = agent_deck_config.update_interval

if agent_deck_config.notifications.suppress_osc_notifications then
   config.notification_handling = 'NeverShow'
end

agent_deck.setup(agent_deck_config)

return config
