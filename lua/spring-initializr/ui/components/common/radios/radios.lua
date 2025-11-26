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
-- Provides a reusable radio button UI component for selecting options
-- in a popup.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local focus_manager = require("spring-initializr.ui.managers.focus_manager")
local reset_manager = require("spring-initializr.ui.managers.reset_manager")
local message_utils = require("spring-initializr.utils.message_utils")
local icons = require("spring-initializr.ui.icons.icons")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Local state table
----------------------------------------------------------------------------

M.RadioState = {}
function M.RadioState.new(config, items, selected)
    return {
        title = config.title,
        key = config.key,
        selections = config.selections,
        items = items,
        selected = selected,
    }
end

----------------------------------------------------------------------------
--
-- Normalize a value entry into a radio item format.
--
-- @param  value  table  With `name` and `id`
--
-- @return table         Formatted with `label` and `value`
--
----------------------------------------------------------------------------
local function normalize_item(value)
    return { label = value.name, value = value.id }
end

----------------------------------------------------------------------------
--
-- Convert list of value tables into normalized radio items.
--
-- @param  values  table  List of tables with `name` and `id`
--
-- @return table         List of normalized items
--
----------------------------------------------------------------------------
local function build_items(values)
    local items = {}
    for _, value in ipairs(values or {}) do
        if type(value) == "table" then
            table.insert(items, normalize_item(value))
        end
    end
    return items
end

----------------------------------------------------------------------------
--
-- Find the index of an item by its value.
--
-- @param  items  table   List of items
-- @param  value  string  Value to find
--
-- @return number         Index (1-based) or 1 if not found
--
----------------------------------------------------------------------------
local function find_item_index(items, value)
    for i, item in ipairs(items) do
        if item.value == value then
            return i
        end
    end
    return 1
end

----------------------------------------------------------------------------
--
-- Format a single item line for display with a selection marker.
--
-- @param  item         table    Radio item
-- @param  is_selected  boolean  Whether the item is selected
--
-- @return string                Formatted line
--
----------------------------------------------------------------------------
local function render_item_line(item, is_selected)
    local prefix = is_selected and icons.get_radio_selected() or icons.get_radio_unselected()
    return string.format("%s %s", prefix, item.label)
end

----------------------------------------------------------------------------
--
-- Render all radio items to the popup buffer.
--
-- @param  popup           Popup   Nui popup instance
-- @param  items           table   List of items
-- @param  selected_index  number  Currently selected item index
--
----------------------------------------------------------------------------
local function render_all_items(popup, items, selected_index)
    local lines = {}
    for i, item in ipairs(items) do
        table.insert(lines, render_item_line(item, i == selected_index))
    end
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
end

----------------------------------------------------------------------------
--
-- Schedule the initial render of the items in the popup.
--
-- @param  popup           Popup
-- @param  items           table
-- @param  selected_index  number
--
----------------------------------------------------------------------------
local function schedule_initial_render(popup, items, selected_index)
    vim.schedule(function()
        render_all_items(popup, items, selected_index)
    end)
end

----------------------------------------------------------------------------
--
-- Handle selection confirmation with <CR>.
--
-- @param  state   RadioState   ConfigurationObject with title, key,
-- selections, items, and selected values
--
----------------------------------------------------------------------------
local function handle_enter(state)
    local selected_item = state.items[state.selected[1]]
    state.selections[state.key] = selected_item.value
    message_utils.show_info_message(string.format("%s: %s", state.title, selected_item.label))
end

----------------------------------------------------------------------------
--
-- Move down in the list.
--
-- @param  items           table   List of items
-- @param  selected_index  number  Current index
--
-- @return number                  New index
--
----------------------------------------------------------------------------
local function handle_move_down(items, selected_index)
    return math.min(selected_index + 1, #items)
end

----------------------------------------------------------------------------
--
-- Move up in the list.
--
-- @param  selected_index  number  Current index
--
-- @return number                  New index
--
----------------------------------------------------------------------------
local function handle_move_up(selected_index)
    return math.max(selected_index - 1, 1)
end

----------------------------------------------------------------------------
--
-- Map <CR> key to selection handler.
--
----------------------------------------------------------------------------
local function map_enter_key(popup, state)
    popup:map("n", "<CR>", function()
        handle_enter(state)
    end, { nowait = true, noremap = true })
end

----------------------------------------------------------------------------
--
-- Map "j" key to move down handler.
--
----------------------------------------------------------------------------
local function map_down_key(popup, state)
    popup:map("n", "j", function()
        state.selected[1] = handle_move_down(state.items, state.selected[1])
        state.selections[state.key] = state.items[state.selected[1]].value
        render_all_items(popup, state.items, state.selected[1])
    end, { nowait = true, noremap = true })
end

----------------------------------------------------------------------------
--
-- Map "k" key to move up handler.
--
----------------------------------------------------------------------------
local function map_up_key(popup, state)
    popup:map("n", "k", function()
        state.selected[1] = handle_move_up(state.selected[1])
        state.selections[state.key] = state.items[state.selected[1]].value
        render_all_items(popup, state.items, state.selected[1])
    end, { nowait = true, noremap = true })
end

----------------------------------------------------------------------------
--
-- Attach all key mappings for interaction.
--
----------------------------------------------------------------------------
local function map_keys(popup, state)
    map_enter_key(popup, state)
    map_down_key(popup, state)
    map_up_key(popup, state)
end

----------------------------------------------------------------------------
--
-- Build border config for a radio popup.
--
-- @param  title  string  Title for popup border
--
-- @return table          Border configuration
--
----------------------------------------------------------------------------
local function radio_border(title)
    local formatted_title = icons.format_section_title(title)
    return {
        style = "rounded",
        text = { top = formatted_title, top_align = "left" },
    }
end

----------------------------------------------------------------------------
--
-- Build size for a radio popup.
--
-- @param  item_count  number  Used to compute height
--
-- @return table               Size configuration
--
----------------------------------------------------------------------------
local function radio_size(item_count)
    return { width = 30, height = item_count + 2 }
end

----------------------------------------------------------------------------
--
-- Build window options for a radio popup.
--
-- @return table  Window options
--
----------------------------------------------------------------------------
local function radio_win_options()
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" }
end

----------------------------------------------------------------------------
--
-- Create the popup UI element for the radio.
--
-- @param  title       string  Title for popup border
-- @param  item_count  number  Used for height
--
-- @return Popup               Created popup
--
----------------------------------------------------------------------------
local function create_radio_popup(title, item_count)
    return Popup({
        border = radio_border(title),
        size = radio_size(item_count),
        enter = true,
        focusable = true,
        win_options = radio_win_options(),
    })
end

----------------------------------------------------------------------------
--
-- Registers focus for provided component
--
-- @param component  component any component
--
----------------------------------------------------------------------------
local function register_focus_for_components(component)
    focus_manager.register_component(component)
end

----------------------------------------------------------------------------
--
-- Create a reset handler for this radio component.
--
-- @param  popup  Popup       Popup instance
-- @param  state  RadioState  State object
--
-- @return function           Reset handler
--
----------------------------------------------------------------------------
local function create_reset_handler(popup, state)
    return function()
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(popup.bufnr) then
                return
            end
            state.selected[1] = 1
            state.selections[state.key] = state.items[1].value
            render_all_items(popup, state.items, state.selected[1])
        end)
    end
end

----------------------------------------------------------------------------
--
-- Create a radio component as a layout box.
--
-- @param  config   table/RadioConfig  Containing configuration object
-- with title, values, key, and shared selections
--
-- @return Layout.Box                  Layout-wrapped popup
--
----------------------------------------------------------------------------
function M.create_radio(config)
    local items = build_items(config.values)

    local initial_index = 1
    if config.selections[config.key] and config.selections[config.key] ~= "" then
        initial_index = find_item_index(items, config.selections[config.key])
    end

    local selected = { initial_index }

    config.selections[config.key] = items[selected[1]].value

    local popup = create_radio_popup(config.title, #items)
    local state = M.RadioState.new(config, items, selected)

    map_keys(popup, state)
    schedule_initial_render(popup, items, selected[1])
    register_focus_for_components(popup)

    local reset_handler = create_reset_handler(popup, state)
    reset_manager.register_reset_handler(reset_handler)

    return Layout.Box(popup, { size = #items + 2 })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
