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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Registers custom Neovim commands for Spring Initializr UI and project
-- generation.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependecies
----------------------------------------------------------------------------
local ui = require("spring-initializr.ui.init")
local core = require("spring-initializr.core.core")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

-----------------------------------------------------------------------------
--
-- Registers Neovim user commands for Spring Initializr.
--
--
-- Commands:
--   :SpringInitializr       Opens the Spring Initializr UI
--   :SpringGenerateProject  Generates a Spring Boot project
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

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
