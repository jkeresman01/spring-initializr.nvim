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
-- UI component for displaying the plugin log file in a buffer.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local BUFFER_NAME = "spring-initializr://log"

----------------------------------------------------------------------------
--
-- Opens the log file in a buffer with appropriate options.
--
-- @param  log_path  string  Full path to the log file
-- @param  mode      string  "edit" (current window), "split", or "vsplit"
--
----------------------------------------------------------------------------
function M.open(log_path, mode)
    if mode == "split" then
        vim.cmd("split " .. vim.fn.fnameescape(log_path))
    elseif mode == "vsplit" then
        vim.cmd("vsplit " .. vim.fn.fnameescape(log_path))
    else
        vim.cmd("edit " .. vim.fn.fnameescape(log_path))
    end

    local buf = vim.api.nvim_get_current_buf()

    vim.bo[buf].readonly = true
    vim.bo[buf].modifiable = false
    vim.bo[buf].bufhidden = "wipe"

    vim.api.nvim_buf_set_name(buf, BUFFER_NAME)

    -- Scroll to bottom (most recent logs)
    vim.cmd("normal! G")
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
