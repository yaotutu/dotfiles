local platform = require('utils.platform')
local wezterm = require('wezterm')
local remotes = require('core.remotes')

local function add_entry(launch_menu, seen, entry, key)
   if seen[key] then
      return
   end

   seen[key] = true
   table.insert(launch_menu, entry)
end

local function default_prog()
   if platform.is_mac then
      return { 'zsh', '-l' }
   end

   if platform.is_linux then
      return { 'fish', '-l' }
   end

   return {}
end

local function local_shell_entries()
   local entries = {
      { label = 'Local Default Shell', args = default_prog() },
   }

   if platform.is_linux then
      table.insert(entries, { label = 'Local Bash', args = { 'bash', '-l' } })
      table.insert(entries, { label = 'Local Fish', args = { 'fish', '-l' } })
      table.insert(entries, { label = 'Local Zsh', args = { 'zsh', '-l' } })
   end

   return entries
end

local function ssh_config_hosts()
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

local function build_launch_menu()
   local launch_menu = {}
   local seen = {}

   for _, remote in ipairs(remotes) do
      add_entry(launch_menu, seen, {
         label = 'Remote ' .. remote.name .. ' (mux)',
         domain = { DomainName = remote.name },
      }, 'mux:' .. remote.name)
   end

   for _, host in ipairs(ssh_config_hosts()) do
      add_entry(launch_menu, seen, {
         label = 'SSH ' .. host,
         args = { 'ssh', host },
      }, 'ssh:' .. host)
   end

   for _, entry in ipairs(local_shell_entries()) do
      add_entry(launch_menu, seen, entry, entry.label)
   end

   return launch_menu
end

return {
   default_prog = default_prog(),
   launch_menu = build_launch_menu(),
}
