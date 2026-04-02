-- tabline.wez 已接管 tab-title 和 right-status
-- 这里只保留插件不管的事件

local M = {}

function M.setup()
   require('events.new-tab-button').setup()
end

return M
