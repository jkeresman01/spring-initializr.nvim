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
local reset_manager = require("spring-initializr.ui.managers.reset_manager")
local highlights = require("spring-initializr.styles.highlights")
local metadata = require("spring-initializr.metadata.metadata")
local dependencies_display =
    require("spring-initializr.ui.components.dependencies.dependencies_display")
local window_utils = require("spring-initializr.utils.window_utils")
local message_utils = require("spring-initializr.utils.message_utils")
local buffer_utils = require("spring-initializr.utils.buffer_utils")
local repository_factory = require("spring-initializr.dao.dal.repository_factory")
local Project = require("spring-initializr.dao.model.project")
local HashSet = require("spring-initializr.algo.hashset")
local Dependency = require("spring-initializr.dao.model.dependency")
local log = require("spring-initializr.trace.log")
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
        resize_autocmd_id = nil,
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
    local ui = layout_builder.build_ui(data, M.state.selections, M.close)
    M.state.layout = ui.layout
    M.state.outer_popup = ui.outer_popup
end

----------------------------------------------------------------------------
--
-- Loads saved state and restores to UI.
--
----------------------------------------------------------------------------
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

    local ok, project = pcall(function()
        return repo.load_project()
    end)

    if not ok or not project then
        return
    end

    M.state.selections.project_type = project.project_type or ""
    M.state.selections.language = project.language or ""
    M.state.selections.boot_version = project.boot_version or ""
    M.state.selections.groupId = project.groupId or "com.example"
    M.state.selections.artifactId = project.artifactId or "demo"
    M.state.selections.name = project.name or "demo"
    M.state.selections.description = project.description or "Demo project for Spring Boot"
    M.state.selections.packageName = project.packageName or "com.example.demo"
    M.state.selections.packaging = project.packaging or ""
    M.state.selections.java_version = project.java_version or ""
    M.state.selections.configurationFileFormat = project.configurationFileFormat or "properties"

    telescope.selected_dependencies = {}
    telescope.selected_dependencies_full = {}

    if not telescope.selected_set then
        telescope.selected_set = HashSet.new()
    else
        telescope.selected_set:clear()
    end

    if project.dependencies then
        for _, dep in ipairs(project.dependencies) do
            if type(dep) == "table" and dep.id then
                table.insert(telescope.selected_dependencies, dep.id)
                table.insert(telescope.selected_dependencies_full, {
                    id = dep.id,
                    name = dep.name or dep.id,
                    description = dep.description or "",
                })
                -- Add to HashSet
                telescope.selected_set:add(dep.id)
            elseif type(dep) == "string" then
                table.insert(telescope.selected_dependencies, dep)
                table.insert(telescope.selected_dependencies_full, {
                    id = dep,
                    name = dep,
                    description = "",
                })
                -- Add to HashSet
                telescope.selected_set:add(dep)
            end
        end
    end

    message_utils.show_info_message("Loaded previous project configuration")
end

----------------------------------------------------------------------------
--
-- Removes the resize autocmd.
--
----------------------------------------------------------------------------
local function remove_resize_autocmd()
    if M.state.resize_autocmd_id then
        log.trace("Removing resize autocmd")
        vim.api.nvim_del_autocmd(M.state.resize_autocmd_id)
        M.state.resize_autocmd_id = nil
    end
end

----------------------------------------------------------------------------
--
-- Closes UI without saving state (used internally for resize).
--
----------------------------------------------------------------------------
local function close_for_resize()
    log.trace("Closing UI for resize")

    remove_resize_autocmd()

    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end

    -- Explicitly unmount the outer popup (Layout doesn't do this automatically)
    if M.state.outer_popup then
        pcall(function()
            M.state.outer_popup:unmount()
        end)
        M.state.outer_popup = nil
    end

    M.state.is_open = false

    focus_manager.reset()
    reset_manager.clear_handlers()
end

----------------------------------------------------------------------------
--
-- Reopens the UI with existing metadata (used for resize).
--
-- @param  data  table  Metadata to use
--
----------------------------------------------------------------------------
local function reopen_after_resize(data)
    if M.state.is_open then
        return
    end

    log.trace("Reopening UI after resize")
    store_metadata(data)
    setup_layout(data)

    log.trace("Mounting layout")
    M.state.layout:mount()
    M.state.is_open = true

    focus_manager.enable_navigation(M.close, M.state.selections)
    dependencies_display.update_display()
    buffer_utils.setup_close_on_buffer_delete(
        focus_manager.focusables,
        M.state.outer_popup,
        M.close
    )
    focus_manager.focus_first()

    -- Re-setup resize autocmd
    M.state.resize_autocmd_id = vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if M.state.is_open and M.state.metadata then
                local saved_metadata = M.state.metadata
                local saved_selections = vim.deepcopy(M.state.selections)

                close_for_resize()

                vim.defer_fn(function()
                    M.state.selections = saved_selections
                    reopen_after_resize(saved_metadata)
                end, 50)
            end
        end,
        desc = "Spring Initializr resize handler",
    })

    log.info("UI reopened after resize")
end

----------------------------------------------------------------------------
--
-- Sets up autocmd for VimResized event to handle terminal resize.
--
----------------------------------------------------------------------------
local function setup_resize_autocmd()
    log.trace("Setting up resize autocmd")
    M.state.resize_autocmd_id = vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
            if M.state.is_open and M.state.metadata then
                local saved_metadata = M.state.metadata
                local saved_selections = vim.deepcopy(M.state.selections)

                close_for_resize()

                vim.defer_fn(function()
                    M.state.selections = saved_selections
                    reopen_after_resize(saved_metadata)
                end, 50)
            end
        end,
        desc = "Spring Initializr resize handler",
    })
    log.debug("Resize autocmd created")
end

----------------------------------------------------------------------------
--
-- Mounts the layout, sets focus_manager behavior and updates dependency display.
--
----------------------------------------------------------------------------
local function activate_ui()
    log.info("Activating UI")
    log.trace("Mounting layout")
    M.state.layout:mount()
    M.state.is_open = true
    log.debug("Enabling navigation")
    focus_manager.enable_navigation(M.close, M.state.selections)
    log.trace("Updating dependencies display")
    dependencies_display.update_display()
    log.debug("Setting up close-on-buffer-delete")
    buffer_utils.setup_close_on_buffer_delete(
        focus_manager.focusables,
        M.state.outer_popup,
        M.close
    )
    log.trace("Focusing first component")
    focus_manager.focus_first()
    log.trace("Setting up resize handler")
    setup_resize_autocmd()
    log.info("UI activated successfully")
end

----------------------------------------------------------------------------
--
-- Handles layout setup using fetched metadata.
--
-- @param  data  table  Metadata used to drive UI creation
--
----------------------------------------------------------------------------
local function mount_ui(data)
    store_metadata(data)
    restore_saved_state()
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
    log.debug("UI setup called")

    if M.state.is_open then
        log.warn("Spring Initializr is already open")
        message_utils.show_warn_message("Spring Initializr is already open")
        return
    end

    log.info("Setting up Spring Initializr UI")
    setup_highlights()

    metadata.fetch_metadata(function(data, err)
        if err or not data then
            log.error("Metadata fetch failed:", err)
            handle_metadata_error(err)
            return
        end

        log.info("Metadata received, mounting UI")
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
    log.info("Closing Spring Initializr UI")

    remove_resize_autocmd()

    if M.state.is_open then
        log.debug("Saving project state before close")
        local dependencies = {}
        for _, dep in ipairs(telescope.selected_dependencies_full or {}) do
            table.insert(dependencies, Dependency.new(dep.id, dep.name, dep.description))
        end

        local project = Project.new(M.state.selections, dependencies)
        local repo = repository_factory.get_instance()
        local ok, err = pcall(function()
            repo.save_project(project)
        end)

        if ok then
            log.info("Project state saved successfully")
        else
            log.error("Failed to save project state:", err)
        end
    end

    log.trace("Unmounting layout")
    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end

    -- Explicitly unmount the outer popup
    if M.state.outer_popup then
        pcall(function()
            M.state.outer_popup:unmount()
        end)
        M.state.outer_popup = nil
    end

    log.trace("Closing windows")
    window_utils.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
    M.state.is_open = false

    log.debug("Resetting focus manager")
    focus_manager.reset()
    log.debug("Clearing reset handlers")
    reset_manager.clear_handlers()
    log.info("UI closed successfully")
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
