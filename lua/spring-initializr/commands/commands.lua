--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: commands/commands.lua
-- Author: Josip Keresman
--
-- Description: Registers custom Neovim commands for Spring Initializr UI and project generation.

local ui = require("spring-initializr.ui.init")
local core = require("spring-initializr.core.core")

local M = {}

--- Registers Neovim user commands for Spring Initializr.
function M.register()
    vim.api.nvim_create_user_command("SpringInitializr", function()
        ui.setup()
    end, { desc = "Open Spring Initializer UI" })

    vim.api.nvim_create_user_command("SpringGenerateProject", function()
        core.generate_project()
    end, { desc = "Generate Spring Boot project to CWD" })
end

return M
