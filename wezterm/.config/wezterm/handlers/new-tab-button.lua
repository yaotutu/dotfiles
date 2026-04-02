local wezterm = require('wezterm')
local launcher = require('utils.launcher')

local M = {}

M.setup = function()
   wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
      -- 右键打开 Launcher 菜单
      if button == 'Right' then
         window:perform_action(launcher.show_launcher_action(), pane)
      end
      return false
   end)
end

return M
