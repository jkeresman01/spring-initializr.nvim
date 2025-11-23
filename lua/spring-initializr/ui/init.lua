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
local dependencies_display =
    require("spring-initializr.ui.components.dependencies.dependencies_display")
local window_utils = require("spring-initializr.utils.window_utils")
local message_utils = require("spring-initializr.utils.message_utils")
local buffer_utils = require("spring-initializr.utils.buffer_utils")
local repository_factory = require("spring-initializr.dao.dal.repository_factory")
local Project = require("spring-initializr.dao.model.project")
local Dependency = require("spring-initializr.dao.model.dependency")
local telescope = require("spring-initializr.telescope.telescope")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        layout = nil,
        outer_popup = nil,
        selections = {
            dependencies = {},
            configurationFileFormat = "properties",
        },
        metadata = nil,
        is_open = false,
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
-- Loads saved state and restores to UI.
--
----------------------------------------------------------------------------
local function restore_saved_state()
    local repo = repository_factory.get_instance()

    if not repo.has_saved_project() then
        return
    end

    local project = repo.load_project()
    if not project then
        return
    end

    M.state.selections.project_type = project.project_type
    M.state.selections.language = project.language
    M.state.selections.boot_version = project.boot_version
    M.state.selections.groupId = project.groupId
    M.state.selections.artifactId = project.artifactId
    M.state.selections.name = project.name
    M.state.selections.description = project.description
    M.state.selections.packageName = project.packageName
    M.state.selections.packaging = project.packaging
    M.state.selections.java_version = project.java_version
    M.state.selections.configurationFileFormat = project.configurationFileFormat

    telescope.selected_dependencies = {}
    telescope.selected_dependencies_full = {}

    if project.dependencies then
        for _, dep in ipairs(project.dependencies) do
            table.insert(telescope.selected_dependencies, dep.id)
            table.insert(telescope.selected_dependencies_full, {
                id = dep.id,
                name = dep.name,
                description = dep.description,
            })
        end
    end

    message_utils.show_info_message("Loaded previous project configuration")
end

----------------------------------------------------------------------------
--
-- Mounts the layout, sets focus_manager behavior and updates dependency display.
--
----------------------------------------------------------------------------
local function activate_ui()
    M.state.layout:mount()
    M.state.is_open = true
    focus_manager.enable_navigation(M)
    dependencies_display.update_display()
    buffer_utils.setup_close_on_buffer_delete(
        focus_manager.focusables,
        M.state.outer_popup,
        M.close
    )
    focus_manager.focus_first()
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
    restore_saved_state(data)
    setup_layout(data)
    activate_ui()
end

----------------------------------------------------------------------------
--
-- Public setup function that initializes the full UI system.
-- Loads metadata, builds layout, and shows the form.
-- Prevents recursive opening if UI is already displayed.
--
----------------------------------------------------------------------------
function M.setup()
    if M.state.is_open then
        message_utils.show_warn_message("Spring Initializr is already open")
        return
    end

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
-- Saves state before closing.
--
----------------------------------------------------------------------------
function M.close()
    if M.state.is_open then
        local dependencies = {}
        for _, dep in ipairs(telescope.selected_dependencies_full or {}) do
            table.insert(dependencies, Dependency.new(dep.id, dep.name, dep.description))
        end

        local project = Project.new(M.state.selections, dependencies)
        local repo = repository_factory.get_instance()
        repo.save_project(project)
    end

    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end

    window_utils.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
    M.state.outer_popup = nil
    M.state.is_open = false

    focus_manager.reset()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
