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
    use_nerd_fonts = true,
}

----------------------------------------------------------------------------
--
-- Sets up plugin configuration.
--
-- @param  user_config  table|nil  User-provided configuration options
--                                 Supported fields:
--                                   - config_format: "properties" or "yaml"
--                                   - use_nerd_fonts: boolean (default: true)
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
-- Exports
----------------------------------------------------------------------------
return M
