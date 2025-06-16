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
local msg = require("spring-initializr.utils.message")

local M = {}

local function make_input_popup(title)
    return {
        border = {
            style = "rounded",
            text = { top = title, top_align = "left" },
        },
        size = { width = 40 },
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    }
end

local function make_input_handlers(key, title, selections)
    return {
        on_change = function(val)
            selections[key] = val
        end,
        on_submit = function(val)
            selections[key] = val
            msg.info(title .. ": " .. val)
        end,
    }
end

local function create_input_popup(title, key, default, selections)
    local popup_opts = make_input_popup(title)
    local handlers = make_input_handlers(key, title, selections)

    return Input(popup_opts, {
        default_value = default or "",
        on_change = handlers.on_change,
        on_submit = handlers.on_submit,
    })
end

function M.create_input(title, key, default, selections)
    selections[key] = default or ""
    local input = create_input_popup(title, key, default, selections)
    focus.register(input)
    return Layout.Box(input, { size = 3 })
end

return M
