local theme = require('theme.catppuccin')

return {
   update_interval = 500,

   colors = {
      working = theme.agent.working,
      waiting = theme.agent.waiting,
      idle = theme.agent.idle,
      inactive = theme.agent.inactive,
   },

   icons = {
      style = 'unicode',
      unicode = {
         working = '●',
         waiting = '◔',
         idle = '○',
         inactive = '◌',
      },
   },

   notifications = {
      enabled = true,
      on_waiting = true,
      on_finished = true,
      backend = 'native',
      suppress_osc_notifications = false,
   },
}
