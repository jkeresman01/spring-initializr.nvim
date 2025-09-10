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
-- Spring Boot dependencies.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local metadata_loader = require("spring-initializr.metadata.metadata")
local message_utils = require("spring-initializr.utils.message")

local M = {
    selected_dependencies = {},
}

----------------------------------------------------------------------------
--
-- Creates a single dependency entry for display in Telescope.
--
-- @param  group_name  string  Name of the dependency group
-- @param  dep         table   Dependency metadata (must include `id` and `name`)
--
-- @return table               Formatted entry for Telescope
--
----------------------------------------------------------------------------
local function create_dependency_entry(group_name, dep)
    return {
        label = string.format("[%s] %s", group_name, dep.name),
        id = dep.id,
    }
end

----------------------------------------------------------------------------
--
-- Flattens the grouped dependencies into a single list of entries.
--
-- @param  groups  table  List of dependency groups
--
-- @return table          Flat list of dependency entries
--
----------------------------------------------------------------------------
local function flatten_dependency_groups(groups)
    local entries = {}
    for _, group in ipairs(groups or {}) do
        for _, dep in ipairs(group.values or {}) do
            table.insert(entries, create_dependency_entry(group.name, dep))
        end
    end
    return entries
end

----------------------------------------------------------------------------
--
-- Converts a dependency entry into a Telescope-compatible format.
--
-- @param  entry  table   Formatted dependency entry
--
-- @return table          Entry maker result for Telescope
--
----------------------------------------------------------------------------
local function make_entry(entry)
    return {
        value = entry,
        display = entry.label,
        ordinal = entry.label,
    }
end

----------------------------------------------------------------------------
--
-- Provides layout configuration for the Telescope picker.
--
-- @return table  Layout config
--
----------------------------------------------------------------------------
local function get_picker_layout()
    return {
        prompt_position = "top",
        width = 0.5,
        height = 0.6,
    }
end

----------------------------------------------------------------------------
--
-- Adds the selected dependency to the internal list and shows a message.
--
-- @param  entry  table  Selected dependency entry
--
----------------------------------------------------------------------------
local function record_selection(entry)
    table.insert(M.selected_dependencies, entry.id)
    message_utils.info("Selected Dependency: " .. entry.id)
end

----------------------------------------------------------------------------
--
-- Handles the <CR> action inside the picker.
--
-- @param  prompt_bufnr  number         Buffer number of the picker
-- @param  on_done       function|nil   Optional callback to run after selection
--
----------------------------------------------------------------------------
local function handle_selection(prompt_bufnr, on_done)
    local selected = action_state.get_selected_entry()
    if selected and selected.value then
        record_selection(selected.value)
    end
    actions.close(prompt_bufnr)
    if on_done then
        on_done()
    end
end

----------------------------------------------------------------------------
--
-- Creates the full Telescope picker configuration table.
--
-- @param  items    table          List of dependency entries
-- @param  opts     table          Telescope picker options
-- @param  on_done  function|nil   Optional callback
--
-- @return table                   Picker configuration
--
----------------------------------------------------------------------------
local function create_picker_config(items, opts, on_done)
    return {
        prompt_title = "Spring Dependencies",
        finder = finders.new_table({
            results = items,
            entry_maker = make_entry,
        }),
        sorter = conf.generic_sorter(opts),
        layout_strategy = "vertical",
        layout_config = get_picker_layout(),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                handle_selection(prompt_bufnr, on_done)
            end)
            return true
        end,
    }
end

----------------------------------------------------------------------------
--
-- Opens the Telescope picker with given dependency entries.
--
-- @param  items    table          Dependency entries
-- @param  opts     table          Picker options
-- @param  on_done  function|nil   Optional callback
--
----------------------------------------------------------------------------
local function open_picker(items, opts, on_done)
    pickers.new(opts, create_picker_config(items, opts, on_done)):find()
end

----------------------------------------------------------------------------
--
-- Initiates the dependency picker:
-- fetch metadata, flatten dependencies, and open the picker.
--
-- @param  opts     table          Picker options
-- @param  on_done  function|nil   Optional callback
--
----------------------------------------------------------------------------
function M.pick_dependencies(opts, on_done)
    opts = opts or {}

    metadata_loader.fetch_metadata(function(data, err)
        if err then
            message_utils.error("Failed to load Spring metadata: " .. err)
            return
        end

        local items = flatten_dependency_groups(data.dependencies.values)
        open_picker(items, opts, on_done)
    end)
end

return M
