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
local msg = require("spring-initializr.utils.message")

local M = {
    state = {
        dependencies_panel = nil,
    },
}

function M.create_button(update_display_fn)
    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = "Add Dependencies (Telescope)", top_align = "center" },
        },
        size = { height = 3, width = 40 },
        enter = true,
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
    })

    popup:map("n", "<CR>", function()
        vim.defer_fn(function()
            telescope_dep.pick_dependencies()
            vim.defer_fn(update_display_fn, 200)
        end, 100)
    end, { noremap = true, nowait = true })

    focus.register(popup)
    return Layout.Box(popup, { size = 3 })
end

function M.create_display()
    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = "Selected Dependencies", top_align = "center" },
        },
        size = { width = 40, height = 10 },
        buf_options = { modifiable = true, readonly = false },
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder", wrap = true },
    })

    M.state.dependencies_panel = popup
    return popup
end

function M.update_display()
    local panel = M.state.dependencies_panel
    if not panel then
        return
    end

    local lines = { "Selected Dependencies:" }
    for i, dep in ipairs(telescope_dep.selected_dependencies or {}) do
        table.insert(lines, string.format("%d. %s", i, dep:sub(1, 38)))
    end
    vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, lines)
end

return M
