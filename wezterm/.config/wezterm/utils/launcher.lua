local wezterm = require('wezterm')

local M = {}

function M.show_launcher_action()
   return wezterm.action.ShowLauncherArgs({
      title = 'Remote-First Launcher',
      flags = 'FUZZY|LAUNCH_MENU_ITEMS',
   })
end

return M
