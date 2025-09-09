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
