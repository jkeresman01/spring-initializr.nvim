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
-- Gathers current plugin configuration and displays it in a float.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")
local config = require("spring-initializr.config.config")
local config_float = require("spring-initializr.ui.components.config.config_float")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Collects current configuration into structured sections.
--
-- @return table  Array of { title, entries } tables
--                Each entry: { label, value, default }
--
----------------------------------------------------------------------------
function M.collect_config()
    local log_path = string.format("%s/%s.log", vim.fn.stdpath("data"), "spring-initializr")

    return {
        {
            title = "Settings",
            entries = {
                { label = "Config Format", value = config.config_format, default = "properties" },
                { label = "Use Nerd Fonts", value = config.use_nerd_fonts, default = true },
            },
        },
        {
            title = "Logging",
            entries = {
                { label = "Console", value = log.config.use_console, default = false },
                { label = "File", value = log.config.use_file, default = false },
                { label = "Level", value = log.config.level, default = "warn" },
                { label = "Log Path", value = log_path, default = log_path },
            },
        },
    }
end

----------------------------------------------------------------------------
--
-- Entry point: collects config and displays it in a float.
--
----------------------------------------------------------------------------
function M.run()
    log.info("Displaying configuration")

    local sections = M.collect_config()
    local formatted = config_float.format_config(sections)
    config_float.show_float(formatted)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
