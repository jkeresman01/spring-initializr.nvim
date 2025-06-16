--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/radios.lua
-- Author: Josip Keresman

local Popup = require("nui.popup")
local Layout = require("nui.layout")

local focus = require("spring-initializr.ui.focus")
local msg = require("spring-initializr.utils.message")

local M = {}

local function normalize_item(value)
    return { label = value.name, value = value.id }
end

local function build_items(values)
    local items = {}
    for _, value in ipairs(values or {}) do
        if type(value) == "table" then
            table.insert(items, normalize_item(value))
        end
    end
    return items
end

local function render_item_line(item, is_selected)
    local prefix = is_selected and "(x)" or "( )"
    return string.format("%s %s", prefix, item.label)
end

local function render_all_items(popup, items, selected_index)
    local lines = {}
    for i, item in ipairs(items) do
        table.insert(lines, render_item_line(item, i == selected_index))
    end
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
end

local function schedule_initial_render(popup, items, selected_index)
    vim.schedule(function()
        render_all_items(popup, items, selected_index)
    end)
end

local function handle_enter(items, selected_index, title, key, selections)
    selections[key] = items[selected_index].value
    msg.info(string.format("%s: %s", title, items[selected_index].label))
end

local function handle_move_down(items, selected_index)
    return math.min(selected_index + 1, #items)
end

local function handle_move_up(selected_index)
    return math.max(selected_index - 1, 1)
end

local function map_enter_key(popup, state)
    popup:map("n", "<CR>", function()
        handle_enter(state.items, state.selected[1], state.title, state.key, state.selections)
    end, { nowait = true, noremap = true })
end

local function map_down_key(popup, state)
    popup:map("n", "j", function()
        state.selected[1] = handle_move_down(state.items, state.selected[1])
        state.selections[state.key] = state.items[state.selected[1]].value
        render_all_items(popup, state.items, state.selected[1])
    end, { nowait = true, noremap = true })
end

local function map_up_key(popup, state)
    popup:map("n", "k", function()
        state.selected[1] = handle_move_up(state.selected[1])
        state.selections[state.key] = state.items[state.selected[1]].value
        render_all_items(popup, state.items, state.selected[1])
    end, { nowait = true, noremap = true })
end

local function map_keys(popup, state)
    map_enter_key(popup, state)
    map_down_key(popup, state)
    map_up_key(popup, state)
end

local function create_radio_popup(title, item_count)
    return Popup({
        border = {
            style = "rounded",
            text = { top = title, top_align = "center" },
        },
        size = { width = 30, height = item_count + 2 },
        enter = true,
        focusable = true,
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    })
end

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
    focus.register(popup)

    return Layout.Box(popup, { size = #items + 2 })
end

return M
