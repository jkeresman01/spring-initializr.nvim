--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/focus.lua
-- Author: Josip Keresman

local win = require("spring-initializr.utils.window")

local M = {
    focusables = {},
    current_focus = 1,
}

function M.register(comp)
    table.insert(M.focusables, comp)
end

function M.enable()
    for _, comp in ipairs(M.focusables) do
        comp:map("n", "<Tab>", function()
            M.current_focus = (M.current_focus % #M.focusables) + 1
            vim.api.nvim_set_current_win(win.get_winid(M.focusables[M.current_focus]))
        end, { noremap = true, nowait = true })

        comp:map("n", "<S-Tab>", function()
            M.current_focus = (M.current_focus - 2 + #M.focusables) % #M.focusables + 1
            vim.api.nvim_set_current_win(win.get_winid(M.focusables[M.current_focus]))
        end, { noremap = true, nowait = true })
    end
end

function M.reset()
    M.focusables = {}
    M.current_focus = 1
end

return M
