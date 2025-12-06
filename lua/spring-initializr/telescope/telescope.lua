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
-- Provides integration with Telescope for displaying and selecting
-- Spring Boot dependencies. Stores full dependency metadata.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local log = require("spring-initializr.trace.log")

local metadata_loader = require("spring-initializr.metadata.metadata")
local action_state = require("telescope.actions.state")
local message_utils = require("spring-initializr.utils.message_utils")
local HashSet = require("spring-initializr.algo.hashset")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local PICKER_TITLE = "Spring Dependencies"
local LAYOUT_STRATEGY = "vertical"

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    selected_dependencies_set = nil,
}

-------------------------------------------------------------------------------
--
-- Initialize the selected dependencies HashSet on first use.
--
-------------------------------------------------------------------------------
local function init_hashset()
    if not M.selected_dependencies_set then
        local key_fn = function(entry)
            return entry.id
        end
        M.selected_dependencies_set = HashSet.new({ key_fn = key_fn })
    end
end

-------------------------------------------------------------------------------
--
-- Formats the display label for a dependency.
--
-- @param group string   Dependency group name
-- @param dep   table    Dependency metadata
--
-- @return string        Formatted label
--
-------------------------------------------------------------------------------
local function format_label(group, dep)
    return string.format("[%s] %s", group, dep.name)
end

-------------------------------------------------------------------------------
--
-- Creates a normalized dependency entry with full metadata.
--
-- @param group string   Group name
-- @param dep   table    Dependency metadata
--
-- @return table         Flat entry table with full metadata
--
-------------------------------------------------------------------------------
local function build_entry(group, dep)
    return {
        id = dep.id,
        name = dep.name,
        description = dep.description or "No description available",
        group = group,
        label = format_label(group, dep),
    }
end

-------------------------------------------------------------------------------
--
-- Converts metadata groups into a flat list of dependency entries.
--
-- @param groups table   List of grouped dependencies
--
-- @return table         Flat list of entries
--
-------------------------------------------------------------------------------
local function flatten_entries(groups)
    local out = {}

    for _, group in ipairs(groups or {}) do
        for _, dep in ipairs(group.values or {}) do
            table.insert(out, build_entry(group.name, dep))
        end
    end

    return out
end

-------------------------------------------------------------------------------
--
-- Converts a flat entry into a Telescope-compatible entry.
--
-- @param entry table
--
-- @return table
--
-------------------------------------------------------------------------------
local function make_telescope_entry(entry)
    return {
        value = entry,
        display = entry.label,
        ordinal = entry.label,
    }
end

-------------------------------------------------------------------------------
--
-- Record user's selected dependency with full metadata.
--
-- @param entry table  Full dependency entry with id, name, description
--
-------------------------------------------------------------------------------
local function record_selection(entry)
    log.debug("Recording dependency selection:", entry.id)
    init_hashset()

    if M.selected_dependencies_set:has_key(entry.id) then
        log.warn("Dependency already selected:", entry.id)
        message_utils.show_warn_message("Already selected: " .. entry.id)
        return
    end

    log.trace("Adding dependency to set")
    M.selected_dependencies_set:add(entry)

    log.fmt_info("Dependency selected: %s (%s)", entry.name, entry.id)
    log.fmt_debug("Total dependencies selected: %d", #M.selected_dependencies_set)
    message_utils.show_info_message("Selected: " .. entry.name)
end

-----------------------------------------------------------------------------
--
-- Remove a dependency by ID.
--
-- @param dep_id string  Dependency ID to remove
-- @return boolean       true if removed, false if not found
--
-------------------------------------------------------------------------------
function M.remove_dependency(dep_id)
    log.debug("Removing dependency:", dep_id)
    init_hashset()

    log.trace("Removing from set")
    local removed = M.selected_dependencies_set:remove_key(dep_id)

    if removed then
        log.info("Dependency removed successfully:", dep_id)
        log.fmt_debug("Remaining dependencies: %d", #M.selected_dependencies_set)
        return true
    end

    return false
end

-------------------------------------------------------------------------------
--
-- Handler for <CR> inside picker.
--
-- @param bufnr   number
-- @param on_done function|nil
--
-------------------------------------------------------------------------------
local function on_select(bufnr, on_done)
    local selected = action_state.get_selected_entry()

    if selected and selected.value then
        record_selection(selected.value)
    end

    actions.close(bufnr)

    if on_done then
        vim.schedule(on_done)
    end
end

-------------------------------------------------------------------------------
--
-- Picker layout config builder.
--
-------------------------------------------------------------------------------
local function picker_layout()
    return {
        prompt_position = "top",
        width = 0.5,
        height = 0.6,
    }
end

-------------------------------------------------------------------------------
--
-- Build Telescope's finder config.
--
-- @param items table
--
-------------------------------------------------------------------------------
local function build_finder(items)
    return finders.new_table({
        results = items,
        entry_maker = make_telescope_entry,
    })
end

-------------------------------------------------------------------------------
--
-- Build attach_mappings callback.
--
-- @param on_done function|nil
--
-------------------------------------------------------------------------------
local function build_mappings(on_done)
    return function(prompt_bufnr)
        actions.select_default:replace(function()
            on_select(prompt_bufnr, on_done)
        end)
        return true
    end
end

-------------------------------------------------------------------------------
--
-- Assemble full picker config.
--
-- @param items   table
-- @param opts    table
-- @param on_done function|nil
--
-------------------------------------------------------------------------------
local function build_picker_config(items, opts, on_done)
    return {
        prompt_title = PICKER_TITLE,
        finder = build_finder(items),
        sorter = conf.generic_sorter(opts),
        layout_strategy = LAYOUT_STRATEGY,
        layout_config = picker_layout(),
        attach_mappings = build_mappings(on_done),
    }
end

-------------------------------------------------------------------------------
--
-- Open a Telescope picker.
--
-- @param items table
-- @param opts  table
-- @param done  function|nil
--
-------------------------------------------------------------------------------
local function open_picker(items, opts, done)
    pickers.new(opts, build_picker_config(items, opts, done)):find()
end

-------------------------------------------------------------------------------
--
-- Fetch metadata, flatten dependencies, and open picker.
--
-- @param opts    table
-- @param on_done function|nil
--
-------------------------------------------------------------------------------
function M.pick_dependencies(opts, on_done)
    opts = opts or {}

    metadata_loader.fetch_metadata(function(data, err)
        if err then
            message_utils.show_error_message("Failed to load Spring metadata: " .. err)
            return
        end

        local groups = data.dependencies.values
        local items = flatten_entries(groups)
        open_picker(items, opts, on_done)
    end)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
