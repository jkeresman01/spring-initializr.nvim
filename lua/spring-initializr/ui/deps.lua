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
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local focus = require("spring-initializr.ui.focus")
local picker = require("spring-initializr.telescope.telescope")

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
local DISPLAY_SIZE = { height = 10, width = 40 }
local BUTTON_TITLE = "Add Dependencies (Telescope)"
local DISPLAY_TITLE = "Selected Dependencies"
local BUTTON_LAYOUT_H = 3
local MAX_DEP_LABEL_LEN = 38

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
    focus.register(popup)
    return Layout.Box(popup, { size = BUTTON_LAYOUT_H })
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
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", wrap = true }
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
        buf_options = { modifiable = true, readonly = false },
        win_options = display_win_options(),
    }
end

----------------------------------------------------------------------------
--
-- Create a popup to display selected dependencies.
--
-- @return Popup  Nui popup used for showing dependencies
--
----------------------------------------------------------------------------
function M.create_display()
    local popup = Popup(display_popup_config())
    M.state.dependencies_panel = popup
    return popup
end

----------------------------------------------------------------------------
--
-- Produce the lines to render for the selected dependencies list.
--
-- @return table  List of strings for buffer rendering
--
----------------------------------------------------------------------------
local function render_dependency_lines()
    local lines = { "Selected Dependencies:" }
    for i, dep in ipairs(picker.selected_dependencies or {}) do
        lines[#lines + 1] = string.format("%d. %s", i, dep:sub(1, MAX_DEP_LABEL_LEN))
    end
    return lines
end

----------------------------------------------------------------------------
--
-- Update the dependencies display buffer with current selections.
--
----------------------------------------------------------------------------
function M.update_display()
    local panel = M.state.dependencies_panel
    if not panel or not vim.api.nvim_buf_is_valid(panel.bufnr) then
        return
    end
    vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, render_dependency_lines())
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
