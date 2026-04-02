-- events/right-status.lua
local wezterm = require('wezterm')
local agent_deck = wezterm.plugin.require('https://github.com/Eric162/wezterm-agent-deck')
local theme = require('colors.theme')
local pane_utils = require('utils.pane')

local M = {}

local function add_part(items, text, color)
   if #items > 1 then
      table.insert(items, { Foreground = { Color = theme.chrome.status.separator } })
      table.insert(items, { Text = '  ·  ' })
   end

   table.insert(items, { Foreground = { Color = color or theme.chrome.status.text } })
   table.insert(items, { Text = text })
end

local function build_right_status(window, pane)
   pane_utils.refresh_agent_states(window, agent_deck)

   local items = {
      { Text = ' ' },
   }

   add_part(items, pane_utils.get_location_label(pane, window), theme.chrome.status.text)

   local counts = agent_deck.count_agents_by_status()
   if counts then
      local waiting = counts.waiting or 0
      local working = counts.working or 0

      if waiting > 0 then
         add_part(items, '◔ ' .. waiting, theme.agent.waiting)
      end

      if working > 0 then
         add_part(items, '● ' .. working, theme.agent.working)
      end
   end

   local mode = pane_utils.get_mode_label(window)
   if mode then
      add_part(items, mode, theme.chrome.status.mode)
   end

   add_part(items, wezterm.strftime('%H:%M'), theme.chrome.status.quiet)
   table.insert(items, { Text = ' ' })

   return wezterm.format(items)
end

M.setup = function()
   wezterm.on('update-right-status', function(window, pane)
      local ok, formatted = pcall(build_right_status, window, pane)

      local text
      if ok then
         text = formatted
      else
         wezterm.log_error('right-status error: ' .. tostring(formatted))
         text = wezterm.format({
            { Text = ' [rs err] ' },
         })
      end

      window:set_right_status(text)
   end)
end

return M
