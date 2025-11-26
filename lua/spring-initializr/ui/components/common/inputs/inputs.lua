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
local reset_manager = require("spring-initializr.ui.managers.reset_manager")
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
-- @param  config   table/InputConfig  Containing configuration object with
-- title, key, default value, and shared selections
-- @param value       any                New value to store and display
--
----------------------------------------------------------------------------
local function update_selection(config, value)
    config.selections[config.key] = value
end

----------------------------------------------------------------------------
--
-- Displays a selected value.
--
-- @param value       any                selection
--
----------------------------------------------------------------------------
local function show_selection(config, value)
    message_utils.show_info_message(config.title .. ": " .. value)
end

----------------------------------------------------------------------------
--
-- Creates input change and submit handlers that update user selections.
--
-- @param  config   table/InputConfig  Containing configuration object with
-- title, key, default value, and shared selections
--
----------------------------------------------------------------------------
local function build_input_handlers(config)
    return {
        on_change = function(value)
            update_selection(config, value)
        end,
        on_submit = function(value)
            update_selection(config, value)
            show_selection(config, value)
        end,
    }
end

----------------------------------------------------------------------------
--
-- Creates and returns an Input popup component.
--
-- @param  config   table/InputConfig  Containing configuration object with
-- title, key, default value, and shared selections
--
-- @return Input                       Input popup component
--
----------------------------------------------------------------------------
local function create_input_component(config)
    local popup_opts = build_input_popup_opts(config.title)
    local input_handlers = build_input_handlers(config)

    return Input(popup_opts, {
        default_value = config.default,
        on_change = input_handlers.on_change,
        on_submit = input_handlers.on_submit,
    })
end

----------------------------------------------------------------------------
--
-- Registers focus for provided component
--
-- @param component  component any component
--
----------------------------------------------------------------------------
local function register_focus_for_components(component)
    focus_manager.register_component(component)
end

----------------------------------------------------------------------------
--
-- Create a reset handler for this input component.
--
-- @param  input_component  Input        Input component instance
-- @param  config           InputConfig  Configuration object
--
-- @return function                      Reset handler
--
----------------------------------------------------------------------------
local function create_reset_handler(input_component, config)
    return function()
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(input_component.bufnr) then
                return
            end
            config.selections[config.key] = config.default
            vim.api.nvim_buf_set_lines(input_component.bufnr, 0, -1, false, { config.default })
        end)
    end
end

----------------------------------------------------------------------------
--
-- Create a layout-wrapped input component for Spring Initializr.
--
-- @param  config   table/InputConfig  Containing configuration object with
-- title, key, default value, and shared selections
--
-- @return Layout.Box                  Layout-wrapped input component
--
----------------------------------------------------------------------------
function M.create_input(config)
    config.selections[config.key] = config.default
    local input_component = create_input_component(config)
    register_focus_for_components(input_component)

    local reset_handler = create_reset_handler(input_component, config)
    reset_manager.register_reset_handler(reset_handler)

    return Layout.Box(input_component, { size = 3 })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
