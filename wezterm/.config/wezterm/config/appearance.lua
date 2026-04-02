local wezterm = require('wezterm')
local gpu_adapters = require('utils.gpu_adapter')
local theme = require('colors.theme')
local colors = theme.terminal

return {
   animation_fps = 60,
   max_fps = 60,
   front_end = 'WebGpu',
   webgpu_power_preference = 'HighPerformance',
   webgpu_preferred_adapter = gpu_adapters:pick_best(),

   -- 颜色主题
   colors = colors,

   -- 背景设置
   background = {
      {
         source = { File = wezterm.GLOBAL.background },
         horizontal_align = 'Center',
      },
      {
         source = { Color = theme.chrome.background.tint },
         height = '100%',
         width = '100%',
         opacity = theme.chrome.background.opacity,
      },
   },

   -- 滚动条
   enable_scroll_bar = true,

   -- 标签栏
   enable_tab_bar = true,
   hide_tab_bar_if_only_one_tab = false,
   use_fancy_tab_bar = false,
   -- tab_max_width 不设限制，让标题完整显示
   show_tab_index_in_tab_bar = false,
   switch_to_last_active_tab_when_closing_tab = true,

   -- 窗口设置
   window_padding = {
      left = theme.chrome.padding.left,
      right = theme.chrome.padding.right,
      top = theme.chrome.padding.top,
      bottom = theme.chrome.padding.bottom,
   },
   window_close_confirmation = 'NeverPrompt',
   window_frame = {
      active_titlebar_bg = theme.chrome.frame.active_titlebar_bg,
      inactive_titlebar_bg = theme.chrome.frame.inactive_titlebar_bg,
      -- macOS 使用原生标题栏，边框设置无效
      border_left_width = '0px',
      border_right_width = '0px',
      border_top_height = '0px',
      border_bottom_height = '0px',
   },
}
