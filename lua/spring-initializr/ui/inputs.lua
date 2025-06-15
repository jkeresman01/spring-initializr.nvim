--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/input.lua
-- Author: Josip Keresman

local Input = require("nui.input")
local Layout = require("nui.layout")
local focus = require("spring-initializr.ui.focus")

local function create_input(title, key, default, selections)
    local input = Input({
        border = {
            style = "rounded",
            text = { top = title, top_align = "left" },
        },
        size = { width = 40 },
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    }, {
        default_value = default or "",
        on_change = function(val)
            selections[key] = val
        end,
        on_submit = function(val)
            selections[key] = val
            require("spring-initializr.utils.message").info(title .. ": " .. val)
        end,
    })

    selections[key] = default or ""
    focus.register(input)
    return Layout.Box(input, { size = 3 })
end

return {
    create_input = create_input,
}
