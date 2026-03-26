local wezterm = require('wezterm')
local colors = require('colors.custom')

-- 初始化随机种子
math.randomseed(os.time())
math.random()
math.random()
math.random()

-- macOS 使用 Unix 路径分隔符
local PATH_SEP = '/'

---@class BackDrops
---@field current_idx number index of current image
---@field files string[] background images
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
   local inital = {
      current_idx = 1,
      files = {},
   }
   local backdrops = setmetatable(inital, self)
   wezterm.GLOBAL.background = nil
   return backdrops
end

---MUST BE RUN BEFORE ALL OTHER `BackDrops` functions
---Sets the `files` after instantiating `BackDrops`.
function BackDrops:set_files()
   self.files = wezterm.read_dir(wezterm.config_dir .. PATH_SEP .. 'backdrops')
   wezterm.GLOBAL.background = self.files[1]
   return self
end

---Override the current window options for background
---@private
---@param window any WezTerm Window
function BackDrops:_set_opt(window)
   local opts = {
      background = {
         {
            source = { File = wezterm.GLOBAL.background },
            horizontal_align = 'Center',
         },
         {
            source = { Color = colors.background },
            height = '100%',
            width = '100%',
            opacity = 0.96,
         },
      },
   }
   window:set_config_overrides(opts)
end

---Convert the `files` array to a table of `InputSelector` choices
function BackDrops:choices()
   local choices = {}
   for idx, file in ipairs(self.files) do
      local name = file:match('([^' .. PATH_SEP .. ']+)$')
      table.insert(choices, {
         id = tostring(idx),
         label = name,
      })
   end
   return choices
end

---Select a random file
---@param window any? WezTerm Window
function BackDrops:random(window)
   self.current_idx = math.random(#self.files)
   wezterm.GLOBAL.background = self.files[self.current_idx]

   if window ~= nil then
      self:_set_opt(window)
   end
end

---Set a specific background from the `files` array
---@param window any WezTerm Window
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
   if idx > #self.files or idx < 0 then
      wezterm.log_error('Index out of range')
      return
   end

   self.current_idx = idx
   wezterm.GLOBAL.background = self.files[self.current_idx]
   self:_set_opt(window)
end

return BackDrops:init()
