local wezterm = require('wezterm')

local target = wezterm.target_triple
local is_win = target:find('windows', 1, true) ~= nil
local is_linux = target:find('linux', 1, true) ~= nil
local is_mac = target:find('apple', 1, true) ~= nil

return {
   os = is_win and 'windows' or is_linux and 'linux' or is_mac and 'mac' or 'unknown',
   is_win = is_win,
   is_linux = is_linux,
   is_mac = is_mac,
}
