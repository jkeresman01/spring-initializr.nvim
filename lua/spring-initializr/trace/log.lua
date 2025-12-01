-- lua/spring-initializr/trace/log.lua
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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Logging module for spring-initializr.nvim
-- Provides configurable trace/debug/info/warn/error/fatal logging
-- to console and/or file.
--
-- Based on rxi/log.lua and tjdevries/vlog.nvim modifed by Josip Keresman for
-- spring-initalizr.nvim
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
-- Initialize logging based on global variables
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
-- Get the log file path
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
-- Format timestamp for log entry
--
-- @return string  Formatted timestamp
--
----------------------------------------------------------------------------
local function get_timestamp()
    return os.date("%Y-%m-%d %H:%M:%S")
end

----------------------------------------------------------------------------
--
-- Get debug info for caller location
--
-- @param  level  number  Stack level to inspect
--
-- @return table         Debug info with source and line
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
-- Format log message
--
-- @param  args   table   Arguments to format
--
-- @return string         Formatted message
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
-- Write to log file
--
-- @param  level    string  Log level name
-- @param  message  string  Formatted message
-- @param  info     table   Caller info
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
-- Write to console
--
-- @param  level    string  Log level name
-- @param  message  string  Formatted message
-- @param  info     table   Caller info
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
-- Core logging function
--
-- @param  level  string  Log level name
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
    local message = format_message(level, args)
    local info = get_caller_info(4)

    if M.config.use_file then
        write_to_file(level, message, info)
    end

    if M.config.use_console then
        write_to_console(level, message, info)
    end
end

----------------------------------------------------------------------------
-- Public API - Log level functions
----------------------------------------------------------------------------

function M.trace(...)
    log("trace", ...)
end

function M.debug(...)
    log("debug", ...)
end

function M.info(...)
    log("info", ...)
end

function M.warn(...)
    log("warn", ...)
end

function M.error(...)
    log("error", ...)
end

function M.fatal(...)
    log("fatal", ...)
end

----------------------------------------------------------------------------
-- Formatted variants (with string.format)
----------------------------------------------------------------------------

function M.fmt_trace(fmt, ...)
    log("trace", string.format(fmt, ...))
end

function M.fmt_debug(fmt, ...)
    log("debug", string.format(fmt, ...))
end

function M.fmt_info(fmt, ...)
    log("info", string.format(fmt, ...))
end

function M.fmt_warn(fmt, ...)
    log("warn", string.format(fmt, ...))
end

function M.fmt_error(fmt, ...)
    log("error", string.format(fmt, ...))
end

function M.fmt_fatal(fmt, ...)
    log("fatal", string.format(fmt, ...))
end

----------------------------------------------------------------------------
--
-- Set log level programmatically
--
-- @param  level  string  Log level name
--
----------------------------------------------------------------------------
function M.set_level(level)
    if M.levels[level] then
        M.config.level = level
    end
end

----------------------------------------------------------------------------
--
-- Get current log level
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
