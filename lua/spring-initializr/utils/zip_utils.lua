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
-- Provides zip-related utilities for the Spring Initializr plugin.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Job = require("plenary.job")
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
        on_exit = function(return_val)
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
-- Exports
----------------------------------------------------------------------------
return M
