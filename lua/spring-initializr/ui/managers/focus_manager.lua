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
-- Provides focus management and navigation across Spring Initializr UI
-- components.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local window_utils = require("spring-initializr.utils.window_utils")
local buffer_manager = require("spring-initializr.ui.managers.buffer_manager")
local reset_manager = require("spring-initializr.ui.managers.reset_manager")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    focusables = {},
    current_focus = 1,
    _selections = nil,
}

----------------------------------------------------------------------------
--
-- Register a focusable component.
--
-- @param comp  table  Component to register
--
----------------------------------------------------------------------------
function M.register_component(comp)
    table.insert(M.focusables, comp)
end

----------------------------------------------------------------------------
--
-- Focus a window and ensure normal mode.
--
-- @param winid  number  Window ID to focus
--
----------------------------------------------------------------------------
local function focus_window(winid)
    if not winid or not vim.api.nvim_win_is_valid(winid) then
        return
    end
    vim.api.nvim_set_current_win(winid)
    vim.cmd("stopinsert")
end

----------------------------------------------------------------------------
--
-- Focus the next component in the focusables list.
--
----------------------------------------------------------------------------
local function focus_next()
    M.current_focus = (M.current_focus % #M.focusables) + 1
    focus_window(window_utils.get_winid(M.focusables[M.current_focus]))
end

----------------------------------------------------------------------------
--
-- Focus the previous component in the focusables list.
--
----------------------------------------------------------------------------
local function focus_prev()
    M.current_focus = (M.current_focus - 2 + #M.focusables) % #M.focusables + 1
    focus_window(window_utils.get_winid(M.focusables[M.current_focus]))
end

----------------------------------------------------------------------------
--
-- Map navigation keys to a component.
--
-- @param comp  table  Component to map keys for
--
----------------------------------------------------------------------------
local function map_navigation_keys(comp)
    comp:map("n", "<Tab>", focus_next, { noremap = true, nowait = true })
    comp:map("n", "<S-Tab>", focus_prev, { noremap = true, nowait = true })
end

----------------------------------------------------------------------------
--
-- Create reset handler that resets form and refreshes dependencies display.
--
-- @param selections  table  Selections table to reset
--
-- @return function          Reset handler
--
----------------------------------------------------------------------------
local function create_reset_handler(selections)
    return function()
        reset_manager.reset_form(selections)
        -- Lazy require to avoid circular dependency
        local dependencies_display =
            require("spring-initializr.ui.components.dependencies.dependencies_display")
        dependencies_display.update_display()
        M.focus_first()
    end
end

----------------------------------------------------------------------------
--
-- Enable focus navigation across all registered components and register
-- close and reset keys.
--
-- @param close_fn    function  Function to close UI
-- @param selections  table     Selections table for reset functionality
--
----------------------------------------------------------------------------
function M.enable_navigation(close_fn, selections)
    M._selections = selections
    local reset_fn = create_reset_handler(selections)

    for _, comp in ipairs(M.focusables) do
        map_navigation_keys(comp)
        buffer_manager.register_close_key(comp, close_fn)
        buffer_manager.register_reset_key(comp, reset_fn)
    end
end

----------------------------------------------------------------------------
--
-- Gets the window ID of the first focusable component.
--
-- @return number|nil  Window ID of first component, or nil
--
----------------------------------------------------------------------------
local function get_first_component_winid()
    if #M.focusables == 0 then
        return nil
    end
    local first_component = M.focusables[1]
    return window_utils.get_winid(first_component)
end

----------------------------------------------------------------------------
--
-- Sets focus to the first registered component in normal mode.
-- Should be called after all components are registered and mounted.
--
----------------------------------------------------------------------------
function M.focus_first()
    vim.schedule(function()
        local winid = get_first_component_winid()
        focus_window(winid)
    end)
end

----------------------------------------------------------------------------
--
-- Clear all focusables and reset focus index.
--
----------------------------------------------------------------------------
function M.reset()
    M.focusables = {}
    M.current_focus = 1
    M._selections = nil
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
