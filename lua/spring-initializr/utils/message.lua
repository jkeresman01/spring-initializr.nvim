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
-- Provides standardized message logging using vim.notify.
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
--
----------------------------------------------------------------------------

local M = {}
local notify = vim.notify

-----------------------------------------------------------------------------
--
-- Logs an info-level message.
--
-- @param msg string Message to display
--
-----------------------------------------------------------------------------
M.info = function(msg)
    notify(msg, vim.log.levels.INFO)
end

-----------------------------------------------------------------------------
--
-- Logs a warning-level message.
--
-- @param msg string Message to display
--
-----------------------------------------------------------------------------
M.warn = function(msg)
    notify(msg, vim.log.levels.WARN)
end

-----------------------------------------------------------------------------
--
-- Logs an error-level message.
--
-- @param msg string Message to display
--
-----------------------------------------------------------------------------
M.error = function(msg)
    notify(msg, vim.log.levels.ERROR)
end

-----------------------------------------------------------------------------
--
-- Logs a debug-level message.
--
-- @param msg string Message to display
--
-----------------------------------------------------------------------------
M.debug = function(msg)
    notify(msg, vim.log.levels.DEBUG)
end

return M
