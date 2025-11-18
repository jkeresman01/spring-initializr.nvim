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

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    focusables = {},
    current_focus = 1,
    close_callback = nil,
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
-- Set the callback function to be called when quit is triggered.
--
-- @param callback  function  Function to call on quit
--
----------------------------------------------------------------------------
function M.set_close_callback(callback)
    M.close_callback = callback
end

----------------------------------------------------------------------------
--
-- Focus the next component in the focusables list.
--
----------------------------------------------------------------------------
local function focus_next()
    M.current_focus = (M.current_focus % #M.focusables) + 1
    vim.api.nvim_set_current_win(window_utils.get_winid(M.focusables[M.current_focus]))
end

----------------------------------------------------------------------------
--
-- Focus the previous component in the focusables list.
--
----------------------------------------------------------------------------
local function focus_prev()
    M.current_focus = (M.current_focus - 2 + #M.focusables) % #M.focusables + 1
    vim.api.nvim_set_current_win(window_utils.get_winid(M.focusables[M.current_focus]))
end

----------------------------------------------------------------------------
--
-- Handle quit action - closes the entire UI.
--
----------------------------------------------------------------------------
local function handle_quit()
    if M.close_callback then
        M.close_callback()
    end
end

----------------------------------------------------------------------------
--
-- Map navigation and quit keys to a component.
--
-- @param comp  table  Component to map keys for
--
----------------------------------------------------------------------------
local function map_component_keys(comp)
    comp:map("n", "<Tab>", focus_next, { noremap = true, nowait = true })
    comp:map("n", "<S-Tab>", focus_prev, { noremap = true, nowait = true })
    comp:map("n", "q", handle_quit, { noremap = true, nowait = true })
end

----------------------------------------------------------------------------
--
-- Enable focus navigation across all registered components.
--
----------------------------------------------------------------------------
function M.enable_navigation()
    for _, comp in ipairs(M.focusables) do
        map_component_keys(comp)
    end
end

----------------------------------------------------------------------------
--
-- Clear all focusables and reset focus index.
--
----------------------------------------------------------------------------
function M.reset()
    M.focusables = {}
    M.current_focus = 1
    M.close_callback = nil
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
