local platform = require('utils.platform')
local remotes = require('core.remotes')
local ssh_hosts = require('utils.ssh_hosts')

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

local function build_launch_menu()
   local launch_menu = {}
   local seen = {}

   for _, remote in ipairs(remotes) do
      add_entry(launch_menu, seen, {
         label = 'Remote ' .. remote.name .. ' (mux)',
         domain = { DomainName = remote.name },
      }, 'mux:' .. remote.name)
   end

   for _, host in ipairs(ssh_hosts.list()) do
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
