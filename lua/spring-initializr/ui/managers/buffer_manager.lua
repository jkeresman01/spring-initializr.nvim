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
-- Provides compatibility wrappers around centralized UI keymap registration.
--
----------------------------------------------------------------------------

local keymap_manager = require("spring-initializr.ui.managers.keymap_manager")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Register the close key ('q') to close UI in normal mode.
--
-- @param comp      table      Component to register
-- @param close_fn  function   Function to close the UI
--
----------------------------------------------------------------------------
function M.register_close_key(comp, close_fn)
    keymap_manager.register_close_key(comp, close_fn)
end

----------------------------------------------------------------------------
--
-- Register the reset key ('<C-r>') to reset form in normal mode.
--
-- @param comp      table      Component to register
-- @param reset_fn  function   Function to reset the form
--
----------------------------------------------------------------------------
function M.register_reset_key(comp, reset_fn)
    keymap_manager.register_reset_key(comp, reset_fn)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
