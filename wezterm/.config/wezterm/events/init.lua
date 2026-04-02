-- 事件注册入口
local M = {}

function M.setup()
   require('events.tab-title').setup()
   require('events.right-status').setup()
end

return M
