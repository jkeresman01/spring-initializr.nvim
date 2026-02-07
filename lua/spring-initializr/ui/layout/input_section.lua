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
-- Input section creation for the layout.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Layout = require("nui.layout")

local inputs = require("spring-initializr.ui.components.common.inputs.inputs")
local calc = require("spring-initializr.ui.helpers.column_calculator")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Create input section with all input fields.
--
-- @param  form_context  FormContext  Context with selections
--
-- @return Layout.Box                 Input section container
--
----------------------------------------------------------------------------
function M.create(form_context)
    local children = {
        inputs.create_input(form_context:input_config("Group", "groupId", "com.example")),
        inputs.create_input(form_context:input_config("Artifact", "artifactId", "demo")),
        inputs.create_input(form_context:input_config("Name", "name", "demo")),
        inputs.create_input(
            form_context:input_config("Description", "description", "Demo project for Spring Boot")
        ),
        inputs.create_input(
            form_context:input_config("Package Name", "packageName", "com.example.demo")
        ),
    }

    return Layout.Box(children, { dir = "col", size = calc.INPUT_COUNT * calc.INPUT_HEIGHT })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
