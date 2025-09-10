----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--
-- Provides utility functions for working with Neovim windows.
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
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

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
