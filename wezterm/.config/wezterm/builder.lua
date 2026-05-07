local wezterm = require('wezterm')

local M = {}

local function merge_options(options, new_options, source)
   for key, value in pairs(new_options) do
      if options[key] ~= nil then
         wezterm.log_warn('Config option overridden by ' .. source .. ': ' .. key)
      end
      options[key] = value
   end
end

function M.build(module_names)
   local options = wezterm.config_builder()

   for _, module_name in ipairs(module_names) do
      local module_options = require(module_name)
      merge_options(options, module_options, module_name)
   end

   return options
end

return M
