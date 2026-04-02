-- 格式化单元格工具类
-- 灵感来自 KevinSilvester/wezterm-config
-- 用于管理 wezterm.format() 的 FormatItem 数组，支持分段式渲染

-- 属性生成器
local attr = {}

---@param type 'Bold'|'Half'|'Normal'
---@return {Attribute: {Intensity: string}}
function attr.intensity(type)
   return { Attribute = { Intensity = type } }
end

---@return {Attribute: {Italic: boolean}}
function attr.italic()
   return { Attribute = { Italic = true } }
end

---@param type 'None'|'Single'|'Double'|'Curly'
---@return {Attribute: {Underline: string}}
function attr.underline(type)
   return { Attribute = { Underline = type } }
end

---@alias Cells.SegmentColors {bg?: string, fg?: string}

---格式化单元格管理器
---@class FormatCells
---@field segments table<string|number, {items: table[], has_bg: boolean, has_fg: boolean}>
local Cells = {}
Cells.__index = Cells

---属性生成器（支持链式调用多个属性）
---@class Cells.Attributes
Cells.attr = setmetatable(attr, {
   __call = function(_, ...)
      return { ... }
   end,
})

---@return FormatCells
function Cells:new()
   return setmetatable({ segments = {} }, self)
end

---添加新的渲染段
---@param segment_id string|number 段 ID
---@param text string 显示文本
---@param color? Cells.SegmentColors 背景色和前景色
---@param attributes? table[] 属性列表（如加粗）
function Cells:add_segment(segment_id, text, color, attributes)
   color = color or {}

   local items = {}

   if color.bg then
      table.insert(items, { Background = { Color = color.bg } })
   end
   if color.fg then
      table.insert(items, { Foreground = { Color = color.fg } })
   end
   if attributes and #attributes > 0 then
      for _, a in ipairs(attributes) do
         table.insert(items, a)
      end
   end
   table.insert(items, { Text = text })
   table.insert(items, 'ResetAttributes')

   self.segments[segment_id] = {
      items = items,
      has_bg = color.bg ~= nil,
      has_fg = color.fg ~= nil,
   }

   return self
end

---检查段是否存在
---@private
---@param segment_id string|number
function Cells:_check_segment(segment_id)
   if not self.segments[segment_id] then
      error('Segment "' .. segment_id .. '" not found')
   end
end

---更新段的文本
---@param segment_id string|number
---@param text string
function Cells:update_segment_text(segment_id, text)
   self:_check_segment(segment_id)
   local idx = #self.segments[segment_id].items - 1
   self.segments[segment_id].items[idx] = { Text = text }
   return self
end

---更新段的颜色
---@param segment_id string|number
---@param color Cells.SegmentColors
function Cells:update_segment_colors(segment_id, color)
   self:_check_segment(segment_id)

   local has_bg = self.segments[segment_id].has_bg
   local has_fg = self.segments[segment_id].has_fg

   if color.bg then
      if has_bg then
         self.segments[segment_id].items[1] = { Background = { Color = color.bg } }
      else
         table.insert(self.segments[segment_id].items, 1, { Background = { Color = color.bg } })
         has_bg = true
      end
   end

   if color.fg then
      local fg_idx = has_bg and 2 or 1
      if has_fg then
         self.segments[segment_id].items[fg_idx] = { Foreground = { Color = color.fg } }
      else
         table.insert(self.segments[segment_id].items, fg_idx, { Foreground = { Color = color.fg } })
         has_fg = true
      end
   end

   self.segments[segment_id].has_bg = has_bg
   self.segments[segment_id].has_fg = has_fg
   return self
end

---按指定顺序渲染段为 FormatItem 数组
---@param ids table<string|number> 段 ID 列表
---@return table[] FormatItem 数组
function Cells:render(ids)
   local cells = {}

   for _, id in ipairs(ids) do
      self:_check_segment(id)
      for _, item in pairs(self.segments[id].items) do
         table.insert(cells, item)
      end
   end

   return cells
end

---重置所有段
function Cells:reset()
   self.segments = {}
   return self
end

return Cells
