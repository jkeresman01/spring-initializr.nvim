----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- spring-initializr.nvim
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Provides centralized keybinding registration helpers for UI components.
--
----------------------------------------------------------------------------

local M = {}

local DEFAULT_OPTS = { noremap = true, nowait = true }

local function map(comp, key, handler, opts)
    comp:map("n", key, handler, opts or DEFAULT_OPTS)
end

function M.register_navigation_keys(comp, focus_next_fn, focus_prev_fn)
    map(comp, "<Tab>", focus_next_fn)
    map(comp, "<S-Tab>", focus_prev_fn)
end

function M.register_close_key(comp, close_fn)
    map(comp, "q", close_fn)
end

function M.register_reset_key(comp, reset_fn)
    map(comp, "<C-r>", reset_fn)
end

function M.register_picker_key(comp, open_picker_fn)
    map(comp, "<C-b>", open_picker_fn)
end

return M
