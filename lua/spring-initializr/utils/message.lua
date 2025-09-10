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

local M = {}

local notify = vim.notify

----------------------------------------------------------------------------
--
-- Logs an info-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.info(msg)
    notify(msg, vim.log.levels.INFO)
end

----------------------------------------------------------------------------
--
-- Logs a warning-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.warn(msg)
    notify(msg, vim.log.levels.WARN)
end

----------------------------------------------------------------------------
--
-- Logs an error-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.error(msg)
    notify(msg, vim.log.levels.ERROR)
end

----------------------------------------------------------------------------
--
-- Logs a debug-level message.
--
-- @param  msg  string  Message to display
--
----------------------------------------------------------------------------
function M.debug(msg)
    notify(msg, vim.log.levels.DEBUG)
end

return M
