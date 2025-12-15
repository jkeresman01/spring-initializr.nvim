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
-- Provides standardized message logging using vim.notify.
-- Includes error handling for nvim-notify compatibility issues.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- State
----------------------------------------------------------------------------
local notify_failed = false

----------------------------------------------------------------------------
--
-- Ensures message is a valid string.
--
-- @param  msg  any     Message to validate
-- @return string       Valid string message
--
----------------------------------------------------------------------------
local function ensure_string(msg)
    if msg == nil then
        return ""
    end

    if type(msg) == "string" then
        return msg
    end

    return tostring(msg)
end

----------------------------------------------------------------------------
--
-- Check if message is empty.
--
-- @param  msg  string  Message to check
-- @return boolean      True if message is empty
--
----------------------------------------------------------------------------
local function is_empty_message(msg)
    return msg == ""
end

----------------------------------------------------------------------------
--
-- Use echo as fallback when notify is not available.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
local function fallback_to_echo(msg)
    vim.api.nvim_echo({ { msg, "Normal" } }, false, {})
end

----------------------------------------------------------------------------
--
-- Attempt to use vim.notify and handle errors.
--
-- @param  msg    string  Message to display
-- @param  level  number  Vim log level
-- @return boolean        True if notify succeeded
--
----------------------------------------------------------------------------
local function try_notify(msg, level)
    local ok = pcall(vim.notify, msg, level, {})
    return ok
end

----------------------------------------------------------------------------
--
-- Safe wrapper around vim.notify with fallback to echo.
-- Handles nvim-notify compatibility issues gracefully.
--
-- @param  msg    string  Message to display
-- @param  level  number  Vim log level
--
----------------------------------------------------------------------------
local function safe_notify(msg, level)
    msg = ensure_string(msg)

    if is_empty_message(msg) then
        return
    end

    if notify_failed then
        fallback_to_echo(msg)
        return
    end

    if not try_notify(msg, level) then
        notify_failed = true
        fallback_to_echo(msg)
    end
end

----------------------------------------------------------------------------
--
-- Logs an info-level message.
--
-- @param  msg  string|any  Message to display
--
----------------------------------------------------------------------------
function M.show_info_message(msg)
    vim.schedule(function()
        safe_notify(msg, vim.log.levels.INFO)
    end)
end

----------------------------------------------------------------------------
--
-- Logs a warning-level message.
--
-- @param  msg  string|any  Message to display
--
----------------------------------------------------------------------------
function M.show_warn_message(msg)
    vim.schedule(function()
        safe_notify(msg, vim.log.levels.WARN)
    end)
end

----------------------------------------------------------------------------
--
-- Logs an error-level message.
--
-- @param  msg  string|any  Message to display
--
----------------------------------------------------------------------------
function M.show_error_message(msg)
    vim.schedule(function()
        safe_notify(msg, vim.log.levels.ERROR)
    end)
end

----------------------------------------------------------------------------
--
-- Logs a debug-level message.
--
-- @param  msg  string|any  Message to display
--
----------------------------------------------------------------------------
function M.show_debug_message(msg)
    vim.schedule(function()
        safe_notify(msg, vim.log.levels.DEBUG)
    end)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
