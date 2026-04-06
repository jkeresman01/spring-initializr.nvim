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
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Manages creation and cleanup of UI-related autocmds.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local events = require("spring-initializr.events.events")
local log = require("spring-initializr.trace.log")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        resize_autocmd_id = nil,
    },
}

----------------------------------------------------------------------------
--
-- Set up a VimResized autocmd and return its id.
--
-- @param callback  function  Resize callback
-- @return number            Autocmd id
--
----------------------------------------------------------------------------
function M.setup_resize_autocmd(callback)
    M.remove_resize_autocmd()
    M.state.resize_autocmd_id = vim.api.nvim_create_autocmd(events.VIM_RESIZED, {
        callback = callback,
    })
    log.trace("Resize autocmd installed")
    return M.state.resize_autocmd_id
end

----------------------------------------------------------------------------
--
-- Remove the active resize autocmd if present.
--
----------------------------------------------------------------------------
function M.remove_resize_autocmd()
    if M.state.resize_autocmd_id then
        pcall(vim.api.nvim_del_autocmd, M.state.resize_autocmd_id)
        M.state.resize_autocmd_id = nil
        log.trace("Resize autocmd removed")
    end
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
