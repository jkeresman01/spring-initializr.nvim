--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: utils/http.lua
-- Author: Josip Keresman
--
-- Provides simple HTTP-related utilities

local Job = require("plenary.job")

local M = {}

--- Internal callback handler for curl job exit.
--
-- @param return_val number
-- @param on_success function
-- @param on_error function
local function handle_download_exit(return_val, on_success, on_error)
    if return_val ~= 0 then
        vim.schedule(on_error)
    else
        vim.schedule(on_success)
    end
end

--- Downloads a file from a URL to a given output path using `curl`.
--
-- @param url string
-- @param output_path
-- @param on_success
-- @param on_error
function M.download_file(url, output_path, on_success, on_error)
    Job:new({
        command = "curl",
        args = { "-L", url, "-o", output_path },
        on_exit = function(_, return_val)
            handle_download_exit(return_val, on_success, on_error)
        end,
    }):start()
end

return M
