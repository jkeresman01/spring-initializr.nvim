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

local function create_radio(title, values, key, selections)
    local items = {}
    for _, v in ipairs(values or {}) do
        if type(v) == "table" then
            table.insert(items, { label = v.name, value = v.id })
        end
    end

    local selected = 1
    selections[key] = items[selected].value

    local popup = Popup({
        border = { style = "rounded", text = { top = title, top_align = "center" } },
        size = { width = 30, height = #items + 2 },
        enter = true,
        focusable = true,
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
    })

    local function render()
        local lines = {}
        for i, item in ipairs(items) do
            local mark = (i == selected) and "(x)" or "( )"
            table.insert(lines, string.format("%s %s", mark, item.label))
        end
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
    end

    popup:map("n", "<CR>", function()
        selections[key] = items[selected].value
        msg.info(title .. ": " .. items[selected].label)
    end, { nowait = true, noremap = true })

    popup:map("n", "j", function()
        selected = math.min(selected + 1, #items)
        selections[key] = items[selected].value
        render()
    end, { nowait = true, noremap = true })

    popup:map("n", "k", function()
        selected = math.max(selected - 1, 1)
        selections[key] = items[selected].value
        render()
    end, { nowait = true, noremap = true })

    vim.schedule(render)
    focus.register(popup)
    return Layout.Box(popup, { size = #items + 2 })
end

return {
    create_radio = create_radio,
}
