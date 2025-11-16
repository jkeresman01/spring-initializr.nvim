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
local layout_builder = require("spring-initializr.ui.layout.layout")
local focus_manager = require("spring-initializr.ui.managers.focus_manager")
local highlights = require("spring-initializr.styles.highlights")
local metadata = require("spring-initializr.metadata.metadata")
local dependencies_display = require("spring-initializr.ui.components.dependecies_display")
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
-- Mounts the layout, sets focus_manager behavior and updates dependency display.
--
----------------------------------------------------------------------------
local function activate_ui()
    M.state.layout:mount()
    focus_manager.enable_navigation()
    dependencies_display.update_display()
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
-- Cleans up all active layout and popup UI components.
-- Resets internal state and focus_manager tracking.
--
----------------------------------------------------------------------------
function M.close()
    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end

    window_utils.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
    M.state.outer_popup = nil

    focus_manager.reset()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
