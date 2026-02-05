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
-- Health checker: start.spring.io reachability.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local SPRING_INITIALIZR_URL = "https://start.spring.io"
local NETWORK_TIMEOUT = 5000 -- 5 seconds

----------------------------------------------------------------------------
--
-- Creates a network reachability checker.
--
-- @return table  Handler with label and check function
--
----------------------------------------------------------------------------
function M.new()
    return {
        label = "start.spring.io",
        check = function()
            local curl_ok, curl = pcall(require, "plenary.curl")
            if not curl_ok then
                return false, "cannot check (plenary.curl not available)"
            end

            local ok, response = pcall(curl.get, SPRING_INITIALIZR_URL, {
                timeout = NETWORK_TIMEOUT,
            })

            if not ok then
                return false, "unreachable (check internet connection / firewall)"
            end

            if response and response.status and response.status >= 200 and response.status < 400 then
                return true, "reachable"
            end

            local status_info = ""
            if response and response.status then
                status_info = string.format(" (HTTP %d)", response.status)
            end

            return false, "unreachable" .. status_info .. " (check internet connection / firewall)"
        end,
    }
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
