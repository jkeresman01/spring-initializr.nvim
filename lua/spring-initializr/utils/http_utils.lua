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
-- Provides simple HTTP-related utilities for downloading files.
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
-- Internal callback handler for curl job exit.
--
-- @param  return_val  number     Exit code from curl
-- @param  on_success  function   Callback on success
-- @param  on_error    function   Callback on error
--
----------------------------------------------------------------------------
local function handle_download_exit(return_val, on_success, on_error)
    if return_val ~= 0 then
        vim.schedule(on_error)
    else
        vim.schedule(on_success)
    end
end

----------------------------------------------------------------------------
--
-- Downloads a file from a URL to a given output path using `curl`.
--
-- @param  url          string     URL to download
-- @param  output_path  string     Destination file path
-- @param  on_success   function   Callback on success
-- @param  on_error     function   Callback on error
--
----------------------------------------------------------------------------
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
