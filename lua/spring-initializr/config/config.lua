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
-- Manages plugin configuration.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    config_format = "properties",
    use_nerd_fonts = true,
    persist_state = false,
}

----------------------------------------------------------------------------
--
-- Sets up plugin configuration.
--
-- @param  user_config  table|nil  User-provided configuration options
--                                 Supported fields:
--                                   - config_format: "properties" or "yaml"
--                                   - use_nerd_fonts: boolean (default: true)
--                                   - persist_state: boolean (default: false)
--
----------------------------------------------------------------------------
function M.setup(user_config)
    if user_config then
        if user_config.config_format then
            M.config_format = user_config.config_format
        end
        if user_config.use_nerd_fonts ~= nil then
            M.use_nerd_fonts = user_config.use_nerd_fonts
        end
        if user_config.persist_state ~= nil then
            M.persist_state = user_config.persist_state
        end
    end
end

----------------------------------------------------------------------------
--
-- Gets the configured format.
--
-- @return string  Configuration format ("properties" or "yaml")
--
----------------------------------------------------------------------------
function M.get_config_format()
    return M.config_format
end

----------------------------------------------------------------------------
--
-- Gets whether to use Nerd Font icons.
--
-- @return boolean  True if Nerd Fonts should be used
--
----------------------------------------------------------------------------
function M.get_use_nerd_fonts()
    return M.use_nerd_fonts
end

----------------------------------------------------------------------------
--
-- Gets whether state persistence is enabled.
--
-- @return boolean  True if state should be persisted between sessions
--
----------------------------------------------------------------------------
function M.get_persist_state()
    return M.persist_state
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
