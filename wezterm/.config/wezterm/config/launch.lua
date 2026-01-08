local platform = require('utils.platform')()
local wezterm = require('wezterm')

local options = {
   default_prog = {},
   launch_menu = {},
}

-- 1. 按平台设置 default_prog 和本地 launch_menu -------------------------

if platform.is_win then
   options.default_prog = { 'pwsh' }
   options.launch_menu = {
      { label = 'PowerShell Core',    args = { 'pwsh' } },
      { label = 'PowerShell Desktop', args = { 'powershell' } },
      { label = 'Command Prompt',     args = { 'cmd' } },
      { label = 'Nushell',            args = { 'nu' } },
      {
         label = 'Git Bash',
         args = { 'C:\\Users\\kevin\\scoop\\apps\\git\\current\\bin\\bash.exe' },
      },
   }
elseif platform.is_mac then
   options.default_prog = { 'zsh', '-l' }
   -- 如果需要本地 shell 菜单可以解开这里
   -- options.launch_menu = {
   --   { label = 'Bash',    args = { 'bash', '-l' } },
   --   { label = 'Fish',    args = { '/opt/homebrew/bin/fish', '-l' } },
   --   { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },
   --   { label = 'Zsh',     args = { 'zsh', '-l' } },
   -- }
elseif platform.is_linux then
   options.default_prog = { 'fish', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { 'fish', '-l' } },
      { label = 'Zsh',  args = { 'zsh', '-l' } },
   }
end

-- 2. 从 ~/.ssh/config 读取 Host，生成“普通 ssh”菜单 -----------------------

local ssh_cmd = { 'ssh' }

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
   ssh_cmd = { 'powershell.exe', 'ssh' }
end

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
            -- 拷贝 ssh_cmd
            local args = {}
            for i, v in ipairs(ssh_cmd) do
               args[i] = v
            end
            args[#args + 1] = host

            -- 普通 ssh 菜单：SSH <host>
            table.insert(options.launch_menu, {
               label = 'SSH ' .. host,
               args = args,
            })

            -- 默认打开 vm
            if host == 'vm' then
               options.default_prog = args
            end
         end
      end
      line = f:read('*l')
   end
   f:close()
end

-- 3. 基于 ssh_domains 生成 “SSH <name> (mux)” 菜单（当前窗口开远程 tab） --

-- 这里假设你有 config/domains.lua，返回类似：
-- return {
--   ssh_backend = 'LibSsh',
--   ssh_domains = {
--     {
--       name = 'nvidia',
--       remote_address = '192.168.110.239',
--       username = 'yaotutu',
--       multiplexing = 'WezTerm',
--       remote_wezterm_path = '/usr/bin/wezterm',
--       assume_shell = 'Posix',
--     },
--   },
-- }
local ok, domains_mod = pcall(require, 'config.domains')
if ok and domains_mod and domains_mod.ssh_domains then
   for _, dom in ipairs(domains_mod.ssh_domains) do
      -- 使用 SpawnTabDomain：DomainName = dom.name
      -- 点击时效果等价于 SpawnTab { DomainName = 'nvidia' }
      table.insert(options.launch_menu, {
         label = 'SSH ' .. dom.name .. ' (mux)',
         domain = { DomainName = dom.name },
         -- 不写 args => 使用远端默认 shell
      })
   end
end

return options
