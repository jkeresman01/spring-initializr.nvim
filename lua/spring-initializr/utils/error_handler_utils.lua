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
-- Provides standardized error handling helpers for potentially unsafe
-- operations and scheduled callbacks.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Safely call a function and optionally log failures.
--
-- @param fn               function       Function to call
-- @param error_message    string|nil     Error message prefix
-- @param default_return   any|nil        Value returned on failure
-- @param ...              any            Arguments passed to fn
--
-- @return boolean                        True on success, false on failure
-- @return any                            Function result or default_return
--
----------------------------------------------------------------------------
function M.safe_call(fn, error_message, default_return, ...)
    local ok, result = pcall(fn, ...)

    if not ok then
        if error_message then
            log.error(error_message, result)
        end
        return false, default_return
    end

    return true, result
end

----------------------------------------------------------------------------
--
-- Wrap a function in vim.schedule while preserving safe error handling.
--
-- @param fn               function       Function to schedule
-- @param error_message    string|nil     Error message prefix
-- @param default_return   any|nil        Value returned from wrapped call on failure
--
-- @return function                      Wrapped scheduled callback
--
----------------------------------------------------------------------------
function M.with_schedule(fn, error_message, default_return)
    return function(...)
        local args = { ... }
        vim.schedule(function()
            M.safe_call(function()
                return fn(unpack(args))
            end, error_message, default_return)
        end)
    end
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
