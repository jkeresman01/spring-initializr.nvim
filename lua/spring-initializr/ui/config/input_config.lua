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
-- Parameter Object used as a constructor to bundle configuration data
-- and shared state for a single input field.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}
M.__index = M

---------------------------------------------------------------------------
-- Public API
----------------------------------------------------------------------------
--
-- Creates a new instance of InputConfig.
--
-- @param  title        string  Label/Title for the input field
-- @param  key          string  Key used to store value in selections table
-- @param  default      string  Default starting value for input
-- @param  selections   table   Shared state table for user selections
--
-- @return InputConfig          A new InputConfig instance
--
----------------------------------------------------------------------------
function M.new(title, key, default, selections)
    return setmetatable({
        title = title,
        key = key,
        default = default or "",
        selections = selections,
    }, M)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
