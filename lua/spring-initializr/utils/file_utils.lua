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
-- Provides file-related utilities for the Spring Initializr plugin.
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Job = require("plenary.job")

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
    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", destination },
        on_exit = on_unzip_complete(zip_path, on_done),
    }):start()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
