-- lua/spring-initializr/ui/config/form_context.lua
local M = {}
M.__index = M

function M.new(metadata, selections)
    return setmetatable({
        metadata = metadata,
        selections = selections,
    }, M)
end

-- Convenience methods to build configs
function M:radio_config(title, values, key)
    local RadioConfig = require("spring-initializr.ui.config.radio_config")
    return RadioConfig.new(title, values, key, self.selections)
end

function M:input_config(title, key, default)
    local InputConfig = require("spring-initializr.ui.config.input_config")
    return InputConfig.new(title, key, default, self.selections)
end

return M