local wezterm = require('wezterm')

local M = {}

function M.list()
   local hosts = {}
   local ssh_config_file = wezterm.home_dir .. '/.ssh/config'
   local file = io.open(ssh_config_file)
   if not file then
      return hosts
   end

   local seen = {}
   for line in file:lines() do
      local declaration = line:match('^%s*[Hh]ost%s+(.+)$')
      if declaration then
         for host in declaration:gmatch('%S+') do
            local is_glob = host:find('[%*%?]') ~= nil
            local is_negated = host:sub(1, 1) == '!'
            if host ~= '' and not is_glob and not is_negated and not seen[host] then
               seen[host] = true
               table.insert(hosts, host)
            end
         end
      end
   end

   file:close()
   table.sort(hosts)
   return hosts
end

return M
