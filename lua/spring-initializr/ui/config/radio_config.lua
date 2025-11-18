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
-- and the shared state for a single radio button group.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}
M.__index = M

----------------------------------------------------------------------------
--
-- Creates a new instance of RadioConfig.
--
-- @param  title        string  Label/Title for the input field
-- @param  values       string  List of available radio options
-- @param  key          string  Key used to store value in selections table
-- @param  selections   table   Shared state table for user selections
--
-- @return InputConfig          A new RadioConfig instance
--
----------------------------------------------------------------------------
function M.new(title, values, key, selections)
    return setmetatable({
        title = title,
        values = values,
        key = key,
        selections = selections,
    }, M)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
