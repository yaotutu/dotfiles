local palette = {
   rosewater = '#f5e0dc',
   flamingo = '#f2cdcd',
   pink = '#f5c2e7',
   mauve = '#cba6f7',
   red = '#f38ba8',
   maroon = '#eba0ac',
   peach = '#fab387',
   yellow = '#f9e2af',
   green = '#a6e3a1',
   teal = '#94e2d5',
   sky = '#89dceb',
   sapphire = '#74c7ec',
   blue = '#89b4fa',
   lavender = '#b4befe',
   text = '#cdd6f4',
   subtext1 = '#bac2de',
   subtext0 = '#a6adc8',
   overlay2 = '#9399b2',
   overlay1 = '#7f849c',
   overlay0 = '#6c7086',
   surface2 = '#585b70',
   surface1 = '#45475a',
   surface0 = '#313244',
   base = '#1f1f28',
   mantle = '#181825',
   crust = '#11111b',
}

local chrome = {
   -- 不使用透明背景，避免视觉重叠
   glass = palette.base,
   tab = {
      active = {
         bg = palette.blue,
         fg = palette.crust,
      },
      hover = {
         bg = palette.surface2,
         fg = palette.text,
      },
      inactive = {
         bg = palette.surface0,
         fg = palette.subtext1,
      },
      unseen = palette.yellow,
   },
   status = {
      text = palette.subtext1,
      quiet = palette.subtext0,
      separator = palette.overlay0,
      mode = palette.lavender,
   },
   frame = {
      active_titlebar_bg = palette.crust,
      inactive_titlebar_bg = palette.mantle,
   },
   background = {
      tint = palette.base,
      opacity = 0.94,
   },
   padding = {
      left = 5,
      right = 10,
      top = 12,
      bottom = 7,
   },
}

local agent = {
   working = palette.green,
   waiting = palette.yellow,
   idle = palette.sky,
   inactive = palette.overlay1,
}

local terminal = {
   foreground = palette.text,
   background = palette.base,
   cursor_bg = palette.rosewater,
   cursor_border = palette.rosewater,
   cursor_fg = palette.crust,
   selection_bg = palette.surface2,
   selection_fg = palette.text,
   ansi = {
      '#0C0C0C',
      '#C50F1F',
      '#13A10E',
      '#C19C00',
      '#0037DA',
      '#881798',
      '#3A96DD',
      '#CCCCCC',
   },
   brights = {
      '#767676',
      '#E74856',
      '#16C60C',
      '#F9F1A5',
      '#3B78FF',
      '#B4009E',
      '#61D6D6',
      '#F2F2F2',
   },
   tab_bar = {
      background = chrome.glass,
      active_tab = {
         bg_color = chrome.tab.active.bg,
         fg_color = chrome.tab.active.fg,
      },
      inactive_tab = {
         bg_color = chrome.tab.inactive.bg,
         fg_color = chrome.tab.inactive.fg,
      },
      inactive_tab_hover = {
         bg_color = chrome.tab.hover.bg,
         fg_color = chrome.tab.hover.fg,
      },
      new_tab = {
         bg_color = palette.base,
         fg_color = palette.text,
      },
      new_tab_hover = {
         bg_color = palette.mantle,
         fg_color = palette.text,
         italic = true,
      },
   },
   visual_bell = palette.surface0,
   indexed = {
      [16] = palette.peach,
      [17] = palette.rosewater,
   },
   scrollbar_thumb = palette.surface2,
   split = palette.lavender,
   compose_cursor = palette.flamingo,
}

return {
   palette = palette,
   chrome = chrome,
   agent = agent,
   terminal = terminal,
}
