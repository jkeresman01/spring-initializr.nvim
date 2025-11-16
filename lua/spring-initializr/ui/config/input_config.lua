-- lua/spring-initializr/ui/config/input_config.lua
local M = {}
M.__index = M

function M.new(title, key, default, selections)
    return setmetatable({
        title = title,
        key = key,
        default = default or "",
        selections = selections,
    }, M)
end

return M