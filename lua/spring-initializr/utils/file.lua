--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: utils/file.lua
-- Author: Josip Keresman
--
-- Provides file-related utilities

local Job = require("plenary.job")

local M = {}

--- Removes a file and calls a continuation on the main thread.
---
--- @param path string
--- @param callback function
local function remove_file_and_continue(path, callback)
    os.remove(path)
    vim.schedule(callback)
end

--- Callback function passed to plenary job to handle unzip result.
---
--- @param zip_path string
--- @param on_done function
local function on_unzip_complete(zip_path, on_done)
    return function()
        remove_file_and_continue(zip_path, on_done)
    end
end

--- Unzips a file to a target directory and removes the zip after.
---
--- @param zip_path string
--- @param destination string
--- @param on_done function
function M.unzip(zip_path, destination, on_done)
    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", destination },
        on_exit = on_unzip_complete(zip_path, on_done),
    }):start()
end

return M
