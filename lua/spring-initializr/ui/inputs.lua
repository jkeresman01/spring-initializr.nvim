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
--
-- This module defines reusable input components used in the Spring Initializr UI.

local Input = require("nui.input")
local Layout = require("nui.layout")

local focus = require("spring-initializr.ui.focus")
local msg = require("spring-initializr.utils.message")

local M = {}

--- Constructs popup border and size settings for an input field.
--
-- @param title string
-- @return table
local function build_input_popup_opts(title)
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

--- Creates input change and submit handlers that update user selections.
--
-- @param key string
-- @param title string
-- @param selections table
-- @return table
local function build_input_handlers(key, title, selections)
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

--- Creates and returns an Input popup component.
--
-- @param title string
-- @param key string
-- @param default string
-- @param selections table
-- @return Input
local function create_input_component(title, key, default, selections)
    local popup_opts = build_input_popup_opts(title)
    local handlers = build_input_handlers(key, title, selections)

    return Input(popup_opts, {
        default_value = default or "",
        on_change = handlers.on_change,
        on_submit = handlers.on_submit,
    })
end

--- Public API to create a layout-wrapped input component for Spring Initializr.
--
-- @param title string
-- @param key string
-- @param default string
-- @param selections table
-- @return Layout.Box
function M.create_input(title, key, default, selections)
    selections[key] = default or ""
    local input = create_input_component(title, key, default, selections)
    focus.register(input)
    return Layout.Box(input, { size = 3 })
end

return M
