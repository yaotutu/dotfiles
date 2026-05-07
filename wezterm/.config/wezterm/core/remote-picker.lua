local wezterm = require('wezterm')
local remotes = require('core.remotes')
local ssh_hosts = require('utils.ssh_hosts')

local act = wezterm.action
local callback = wezterm.action_callback

local LOCAL_DOMAIN = 'local'

local M = {}

local function add_choice(choices, seen, id, label)
   if seen[id] then
      return
   end

   seen[id] = true
   table.insert(choices, {
      id = id,
      label = label,
   })
end

local function build_choices()
   local choices = {}
   local seen = {}

   for _, remote in ipairs(remotes) do
      local label = 'MUX  ' .. remote.name
      if remote.remote_address and remote.remote_address ~= '' then
         label = label .. '  ' .. remote.remote_address
      end
      add_choice(choices, seen, 'domain:' .. remote.name, label)
   end

   for _, host in ipairs(ssh_hosts.list()) do
      add_choice(choices, seen, 'ssh:' .. host, 'SSH  ' .. host)
   end

   return choices
end

local function connect_remote(window, pane, id)
   if not id then
      return
   end

   local kind, value = id:match('^([^:]+):(.+)$')
   if kind == 'domain' then
      window:perform_action(act.SpawnTab({ DomainName = value }), pane)
   elseif kind == 'ssh' then
      window:perform_action(act.SpawnCommandInNewTab({
         domain = { DomainName = LOCAL_DOMAIN },
         args = { 'ssh', value },
      }), pane)
   end
end

function M.action()
   return callback(function(window, pane)
      window:perform_action(act.InputSelector({
         title = 'Connect Remote',
         choices = build_choices(),
         fuzzy = true,
         fuzzy_description = 'Connect Remote: ',
         action = callback(connect_remote),
      }), pane)
   end)
end

return M
