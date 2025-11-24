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
-- Manages the UI elements related to Spring Initializr dependency selection.
-- Uses card-based view to display selected dependencies with full metadata.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Popup = require("nui.popup")

local buffer_manager = require("spring-initializr.ui.managers.buffer_manager")
local focus_manager = require("spring-initializr.ui.managers.focus_manager")
local message_utils = require("spring-initializr.utils.message_utils")
local picker = require("spring-initializr.telescope.telescope")
local dependency_card = require("spring-initializr.ui.components.dependencies.dependency_card")

----------------------------------------------------------------------------
-- Module
----------------------------------------------------------------------------
local M = {
    state = { dependencies_panel = nil },
}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local BUTTON_SIZE = { height = 3, width = 40 }
local DISPLAY_SIZE = { height = "100%", width = 40 }
local BUTTON_TITLE = "Add Dependencies (Telescope)"
local DISPLAY_TITLE = "Selected Dependencies"

----------------------------------------------------------------------------
--
-- Returns the border configuration for the "Add Dependencies" button.
--
-- @return table  Border configuration table
--
----------------------------------------------------------------------------
local function button_border()
    return { style = "rounded", text = { top = BUTTON_TITLE, top_align = "center" } }
end

----------------------------------------------------------------------------
--
-- Returns the window options for the "Add Dependencies" button.
--
-- @return table  Window options
--
----------------------------------------------------------------------------
local function button_win_options()
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" }
end

----------------------------------------------------------------------------
--
-- Returns the buffer options for the "Add Dependencies" button.
-- Makes the button readonly to prevent text editing.
--
-- @return table  Buffer options
--
----------------------------------------------------------------------------
local function button_buffer_options()
    return {
        modifiable = false,
        readonly = true,
    }
end

----------------------------------------------------------------------------
--
-- Builds the configuration table for the dependencies button popup.
--
-- @return table  Popup configuration
--
----------------------------------------------------------------------------
local function button_popup_config()
    return {
        border = button_border(),
        size = BUTTON_SIZE,
        enter = true,
        buf_options = button_buffer_options(),
        win_options = button_win_options(),
    }
end

----------------------------------------------------------------------------
--
-- Open the Telescope picker with a callback to refresh the display.
--
-- @param on_update  function  Callback to refresh the dependencies list
--
----------------------------------------------------------------------------
local function open_picker_and_refresh(on_update)
    picker.pick_dependencies({}, on_update)
end

----------------------------------------------------------------------------
--
-- Bind the <CR> key on the button popup to open the picker and refresh.
--
-- @param popup      Popup     NUI popup instance for the button
-- @param on_update  function  Callback to refresh the dependencies list
--
----------------------------------------------------------------------------
local function bind_button_action(popup, on_update)
    popup:map("n", "<CR>", function()
        open_picker_and_refresh(on_update)
    end, { noremap = true, nowait = true })
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
-- Create a popup button that triggers dependency selection.
--
-- @param update_display_fn  function  Callback to update the dependency display
--
-- @return Layout.Box  The button wrapped in a Layout.Box
--
----------------------------------------------------------------------------
function M.create_button(update_display_fn)
    local popup = Popup(button_popup_config())
    bind_button_action(popup, update_display_fn)
    register_focus_for_components(popup)
    return popup
end

----------------------------------------------------------------------------
--
-- Returns the border configuration for the dependencies display panel.
--
-- @return table  Border configuration table
--
----------------------------------------------------------------------------
local function display_border()
    return { style = "rounded", text = { top = DISPLAY_TITLE, top_align = "center" } }
end

----------------------------------------------------------------------------
--
-- Returns the window options for the dependencies display panel.
--
-- @return table  Window options
--
----------------------------------------------------------------------------
local function display_win_options()
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", wrap = false }
end

----------------------------------------------------------------------------
--
-- Returns the buffer options for the dependencies display panel.
--
-- @return table  Buffer options
--
----------------------------------------------------------------------------
local function display_buffer_options()
    return { modifiable = true, readonly = false }
end

----------------------------------------------------------------------------
--
-- Builds the configuration table for the dependencies display popup.
--
-- @return table  Popup configuration
--
----------------------------------------------------------------------------
local function display_popup_config()
    return {
        border = display_border(),
        size = DISPLAY_SIZE,
        buf_options = display_buffer_options(),
        win_options = display_win_options(),
    }
end

----------------------------------------------------------------------------
--
-- Create a popup to display selected dependencies.
--
-- @param close_fn  table  Module closing function from layout.lua
--
-- @return Popup           Nui popup used for showing dependencies
--
----------------------------------------------------------------------------
function M.create_display(close_fn)
    local popup = Popup(display_popup_config())
    M.state.dependencies_panel = popup
    buffer_manager.register_close_key(popup, close_fn)
    return popup
end

----------------------------------------------------------------------------
--
-- Get the actual display width of the panel window.
--
-- @return number  Width of the panel in characters
--
----------------------------------------------------------------------------
local function get_panel_width()
    local panel = M.state.dependencies_panel

    if not panel or not panel.winid or not vim.api.nvim_win_is_valid(panel.winid) then
        return 40
    end

    return vim.api.nvim_win_get_width(panel.winid)
end

----------------------------------------------------------------------------
--
-- Produce the lines to render for the selected dependencies list.
-- Uses card-based view to display dependencies with full metadata.
--
-- @return table  List of strings for buffer rendering
--
----------------------------------------------------------------------------
local function render_dependency_lines()
    if not picker.selected_dependencies_full or #picker.selected_dependencies_full == 0 then
        return { "No dependencies selected" }
    end

    local panel_width = get_panel_width()
    return dependency_card.create_all_cards(picker.selected_dependencies_full, panel_width)
end

----------------------------------------------------------------------------
--
-- Update the dependencies display buffer with current selections.
--
----------------------------------------------------------------------------
function M.update_display()
    local panel = M.state.dependencies_panel

    if not panel or not vim.api.nvim_buf_is_valid(panel.bufnr) then
        message_utils.show_error_message("Failed to update dependencies display buffer")
        return
    end

    local lines = render_dependency_lines()
    vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, lines)

    if picker.selected_dependencies_full and #picker.selected_dependencies_full > 0 then
        local panel_width = get_panel_width()
        dependency_card.apply_highlights(
            panel.bufnr,
            0,
            #picker.selected_dependencies_full,
            panel_width
        )
    end
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
