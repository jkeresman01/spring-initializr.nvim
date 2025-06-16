--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/deps.lua
-- Author: Josip Keresman

local Popup = require("nui.popup")
local Layout = require("nui.layout")

local focus = require("spring-initializr.ui.focus")
local telescope_dep = require("spring-initializr.telescope.telescope")

local M = {
    state = {
        dependencies_panel = nil,
    },
}

local function button_border()
    return {
        style = "rounded",
        text = { top = "Add Dependencies (Telescope)", top_align = "center" },
    }
end

local function button_popup_config()
    return {
        border = button_border(),
        size = { height = 3, width = 40 },
        enter = true,
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    }
end

local function bind_button_action(popup, on_update)
    popup:map("n", "<CR>", function()
        vim.defer_fn(function()
            telescope_dep.pick_dependencies()
            vim.defer_fn(on_update, 200)
        end, 100)
    end, { noremap = true, nowait = true })
end

function M.create_button(update_display_fn)
    local popup = Popup(button_popup_config())
    bind_button_action(popup, update_display_fn)
    focus.register(popup)
    return Layout.Box(popup, { size = 3 })
end

local function display_border()
    return {
        style = "rounded",
        text = { top = "Selected Dependencies", top_align = "center" },
    }
end

local function display_popup_config()
    return {
        border = display_border(),
        size = { width = 40, height = 10 },
        buf_options = { modifiable = true, readonly = false },
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
            wrap = true,
        },
    }
end

function M.create_display()
    local popup = Popup(display_popup_config())
    M.state.dependencies_panel = popup
    return popup
end

local function render_dependency_list()
    local lines = { "Selected Dependencies:" }
    for i, dep in ipairs(telescope_dep.selected_dependencies or {}) do
        table.insert(lines, string.format("%d. %s", i, dep:sub(1, 38)))
    end
    return lines
end

function M.update_display()
    local panel = M.state.dependencies_panel
    if not panel then
        return
    end
    vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, render_dependency_list())
end

return M
