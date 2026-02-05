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
-- Health checker: Neovim version >= 0.10.0
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local REQUIRED_NVIM_VERSION = { major = 0, minor = 10, patch = 0 }

----------------------------------------------------------------------------
--
-- Creates a Neovim version checker.
--
-- @return table  Handler with label and check function
--
----------------------------------------------------------------------------
function M.new()
    return {
        label = "Neovim version",
        check = function()
            local v = vim.version()
            local version_str = string.format("%d.%d.%d", v.major, v.minor, v.patch)

            local req = REQUIRED_NVIM_VERSION
            if v.major > req.major then
                return true, version_str
            elseif v.major == req.major then
                if v.minor > req.minor then
                    return true, version_str
                elseif v.minor == req.minor and v.patch >= req.patch then
                    return true, version_str
                end
            end

            return false, version_str .. " (upgrade to 0.10.0+)"
        end,
    }
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
