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
-- Factory for bundling high-level data (metadata and user selections)
-- and provide convenience methods to generate reusable configuration objects
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}
M.__index = M

----------------------------------------------------------------------------
--
-- Creates a new instance of FormContext.
--
-- @param  metadata    table  Stores Spring Initializr API metadata
-- @param  selection   table  Shared global state for user selections
--
-- @return FormContext        Next FormContext instance
--
----------------------------------------------------------------------------
function M.new(metadata, selections)
    return setmetatable({
        metadata = metadata,
        selections = selections,
    }, M)
end

----------------------------------------------------------------------------
--
-- Create a new RadioConfig Parameter Object.
--
-- @param  title       string  Label/title of the radio group
-- @param  values      table   Available radio options
-- @param  key         string  Key to store the selection in state
--
-- @return RadioConfig         Fully configured RadioConfig object
--
----------------------------------------------------------------------------
function M:radio_config(title, values, key)
    local RadioConfig = require("spring-initializr.ui.config.radio_config")
    return RadioConfig.new(title, values, key, self.selections)
end

----------------------------------------------------------------------------
--
-- Create a new InputConfig Parameter Object.
--
-- @param  title    string  Label for the input field
-- @param  key      string  Key to store the selection in state
-- @param  default  string  Default value for input field
--
-- @return InputConfig      Fully configured InputConfig object
--
----------------------------------------------------------------------------
function M:input_config(title, key, default)
    local InputConfig = require("spring-initializr.ui.config.input_config")
    return InputConfig.new(title, key, default, self.selections)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
