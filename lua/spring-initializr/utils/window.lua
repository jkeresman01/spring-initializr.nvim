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
-- Provides utility functions for working with Neovim windows.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Returns the window ID from a component.
-- Accepts either a direct window ID or a component with a `popup.winid`.
--
-- @param  comp        table       Component object with `winid` or `popup.winid`
-- @return number|nil              Window ID, or nil if not found
--
----------------------------------------------------------------------------
function M.get_winid(comp)
    return comp.winid or (comp.popup and comp.popup.winid)
end

----------------------------------------------------------------------------
--
-- Safely closes a Neovim window if it is valid.
-- Uses `pcall` to protect against errors from already closed/invalid windows.
--
-- @param  winid       number      Window ID to close
--
----------------------------------------------------------------------------
function M.safe_close(winid)
    if winid and vim.api.nvim_win_is_valid(winid) then
        pcall(vim.api.nvim_win_close, winid, true)
    end
end

return M
