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
-- Entry point for initializing and closing the Spring Initializr UI.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local layout_builder = require("spring-initializr.ui.layout")
local focus = require("spring-initializr.ui.focus")
local highlights = require("spring-initializr.styles.highlights")
local metadata = require("spring-initializr.metadata.metadata")
local deps = require("spring-initializr.ui.deps")
local window_utils = require("spring-initializr.utils.window_utils")
local message_utils = require("spring-initializr.utils.message_utils")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        layout = nil,
        outer_popup = nil,
        selections = { dependencies = {} },
        metadata = nil,
        autocmd_id = nil,
    },
}

----------------------------------------------------------------------------
--
-- Applies highlight configuration and sets up autocmd for theme changes.
--
----------------------------------------------------------------------------
local function setup_highlights()
    highlights.configure()
end

----------------------------------------------------------------------------
--
-- Logs an error message if metadata fetch fails.
--
-- @param  err  string  Error message to show to the user
--
----------------------------------------------------------------------------
local function handle_metadata_error(err)
    message_utils.show_error_message("Failed to load metadata: " .. (err or "unknown error"))
end

----------------------------------------------------------------------------
--
-- Saves fetched metadata to module state.
--
-- @param  data  table  Metadata object
--
----------------------------------------------------------------------------
local function store_metadata(data)
    M.state.metadata = data
end

----------------------------------------------------------------------------
--
-- Builds and stores the UI layout and popup in module state.
--
-- @param  data  table  Metadata used for building the UI
--
----------------------------------------------------------------------------
local function setup_layout(data)
    local ui = layout_builder.build_ui(data, M.state.selections)
    M.state.layout = ui.layout
    M.state.outer_popup = ui.outer_popup
end

----------------------------------------------------------------------------
--
-- Checks if a closed window belongs to our UI.
--
-- @param  closed_win  number  Window ID that was closed
--
-- @return boolean             True if window belongs to this UI
--
----------------------------------------------------------------------------
local function is_ui_window(closed_win)
    if M.state.outer_popup and M.state.outer_popup.winid == closed_win then
        return true
    end

    for _, comp in ipairs(focus.focusables) do
        local winid = window_utils.get_winid(comp)
        if winid == closed_win then
            return true
        end
    end

    return false
end

----------------------------------------------------------------------------
--
-- Handles window close event.
--
-- @param  args  table  Autocmd event arguments
--
----------------------------------------------------------------------------
local function handle_window_closed(args)
    local closed_win = tonumber(args.match)
    if not closed_win then
        return
    end

    if is_ui_window(closed_win) then
        vim.schedule(function()
            M.close()
        end)
    end
end

----------------------------------------------------------------------------
--
-- Clears existing autocmd if present.
--
----------------------------------------------------------------------------
local function clear_autocmd()
    if M.state.autocmd_id then
        pcall(vim.api.nvim_del_autocmd, M.state.autocmd_id)
        M.state.autocmd_id = nil
    end
end

----------------------------------------------------------------------------
--
-- Sets up autocmd to close entire UI when any window is closed with :q
--
----------------------------------------------------------------------------
local function setup_close_autocmd()
    clear_autocmd()
    M.state.autocmd_id = vim.api.nvim_create_autocmd("WinClosed", {
        callback = handle_window_closed,
    })
end

----------------------------------------------------------------------------
--
-- Mounts the layout, sets focus behavior and updates dependency display.
--
----------------------------------------------------------------------------
local function activate_ui()
    M.state.layout:mount()
    focus.enable()
    deps.update_display()
    setup_close_autocmd()
end

----------------------------------------------------------------------------
--
-- Orchestrates layout setup using fetched metadata.
--
-- @param  data  table  Metadata used to drive UI creation
--
----------------------------------------------------------------------------
local function mount_ui(data)
    store_metadata(data)
    setup_layout(data)
    activate_ui()
end

----------------------------------------------------------------------------
--
-- Public setup function that initializes the full UI system.
-- Loads metadata, builds layout, and shows the form.
--
----------------------------------------------------------------------------
function M.setup()
    setup_highlights()

    metadata.fetch_metadata(function(data, err)
        if err or not data then
            handle_metadata_error(err)
            return
        end

        vim.schedule(function()
            mount_ui(data)
        end)
    end)
end

----------------------------------------------------------------------------
--
-- Unmounts the layout component.
--
----------------------------------------------------------------------------
local function unmount_layout()
    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end
end

----------------------------------------------------------------------------
--
-- Closes the outer popup window.
--
----------------------------------------------------------------------------
local function close_outer_popup()
    window_utils.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
    M.state.outer_popup = nil
end

----------------------------------------------------------------------------
--
-- Cleans up all active layout and popup UI components.
-- Resets internal state and focus tracking.
--
----------------------------------------------------------------------------
function M.close()
    clear_autocmd()
    unmount_layout()
    close_outer_popup()
    focus.reset()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
