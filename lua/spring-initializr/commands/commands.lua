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
-- Registers custom Neovim commands for Spring Initializr UI and project
-- generation.
--
-- License: GPL-3.0
-- Author: Josip Keresman
---
----------------------------------------------------------------------------

local ui = require("spring-initializr.ui.init")
local core = require("spring-initializr.core.core")

local M = {}

-----------------------------------------------------------------------------
-- Registers Neovim user commands for Spring Initializr.
--
--
-- Commands:
--   :SpringInitializr       Opens the Spring Initializr UI
--   :SpringGenerateProject  Generates a Spring Boot project into the CWD
--
-----------------------------------------------------------------------------
function M.register()
    vim.api.nvim_create_user_command("SpringInitializr", function()
        ui.setup()
    end, { desc = "Open Spring Initializer UI" })

    vim.api.nvim_create_user_command("SpringGenerateProject", function()
        core.generate_project()
    end, { desc = "Generate Spring Boot project to CWD" })
end

return M
