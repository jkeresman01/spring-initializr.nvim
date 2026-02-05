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
-- Health checker: configuration validity.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local plugin_config = require("spring-initializr.config.config")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local VALID_CONFIG_FORMATS = { properties = true, yaml = true }

----------------------------------------------------------------------------
--
-- Creates a configuration validity checker.
--
-- @return table  Handler with label and check function
--
----------------------------------------------------------------------------
function M.new()
    return {
        label = "Configuration",
        check = function()
            local issues = {}

            local fmt = plugin_config.get_config_format()
            if not VALID_CONFIG_FORMATS[fmt] then
                table.insert(
                    issues,
                    'config_format "' .. tostring(fmt) .. '" is not "properties" or "yaml"'
                )
            end

            local nerd = plugin_config.get_use_nerd_fonts()
            if type(nerd) ~= "boolean" then
                table.insert(issues, "use_nerd_fonts is " .. type(nerd) .. ", expected boolean")
            end

            if #issues == 0 then
                return true, "valid"
            end

            return false, table.concat(issues, "; ")
        end,
    }
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
