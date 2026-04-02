local wezterm = require('wezterm')
local platform = require('utils.platform')

---@alias WeztermGPUBackend 'Vulkan'|'Metal'|'Gl'|'Dx12'
---@alias WeztermGPUDeviceType 'DiscreteGpu'|'IntegratedGpu'|'Cpu'|'Other'

---@class WeztermGPUAdapter
---@field name string
---@field backend WeztermGPUBackend
---@field device number
---@field device_type WeztermGPUDeviceType
---@field driver? string
---@field driver_info? string
---@field vendor string

---@class GpuAdapters
---@field __backends WeztermGPUBackend[]
---@field __preferred_backend WeztermGPUBackend
---@field DiscreteGpu table|nil
---@field IntegratedGpu table|nil
---@field Cpu table|nil
---@field Other table|nil
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters

-- 各平台支持的图形后端
GpuAdapters.AVAILABLE_BACKENDS = {
   linux = { 'Vulkan', 'Gl' },
   mac = { 'Metal' },
}

---@type WeztermGPUAdapter[]
GpuAdapters.ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---@return GpuAdapters
---@private
function GpuAdapters:init()
   local backends = self.AVAILABLE_BACKENDS[platform.os] or { 'Gl' }
   local initial = {
      __backends = backends,
      __preferred_backend = backends[1],
      DiscreteGpu = nil,
      IntegratedGpu = nil,
      Cpu = nil,
      Other = nil,
   }

   -- 遍历枚举的 GPU，按 device_type 和 backend 分类
   for _, adapter in ipairs(self.ENUMERATED_GPUS) do
      if not initial[adapter.device_type] then
         initial[adapter.device_type] = {}
      end
      initial[adapter.device_type][adapter.backend] = adapter
   end

   return setmetatable(initial, self)
end

---选择最佳 GPU 适配器
---优先级: DiscreteGpu > IntegratedGpu > Other > Cpu
---@return WeztermGPUAdapter|nil
function GpuAdapters:pick_best()
   local adapters = self.DiscreteGpu
      or self.IntegratedGpu
      or self.Other
      or self.Cpu

   if not adapters then
      return nil
   end

   return adapters[self.__preferred_backend]
end

return GpuAdapters:init()
