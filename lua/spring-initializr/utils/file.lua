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

local Job = require("plenary.job")

local M = {}

function M.unzip(zip_path, destination, on_done)
    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", destination },
        on_exit = function()
            os.remove(zip_path)
            vim.schedule(on_done)
        end,
    }):start()
end

return M
