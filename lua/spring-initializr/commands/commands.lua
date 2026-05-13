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
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Registers custom Neovim commands for Spring Initializr UI and project
-- generation.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local ui = require("spring-initializr.ui.init")
local spring_initializr = require("spring-initializr.core.core")

----------------------------------------------------------------------------
-- Constants (enum-like command names)
----------------------------------------------------------------------------
local CMD = {
    SPRING_INITIALIZR = "SpringInitializr",
    SPRING_GENERATE_PROJECT = "SpringGenerateProject",
    SPRING_INITIALIZR_HEALTH = "SpringInitializrHealth",
    SPRING_INITIALIZR_CONFIG = "SpringInitializrConfig",
    SPRING_INITIALIZR_LOG = "SpringInitializrLog",
}

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Register :SpringInitializr
--
----------------------------------------------------------------------------
local function register_cmd_spring_initializr()
    vim.api.nvim_create_user_command(CMD.SPRING_INITIALIZR, function()
        ui.setup()
    end, { desc = "Open Spring Initializr UI" })
end

----------------------------------------------------------------------------
--
-- Register :SpringGenerateProject
--
----------------------------------------------------------------------------
local function register_cmd_spring_generate_project()
    vim.api.nvim_create_user_command(CMD.SPRING_GENERATE_PROJECT, function()
        spring_initializr.generate_project()
    end, { desc = "Generate Spring Boot project to CWD" })
end

----------------------------------------------------------------------------
--
-- Register :SpringInitializrHealth
--
----------------------------------------------------------------------------
local function register_cmd_spring_initializr_health()
    vim.api.nvim_create_user_command(CMD.SPRING_INITIALIZR_HEALTH, function()
        require("spring-initializr.health.health").run()
    end, { desc = "Run Spring Initializr health check" })
end

----------------------------------------------------------------------------
--
-- Register :SpringInitializrConfig
--
----------------------------------------------------------------------------
local function register_cmd_spring_initializr_config()
    vim.api.nvim_create_user_command(CMD.SPRING_INITIALIZR_CONFIG, function()
        require("spring-initializr.config.config_display").run()
    end, { desc = "Display Spring Initializr configuration" })
end

----------------------------------------------------------------------------
--
-- Register :SpringInitializrLog
--
----------------------------------------------------------------------------
local function register_cmd_spring_initializr_log()
    local subcommands = { "split", "vsplit", "clear" }

    vim.api.nvim_create_user_command(CMD.SPRING_INITIALIZR_LOG, function(opts)
        local args = opts.args ~= "" and opts.args or nil
        require("spring-initializr.trace.log_display").run(args)
    end, {
        desc = "View Spring Initializr log file",
        nargs = "?",
        complete = function()
            return subcommands
        end,
    })
end

----------------------------------------------------------------------------
--
-- Register Neovim user commands for Spring Initializr.
--
-- Commands:
--   :SpringInitializr        Opens the Spring Initializr UI
--   :SpringGenerateProject   Generates a Spring Boot project
--   :SpringInitializrHealth  Runs health check diagnostics
--   :SpringInitializrConfig  Displays current configuration
--   :SpringInitializrLog     Views plugin log file
--
----------------------------------------------------------------------------
function M.register()
    register_cmd_spring_initializr()
    register_cmd_spring_generate_project()
    register_cmd_spring_initializr_health()
    register_cmd_spring_initializr_config()
    register_cmd_spring_initializr_log()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
