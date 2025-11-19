---------------------------------------------------------------------------
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
-- Manages plugin configuration.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    config_format = "properties",
}

----------------------------------------------------------------------------
--
-- Sets up plugin configuration.
--
-- @param  user_config  table|nil  User-provided configuration options
--                                 Supported fields:
--                                   - config_format: "properties" or "yaml"
--
----------------------------------------------------------------------------
function M.setup(user_config)
    if user_config and user_config.config_format then
        M.config_format = user_config.config_format
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
-- Exports
----------------------------------------------------------------------------
return M
