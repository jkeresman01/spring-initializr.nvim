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
-- Health checker factory: system executable availability.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Creates a checker for a system executable.
--
-- @param  name     string  Executable name (e.g. "curl", "unzip")
-- @param  cmd      string  Command to run for version info
-- @param  pattern  string  Lua pattern to extract version from output
--
-- @return table  Handler with label and check function
--
----------------------------------------------------------------------------
function M.new(name, cmd, pattern)
    return {
        label = name,
        check = function()
            if vim.fn.executable(name) ~= 1 then
                return false, "not found (install " .. name .. ")"
            end

            local output = vim.fn.system(cmd)
            local version = output:match(pattern)
            if version then
                return true, version
            end

            return true, "installed"
        end,
    }
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
