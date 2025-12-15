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
-- Logging module for spring-initializr.nvim
-- Provides configurable trace/debug/info/warn/error/fatal logging
-- to console and/or file.
--
-- Based on rxi/log.lua and tjdevries/vlog.nvim modified by Josip Keresman for
-- spring-initializr.nvim
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Configuration
----------------------------------------------------------------------------
M.config = {
    plugin = "spring-initializr",
    level = "warn",
    use_console = false,
    use_file = false,
}

----------------------------------------------------------------------------
-- Log levels
----------------------------------------------------------------------------
M.levels = {
    trace = 1,
    debug = 2,
    info = 3,
    warn = 4,
    error = 5,
    fatal = 6,
}

----------------------------------------------------------------------------
-- Level colors for console output
----------------------------------------------------------------------------
local level_colors = {
    trace = "Comment",
    debug = "Comment",
    info = "None",
    warn = "WarningMsg",
    error = "ErrorMsg",
    fatal = "ErrorMsg",
}

----------------------------------------------------------------------------
--
-- Initialize logging configuration based on global variables.
-- Checks vim global variables to configure console output, file output,
-- and log level settings.
--
----------------------------------------------------------------------------
local function init_config()
    if vim.g.spring_initializr_log_console ~= nil then
        M.config.use_console = vim.g.spring_initializr_log_console
    end

    if vim.g.spring_initializr_log_file ~= nil then
        M.config.use_file = vim.g.spring_initializr_log_file
    end

    if vim.g.spring_initializr_log_level ~= nil then
        local level = vim.g.spring_initializr_log_level
        if M.levels[level] then
            M.config.level = level
        end
    end
end

----------------------------------------------------------------------------
--
-- Get the log file path.
--
-- @return string  Full path to log file
--
----------------------------------------------------------------------------
local function get_log_path()
    local data_dir = vim.fn.stdpath("data")
    return string.format("%s/%s.log", data_dir, M.config.plugin)
end

----------------------------------------------------------------------------
--
-- Format timestamp for log entry.
--
-- @return string  Formatted timestamp (YYYY-MM-DD HH:MM:SS)
--
----------------------------------------------------------------------------
local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

----------------------------------------------------------------------------
--
-- Get debug info for caller location.
--
-- @param  level  number  Stack level to inspect (default: 3)
--
-- @return table          Debug info with source and line fields
--
----------------------------------------------------------------------------
local function get_caller_info(level)
    local info = debug.getinfo(level or 3, "Sl")
    local source = info.source:sub(2)
    local line = info.currentline

    -- Simplify path by removing common prefix
    source = source:gsub("^.*lua/", "")

    return {
        source = source,
        line = line,
    }
end

----------------------------------------------------------------------------
--
-- Format log message from arguments.
-- Converts tables to strings using vim.inspect and other types using tostring.
--
-- @param  args   table   Array of arguments to format
--
-- @return string         Formatted message with arguments joined by spaces
--
----------------------------------------------------------------------------
local function format_message(args)
    local parts = {}

    for _, arg in ipairs(args) do
        if type(arg) == "table" then
            table.insert(parts, vim.inspect(arg))
        else
            table.insert(parts, tostring(arg))
        end
    end

    return table.concat(parts, " ")
end

----------------------------------------------------------------------------
--
-- Write log entry to file.
--
-- @param  level    string  Log level name
-- @param  message  string  Formatted message
-- @param  info     table   Caller info with source and line
--
----------------------------------------------------------------------------
local function write_to_file(level, message, info)
    local log_path = get_log_path()
    local timestamp = get_timestamp()

    local log_line = string.format(
        "[%s] [%s] %s:%d - %s\n",
        timestamp,
        level:upper(),
        info.source,
        info.line,
        message
    )

    local file = io.open(log_path, "a")
    if file then
        file:write(log_line)
        file:close()
    end
end

----------------------------------------------------------------------------
--
-- Write log entry to console using vim.api.nvim_echo.
--
-- @param  level    string  Log level name
-- @param  message  string  Formatted message
-- @param  info     table   Caller info with source and line
--
----------------------------------------------------------------------------
local function write_to_console(level, message, info)
    local hl_group = level_colors[level] or "None"
    local prefix = string.format("[%s] %s:%d", level:upper(), info.source, info.line)

    vim.schedule(function()
        vim.api.nvim_echo({
            { prefix .. " - ", hl_group },
            { message, "None" },
        }, false, {})
    end)
end

----------------------------------------------------------------------------
--
-- Core logging function.
-- Checks log level, formats message, and writes to configured outputs.
--
-- @param  level  string  Log level name (trace/debug/info/warn/error/fatal)
-- @param  ...    any     Arguments to log
--
----------------------------------------------------------------------------
local function log(level, ...)
    -- Initialize config on first use
    if not M._initialized then
        init_config()
        M._initialized = true
    end

    -- Check if this level should be logged
    local current_level = M.levels[M.config.level] or M.levels.warn
    local message_level = M.levels[level]

    if message_level < current_level then
        return
    end

    -- Skip if neither console nor file logging is enabled
    if not M.config.use_console and not M.config.use_file then
        return
    end

    local args = { ... }
    local message = format_message(args)
    local info = get_caller_info(4)

    if M.config.use_file then
        write_to_file(level, message, info)
    end

    if M.config.use_console then
        write_to_console(level, message, info)
    end
end

----------------------------------------------------------------------------
--
-- Log a trace-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.trace(...)
    log("trace", ...)
end

----------------------------------------------------------------------------
--
-- Log a debug-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.debug(...)
    log("debug", ...)
end

----------------------------------------------------------------------------
--
-- Log an info-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.info(...)
    log("info", ...)
end

----------------------------------------------------------------------------
--
-- Log a warning-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.warn(...)
    log("warn", ...)
end

----------------------------------------------------------------------------
--
-- Log an error-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.error(...)
    log("error", ...)
end

----------------------------------------------------------------------------
--
-- Log a fatal-level message.
--
-- @param  ...  any  Arguments to log
--
----------------------------------------------------------------------------
function M.fatal(...)
    log("fatal", ...)
end

----------------------------------------------------------------------------
-- Formatted variants (with string.format)
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Log a trace-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_trace(fmt, ...)
    log("trace", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Log a debug-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_debug(fmt, ...)
    log("debug", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Log an info-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_info(fmt, ...)
    log("info", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Log a warning-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_warn(fmt, ...)
    log("warn", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Log an error-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_error(fmt, ...)
    log("error", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Log a fatal-level message with string.format formatting.
--
-- @param  fmt  string  Format string
-- @param  ...  any     Arguments for format string
--
----------------------------------------------------------------------------
function M.fmt_fatal(fmt, ...)
    log("fatal", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Set log level programmatically.
--
-- @param  level  string  Log level name (trace/debug/info/warn/error/fatal)
--
----------------------------------------------------------------------------
function M.set_level(level)
    if M.levels[level] then
        M.config.level = level
    end
end

----------------------------------------------------------------------------
--
-- Get current log level.
--
-- @return string  Current log level name
--
----------------------------------------------------------------------------
function M.get_level()
    return M.config.level
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
