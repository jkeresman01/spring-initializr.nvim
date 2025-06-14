--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: command.lua
-- Author: Josip Keresman

local ui = require("spring-initializr.ui")
local core = require("spring-initializr.core")

local M = {}

function M.register()
    vim.api.nvim_create_user_command("SpringInitializr", function()
        ui.setup_ui()
    end, {
        desc = "Open Spring Initializer UI",
    })

    vim.api.nvim_create_user_command("SpringGenerateProject", function()
        core.generate_project()
    end, {
        desc = "Generate Spring Boot project to CWD",
    })
end

return M
