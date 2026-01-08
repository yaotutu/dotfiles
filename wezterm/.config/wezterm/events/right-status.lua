-- events/right-status.lua
local wezterm = require('wezterm')

local M = {}
local nf = wezterm.nerdfonts

-- local ->  local；其他域 -> 󰢹 name
local function location_label(pane, window)
   local ok, name = pcall(function()
      return pane:get_domain_name()
   end)

   if not ok or not name or name == '' then
      name = '?'
   end

   local icon
   if name == 'local' then
      icon = nf.md_laptop or ''
   else
      icon = nf.md_server or '󰢹'
   end

   local label = icon .. ' ' .. name

   -- 非 default 的 workspace 才显示
   local ws = window:active_workspace()
   if ws and ws ~= 'default' then
      label = label .. ' · ' .. ws
   end

   return label
end

-- 模式标签：key table / leader
local function mode_label(window)
   local keytbl = window:active_key_table()
   if keytbl then
      -- 用小写 + 简短前缀，看起来没那么吵
      return keytbl:lower()
   elseif window:leader_is_active() then
      -- 一个小标记即可
      return 'Ⓛ'
   end
   return nil
end

local function build_right_status(window, pane)
   local parts = {}

   -- 1) 位置： local · ai3d / 󰢹 nvidia · ai3d
   table.insert(parts, location_label(pane, window))

   -- 2) 模式（可选）
   local mode = mode_label(window)
   if mode then
      table.insert(parts, mode)
   end

   -- 3) 时间（小时:分钟就够用了，秒会有点跳眼）
   local time = wezterm.strftime('%H:%M')
   table.insert(parts, time)

   local text = ' ' .. table.concat(parts, '  ·  ') .. ' '

   return wezterm.format({
      { Attribute = { Intensity = 'Half' } }, -- 整体稍微淡一点
      { Text = text },
   })
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
