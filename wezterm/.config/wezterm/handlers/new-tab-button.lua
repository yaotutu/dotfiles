local wezterm = require('wezterm')
local launcher = require('utils.launcher')

local M = {}

M.setup = function()
   wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
      if default_action and button == 'Left' then
         window:perform_action(default_action, pane)
      end

      if default_action and button == 'Right' then
         window:perform_action(launcher.show_launcher_action(), pane)
      end
      return false
   end)
end

return M
