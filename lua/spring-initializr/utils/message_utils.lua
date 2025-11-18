---------------------------------------------------------------------------
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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Provides standardized message logging using vim.notify.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Locales
----------------------------------------------------------------------------
local notify = vim.notify

----------------------------------------------------------------------------
--
-- Logs an info-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.show_info_message(msg)
    vim.schedule(function()
        notify(msg, vim.log.levels.INFO)
    end)
end

----------------------------------------------------------------------------
--
-- Logs a warning-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.show_warn_message(msg)
    vim.schedule(function()
        notify(msg, vim.log.levels.WARN)
    end)
end

----------------------------------------------------------------------------
--
-- Logs an error-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.show_error_message(msg)
    vim.schedule(function()
        notify(msg, vim.log.levels.ERROR)
    end)
end

----------------------------------------------------------------------------
--
-- Logs a debug-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.show_debug_message(msg)
    vim.schedule(function()
        notify(msg, vim.log.levels.DEBUG)
    end)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
