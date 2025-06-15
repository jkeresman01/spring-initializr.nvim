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

local Job = require("plenary.job")

local M = {}

function M.download_file(url, output_path, on_success, on_error)
    Job:new({
        command = "curl",
        args = { "-L", url, "-o", output_path },
        on_exit = function(_, return_val)
            if return_val ~= 0 then
                vim.schedule(on_error)
            else
                vim.schedule(on_success)
            end
        end,
    }):start()
end

return M
