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
-- Provides file-related utilities for the Spring Initializr plugin.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Job = require("plenary.job")
local Path = require("plenary.path")
local log = require("spring-initializr.trace.log")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Removes a file and calls a continuation on the main thread.
--
-- @param  path      string    Path to the file to remove
-- @param  callback  function  Callback to execute after removal
--
----------------------------------------------------------------------------
local function remove_file_and_continue(path, callback)
    os.remove(path)
    vim.schedule(callback)
end

----------------------------------------------------------------------------
--
-- Callback function passed to plenary job to handle unzip result.
--
-- @param  zip_path   string    Path to the zip file
-- @param  on_done    function  Callback to execute after unzip completes
--
-- @return function             Wrapped callback for Job:on_exit
--
----------------------------------------------------------------------------
local function on_unzip_complete(zip_path, on_done)
    return function()
        remove_file_and_continue(zip_path, on_done)
    end
end

----------------------------------------------------------------------------
--
-- Unzips a file to a target directory and removes the zip after.
--
-- @param  zip_path     string    Path to the zip file
-- @param  destination  string    Target directory
-- @param  on_done      function  Callback to execute when done
--
----------------------------------------------------------------------------
function M.unzip(zip_path, destination, on_done)
    log.fmt_info("Unzipping file: %s to %s", zip_path, destination)

    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", destination },
        on_exit = function(j, return_val)
            if return_val == 0 then
                log.info("Unzip completed successfully")
            else
                log.error("Unzip failed with code:", return_val)
            end
            on_unzip_complete(zip_path, on_done)()
        end,
    }):start()

    log.trace("Unzip job started")
end

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
