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
local message_utils = require("spring-initializr.utils.message_utils")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

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
-- Format a single item line for display with a selection marker.
--
-- @param  item         table    Radio item
-- @param  is_selected  boolean  Whether the item is selected
--
-- @return string                Formatted line
--
----------------------------------------------------------------------------
local function render_item_line(item, is_selected)
    local prefix = is_selected and "(x)" or "( )"
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
-- @param  items           table    List of items
-- @param  selected_index  number   Currently selected index
-- @param  title           string   Title of the radio group
-- @param  key             string   State key
-- @param  selections      table    Global selection state
--
----------------------------------------------------------------------------
local function handle_enter(items, selected_index, title, key, selections)
    selections[key] = items[selected_index].value
    message_utils.show_info_message(string.format("%s: %s", title, items[selected_index].label))
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
        handle_enter(state.items, state.selected[1], state.title, state.key, state.selections)
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
    return {
        style = "rounded",
        text = { top = title, top_align = "center" },
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
-- Create a radio component as a layout box.
--
-- @param  title       string  Label/title of the radio group
-- @param  values      table   Available radio options
-- @param  key         string  Key to store the selection in state
-- @param  selections  table   Global selection state
--
-- @return Layout.Box          Layout-wrapped popup
--
----------------------------------------------------------------------------
function M.create_radio(title, values, key, selections)
    local items = build_items(values)
    local selected = { 1 }

    selections[key] = items[selected[1]].value

    local popup = create_radio_popup(title, #items)
    local state = {
        title = title,
        items = items,
        key = key,
        selections = selections,
        selected = selected,
    }

    map_keys(popup, state)
    schedule_initial_render(popup, items, selected[1])
    register_focus_for_components(popup)

    return Layout.Box(popup, { size = #items + 2 })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
