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
-- Entry point for the Spring Initializr Neovim plugin.
-- Registers all user commands and sets up the plugin.
--
----------------------------------------------------------------------------

local commands = require("spring-initializr.commands.commands")
local config = require("spring-initializr.config.config")

local M = {}

-----------------------------------------------------------------------------
--
-- Initializes the plugin by registering user commands.
--
-- @param  user_config  table|nil  Optional configuration options
--                                 Supported fields:
--                                   - config_format: "properties" or "yaml"
--
-- @example
-- require("spring-initializr").setup()
--
-- @example
-- local ConfigFormat = require("spring-initializr.constants.config_format")
-- require("spring-initializr").setup({
--   config_format = ConfigFormat.YAML
-- })
--
-----------------------------------------------------------------------------
function M.setup(user_config)
    config.setup(user_config)
    commands.register()
end

return M
