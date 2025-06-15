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

local function format_dependency_items(metadata)
    local items = {}
    for _, group in ipairs(metadata.dependencies.values or {}) do
        for _, dep in ipairs(group.values or {}) do
            table.insert(items, {
                label = string.format("[%s] %s", group.name, dep.name),
                id = dep.id,
            })
        end
    end
    return items
end

local function make_entry(entry)
    return {
        value = entry,
        display = entry.label,
        ordinal = entry.label,
    }
end

local function on_select_dependency(prompt_bufnr, on_done)
    local selection = action_state.get_selected_entry()
    table.insert(M.selected_dependencies, selection.value.id)
    msg.info("Selected Dependency: " .. selection.value.id)
    actions.close(prompt_bufnr)

    if on_done then
        on_done()
    end
end

local function show_dependency_picker(items, opts, on_done)
    pickers
        .new(opts, {
            prompt_title = "Spring Dependencies",
            finder = finders.new_table({
                results = items,
                entry_maker = make_entry,
            }),
            sorter = conf.generic_sorter(opts),
            layout_strategy = "vertical",
            layout_config = {
                prompt_position = "top",
                width = 0.5,
                height = 0.6,
            },
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    on_select_dependency(prompt_bufnr, on_done)
                end)
                return true
            end,
        })
        :find()
end

function M.pick_dependencies(opts, on_done)
    opts = opts or {}

    metadata_loader.fetch_metadata(function(data, err)
        if err then
            msg.error("Failed to load Spring metadata: " .. err)
            return
        end

        local items = format_dependency_items(data)
        show_dependency_picker(items, opts, on_done)
    end)
end

return M
