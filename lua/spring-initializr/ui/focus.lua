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

--- Register a focusable component.
---@param comp table
function M.register(comp)
    table.insert(M.focusables, comp)
end

--- Focus the next component in the focusables list.
local function focus_next()
    M.current_focus = (M.current_focus % #M.focusables) + 1
    vim.api.nvim_set_current_win(win.get_winid(M.focusables[M.current_focus]))
end

--- Focus the previous component in the focusables list.
local function focus_prev()
    M.current_focus = (M.current_focus - 2 + #M.focusables) % #M.focusables + 1
    vim.api.nvim_set_current_win(win.get_winid(M.focusables[M.current_focus]))
end

--- Map navigation keys to a component.
---@param comp table
local function map_navigation_keys(comp)
    comp:map("n", "<Tab>", focus_next, { noremap = true, nowait = true })
    comp:map("n", "<S-Tab>", focus_prev, { noremap = true, nowait = true })
end

--- Enable focus navigation across all registered components.
function M.enable()
    for _, comp in ipairs(M.focusables) do
        map_navigation_keys(comp)
    end
end

--- Clear all focusables and reset focus index.
function M.reset()
    M.focusables = {}
    M.current_focus = 1
end

return M
