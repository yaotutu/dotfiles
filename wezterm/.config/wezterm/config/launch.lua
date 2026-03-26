local platform = require('utils.platform')()
local wezterm = require('wezterm')

local options = {
   default_prog = {},
   launch_menu = {},
}

-- 根据平台设置默认 shell -------------------------

if platform.is_mac then
   options.default_prog = { 'zsh', '-l' }
elseif platform.is_linux then
   options.default_prog = { 'fish', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh',  args = { 'zsh', '-l' } },
   }
end

-- 从 ~/.ssh/config 读取 Host，生成 SSH 菜单 -----------------------

local ssh_config_file = wezterm.home_dir .. '/.ssh/config'
local f = io.open(ssh_config_file)
if f then
   local line = f:read('*l')
   while line do
      if line:find('Host ') == 1 then
         -- 去掉前缀和多余空白
         local host = line:gsub('Host ', ''):gsub('%s+', '')
         -- 跳过空 Host / 通配符
         if host ~= '' and host ~= '*' then
            -- 普通 ssh 菜单：SSH <host>
            table.insert(options.launch_menu, {
               label = 'SSH ' .. host,
               args = { 'ssh', host },
            })
         end
      end
      line = f:read('*l')
   end
   f:close()
end

-- 基于 ssh_domains 生成 "SSH <name> (mux)" 菜单（WezTerm 多路复用）--

local ok, domains_mod = pcall(require, 'config.domains')
if ok and domains_mod and domains_mod.ssh_domains then
   for _, dom in ipairs(domains_mod.ssh_domains) do
      table.insert(options.launch_menu, {
         label = 'SSH ' .. dom.name .. ' (mux)',
         domain = { DomainName = dom.name },
      })
   end
end

return options
