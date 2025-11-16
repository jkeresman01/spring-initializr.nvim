-- lua/spring-initializr/ui/config/radio_config.lua
local M = {}
M.__index = M

function M.new(title, values, key, selections)
    return setmetatable({
        title = title,
        values = values,
        key = key,
        selections = selections,
    }, M)
end

return M
