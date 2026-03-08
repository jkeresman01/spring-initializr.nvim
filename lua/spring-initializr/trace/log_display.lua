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
-- Handles :SpringInitializrLog command logic: opening, splitting,
-- and clearing the plugin log file.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")
local log_buffer = require("spring-initializr.ui.components.log.log_buffer")
local message_utils = require("spring-initializr.utils.message_utils")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Returns the log file path.
--
-- @return string  Full path to the log file
--
----------------------------------------------------------------------------
function M.get_log_path()
    return string.format("%s/%s.log", vim.fn.stdpath("data"), "spring-initializr")
end

----------------------------------------------------------------------------
--
-- Checks whether file logging is enabled.
--
-- @return boolean  True if file logging is enabled
--
----------------------------------------------------------------------------
function M.is_logging_enabled()
    return log.config.use_file
end

----------------------------------------------------------------------------
--
-- Checks whether the log file exists.
--
-- @param  path  string   Full path to the log file
--
-- @return boolean         True if the file exists
--
----------------------------------------------------------------------------
function M.file_exists(path)
    return vim.fn.filereadable(path) == 1
end

----------------------------------------------------------------------------
--
-- Clears the log file by truncating it.
--
-- @param  path  string  Full path to the log file
--
----------------------------------------------------------------------------
function M.clear(path)
    local file = io.open(path, "w")
    if file then
        file:close()
        message_utils.show_info_message("Spring Initializr: Log file cleared")
    else
        message_utils.show_error_message("Spring Initializr: Failed to clear log file")
    end
end

----------------------------------------------------------------------------
--
-- Entry point for :SpringInitializrLog command.
--
-- @param  args  string|nil  Optional subcommand: "split", "vsplit", "clear"
--
----------------------------------------------------------------------------
function M.run(args)
    log.info("SpringInitializrLog command invoked", args or "")

    local log_path = M.get_log_path()

    if args == "clear" then
        if not M.file_exists(log_path) then
            message_utils.show_warn_message("Spring Initializr: Log file does not exist")
            return
        end
        M.clear(log_path)
        return
    end

    if not M.is_logging_enabled() then
        message_utils.show_warn_message(
            "Spring Initializr: File logging is disabled. "
                .. "Set vim.g.spring_initializr_log_file = true to enable."
        )
        return
    end

    if not M.file_exists(log_path) then
        message_utils.show_warn_message(
            "Spring Initializr: Log file does not exist yet. "
                .. "It will be created once a log message is written."
        )
        return
    end

    local mode = "edit"
    if args == "split" or args == "vsplit" then
        mode = args
    end

    log_buffer.open(log_path, mode)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
