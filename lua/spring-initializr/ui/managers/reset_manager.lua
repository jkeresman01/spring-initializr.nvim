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
-- Manages form reset functionality for Spring Initializr UI.
-- Coordinates resetting all form fields to their default values.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local message_utils = require("spring-initializr.utils.message_utils")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local DEFAULT_VALUES = {
    groupId = "com.example",
    artifactId = "demo",
    name = "demo",
    description = "Demo project for Spring Boot",
    packageName = "com.example.demo",
}

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        reset_handlers = {},
    },
}

----------------------------------------------------------------------------
--
-- Register a reset handler function.
--
-- @param handler  function  Handler to call during reset
--
----------------------------------------------------------------------------
function M.register_reset_handler(handler)
    if type(handler) == "function" then
        table.insert(M.state.reset_handlers, handler)
    end
end

----------------------------------------------------------------------------
--
-- Clear all registered reset handlers.
--
----------------------------------------------------------------------------
function M.clear_handlers()
    M.state.reset_handlers = {}
end

----------------------------------------------------------------------------
--
-- Reset input field values to defaults.
--
-- @param selections  table  Selections table to reset
--
----------------------------------------------------------------------------
local function reset_input_values(selections)
    selections.groupId = DEFAULT_VALUES.groupId
    selections.artifactId = DEFAULT_VALUES.artifactId
    selections.name = DEFAULT_VALUES.name
    selections.description = DEFAULT_VALUES.description
    selections.packageName = DEFAULT_VALUES.packageName
end

----------------------------------------------------------------------------
--
-- Clear all selected dependencies.
--
----------------------------------------------------------------------------
local function clear_dependencies()
    local telescope = require("spring-initializr.telescope.telescope")
    telescope.selected_dependencies = {}
    telescope.selected_dependencies_full = {}
    if telescope.selected_set then
        telescope.selected_set:clear()
    end
end

----------------------------------------------------------------------------
--
-- Execute all registered reset handlers safely.
--
----------------------------------------------------------------------------
local function execute_handlers()
    for _, handler in ipairs(M.state.reset_handlers) do
        pcall(handler)
    end
end

----------------------------------------------------------------------------
--
-- Reset the entire form to default values.
--
-- @param selections  table  Selections table to reset
--
----------------------------------------------------------------------------
function M.reset_form(selections)
    reset_input_values(selections)
    clear_dependencies()
    execute_handlers()
    message_utils.show_info_message("Form reset to defaults")
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
