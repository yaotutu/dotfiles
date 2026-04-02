local M = {}

function M.setup()
   require('events.tab-title').setup()
   require('events.right-status').setup()
   require('events.new-tab-button').setup()
end

return M
