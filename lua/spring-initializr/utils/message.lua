--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: utils/message.lua
-- Author: Josip Keresman

local M = {}

local notify = vim.notify

M.info = function(msg)
    notify(msg, vim.log.levels.INFO)
end

M.warn = function(msg)
    notify(msg, vim.log.levels.WARN)
end

M.error = function(msg)
    notify(msg, vim.log.levels.ERROR)
end

M.debug = function(msg)
    notify(msg, vim.log.levels.DEBUG)
end

return M
