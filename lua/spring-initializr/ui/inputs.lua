----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--
-- Defines reusable input components used in the Spring Initializr UI.
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Input = require("nui.input")
local Layout = require("nui.layout")

local focus = require("spring-initializr.ui.focus")
local msg = require("spring-initializr.utils.message")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Constructs popup border and size settings for an input field.
--
-- @param  title  string  Field title
--
-- @return table          Popup configuration
--
----------------------------------------------------------------------------
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

----------------------------------------------------------------------------
--
-- Creates input change and submit handlers that update user selections.
--
-- @param  key         string  Field key
-- @param  title       string  Field title
-- @param  selections  table   State table to store values
--
-- @return table               Handlers for input events
--
----------------------------------------------------------------------------
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

----------------------------------------------------------------------------
--
-- Creates and returns an Input popup component.
--
-- @param  title       string  Field title
-- @param  key         string  Field key
-- @param  default     string  Default value
-- @param  selections  table   State table to store values
--
-- @return Input               Input popup component
--
----------------------------------------------------------------------------
local function create_input_component(title, key, default, selections)
    local popup_opts = build_input_popup_opts(title)
    local handlers = build_input_handlers(key, title, selections)

    return Input(popup_opts, {
        default_value = default or "",
        on_change = handlers.on_change,
        on_submit = handlers.on_submit,
    })
end

----------------------------------------------------------------------------
--
-- Create a layout-wrapped input component for Spring Initializr.
--
-- @param  title       string       Field title
-- @param  key         string       Field key
-- @param  default     string       Default value
-- @param  selections  table        State table to store values
--
-- @return Layout.Box               Layout-wrapped input component
--
----------------------------------------------------------------------------
function M.create_input(title, key, default, selections)
    selections[key] = default or ""
    local input = create_input_component(title, key, default, selections)
    focus.register(input)
    return Layout.Box(input, { size = 3 })
end

return M
