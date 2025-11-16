---------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--
-- spring-initializr.nvim
--
--
-- Copyright (C) 2025 Josip Keresman
--
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Defines reusable input components used in the Spring Initializr UI.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Input = require("nui.input")
local Layout = require("nui.layout")

local focus_manager = require("spring-initializr.ui.managers.focus_manager")
local message_utils = require("spring-initializr.utils.message_utils")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local INPUT_WIDTH = 40

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Build the border config for an input popup.
--
-- @param  title  string  Field title
--
-- @return table          Border configuration
--
----------------------------------------------------------------------------
local function input_border(title)
    return { style = "rounded", text = { top = title, top_align = "left" } }
end

----------------------------------------------------------------------------
--
-- Build the size config for an input popup.
--
-- @return table  Size configuration
--
----------------------------------------------------------------------------
local function input_size()
    return { width = INPUT_WIDTH }
end

----------------------------------------------------------------------------
--
-- Build window options for an input popup.
--
-- @return table  Window options
--
----------------------------------------------------------------------------
local function input_win_options()
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" }
end

----------------------------------------------------------------------------
--
-- Constructs popup options table for an input field.
--
-- @param  title  string  Field title
--
-- @return table          Popup configuration
--
----------------------------------------------------------------------------
local function build_input_popup_opts(title)
    return {
        border = input_border(title),
        size = input_size(),
        win_options = input_win_options(),
    }
end

----------------------------------------------------------------------------
--
-- Updates a selected field value and displays a message.
--
-- @param selections table   Table holding current user selections
-- @param key        string  Field key to update
-- @param title      string  Human-readable label for the field
-- @param val        any     New value to store and display
--
----------------------------------------------------------------------------
local function update_selection(selections, key, title, val)
    selections[key] = val
    message_utils.show_info_message(title .. ": " .. val)
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
            update_selection(selections, key, title, val)
        end,
        on_submit = function(val)
            update_selection(selections, key, title, val)
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
    local input_handlers = build_input_handlers(key, title, selections)

    return Input(popup_opts, {
        default_value = default or "",
        on_change = input_handlers.on_change,
        on_submit = input_handlers.on_submit,
    })
end

----------------------------------------------------------------------------
--
-- Registers foucs for provided component
--
-- @param component  component any component
--
----------------------------------------------------------------------------
local function register_focus_for_components(component)
    focus_manager.register_component(component)
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
    local input_component = create_input_component(title, key, default, selections)
    register_focus_for_components(input_component)
    return Layout.Box(input_component, { size = 3 })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
