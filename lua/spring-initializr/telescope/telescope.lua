--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: metadata.lua
-- Author: Josip Keresman
--
-- This module provides integration with Telescope for displaying and selecting Spring Boot dependencies

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local metadata_loader = require("spring-initializr.metadata.metadata")
local msg = require("spring-initializr.utils.message")

local M = {
    selected_dependencies = {},
}

--- Creates a single dependency entry for display in Telescope.
--
-- @param group_name string: name of the dependency group.
-- @param dep table: dependency metadata (must include `id` and `name`).
-- @return table: formatted entry for Telescope.
local function create_dependency_entry(group_name, dep)
    return {
        label = string.format("[%s] %s", group_name, dep.name),
        id = dep.id,
    }
end

--- Flattens the grouped dependencies into a single list of entries.
--
-- @param groups table: list of dependency groups.
-- @return table: flat list of dependency entries.
local function flatten_dependency_groups(groups)
    local entries = {}
    for _, group in ipairs(groups or {}) do
        for _, dep in ipairs(group.values or {}) do
            table.insert(entries, create_dependency_entry(group.name, dep))
        end
    end
    return entries
end

--- Converts a dependency entry into a Telescope-compatible format.
--
-- @param entry table: formatted dependency entry.
-- @return table: entry_maker result for Telescope.
local function make_entry(entry)
    return {
        value = entry,
        display = entry.label,
        ordinal = entry.label,
    }
end

--- Provides layout configuration for the Telescope picker.
--
-- @return table: layout config.
local function get_picker_layout()
    return {
        prompt_position = "top",
        width = 0.5,
        height = 0.6,
    }
end

--- Adds the selected dependency to the internal list and shows a message.
--
-- @param entry table: selected dependency entry.
local function record_selection(entry)
    table.insert(M.selected_dependencies, entry.id)
    msg.info("Selected Dependency: " .. entry.id)
end

--- Handles the <CR> action inside the picker.
--
-- @param prompt_bufnr number: buffer number of the picker.
-- @param on_done function|nil: optional callback to run after selection.
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

--- Creates the full Telescope picker configuration table.
--
-- @param items table: list of dependency entries.
-- @param opts table: telescope picker options.
-- @param on_done function|nil: optional callback.
-- @return table: picker configuration.
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

--- Opens the Telescope picker with given dependency entries.
--
-- @param items table: dependency entries.
-- @param opts table: picker options.
-- @param on_done function|nil: optional callback.
local function open_picker(items, opts, on_done)
    pickers.new(opts, create_picker_config(items, opts, on_done)):find()
end

--- Public function to initiate the dependency picker.
-- Fetches metadata, flattens the dependency list, and opens the picker.
--
-- @param opts table
-- @param on_done function|nil
function M.pick_dependencies(opts, on_done)
    opts = opts or {}

    metadata_loader.fetch_metadata(function(data, err)
        if err then
            msg.error("Failed to load Spring metadata: " .. err)
            return
        end

        local items = flatten_dependency_groups(data.dependencies.values)
        open_picker(items, opts, on_done)
    end)
end

return M
