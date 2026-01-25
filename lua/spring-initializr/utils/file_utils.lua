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
-- Provides file-related utilities for the Spring Initializr plugin.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Path = require("plenary.path")
local log = require("spring-initializr.trace.log")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Ensures a directory exists, creating it (with parents) if necessary.
--
-- @param  dir_path  string  Path to directory
--
-- @return boolean           True if directory exists or was created
--
----------------------------------------------------------------------------
function M.ensure_directory(dir_path)
    local dir = Path:new(dir_path)

    if dir:exists() then
        return true
    end

    local ok, err = pcall(function()
        dir:mkdir({ parents = true })
    end)

    if not ok then
        return false, "Failed to create directory: " .. (err or "unknown error")
    end

    return true
end

----------------------------------------------------------------------------
--
-- Checks if a file exists at the given path.
--
-- @param  file_path  string   Path to file
--
-- @return boolean             True if file exists
--
----------------------------------------------------------------------------
function M.file_exists(file_path)
    local file = Path:new(file_path)
    return file:exists()
end

----------------------------------------------------------------------------
--
-- Reads the contents of a file.
--
-- @param  file_path  string       Path to file
--
-- @return string|nil              File contents, or nil if error
-- @return string|nil              Error message if failed
--
----------------------------------------------------------------------------
function M.read_file(file_path)
    local file = Path:new(file_path)

    if not file:exists() then
        return nil, "File does not exist: " .. file_path
    end

    local ok, content = pcall(function()
        return file:read()
    end)

    if not ok then
        return nil, "Failed to read file: " .. (content or "unknown error")
    end

    return content, nil
end

----------------------------------------------------------------------------
--
-- Writes content to a file, creating parent directories if needed.
--
-- @param  file_path  string       Path to file
-- @param  content    string       Content to write
--
-- @return boolean                 True if successful
-- @return string|nil              Error message if failed
--
----------------------------------------------------------------------------
function M.write_file(file_path, content)
    log.fmt_debug("Writing file: %s", file_path)
    log.fmt_trace("Content length: %d bytes", #content)

    local file = Path:new(file_path)

    local parent = file:parent()
    if parent then
        local dir_ok, dir_err = M.ensure_directory(parent:absolute())
        if not dir_ok then
            log.error("Failed to create parent directory:", dir_err)
            return false, dir_err
        end
    end

    local ok, err = pcall(function()
        file:write(content, "w")
    end)

    if not ok then
        log.error("File write failed:", err)
        return false, "Failed to write file: " .. (err or "unknown error")
    end

    log.info("File written successfully:", file_path)
    return true, nil
end

----------------------------------------------------------------------------
--
-- Deletes a file if it exists.
--
-- @param  file_path  string       Path to file
--
-- @return boolean                 True if deleted or didn't exist
-- @return string|nil              Error message if failed
--
----------------------------------------------------------------------------
function M.delete_file(file_path)
    local file = Path:new(file_path)

    if not file:exists() then
        return true, nil
    end

    local ok, err = pcall(function()
        file:rm()
    end)

    if not ok then
        return false, "Failed to delete file: " .. (err or "unknown error")
    end

    return true, nil
end

----------------------------------------------------------------------------
--
-- Gets the full path to a file in the plugin's data directory.
--
-- @param  filename  string  Name of file
--
-- @return string            Full path to file
--
----------------------------------------------------------------------------
function M.get_data_file_path(filename)
    local data_dir = vim.fn.stdpath("data") .. "/spring-initializr"
    return data_dir .. "/" .. filename
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
