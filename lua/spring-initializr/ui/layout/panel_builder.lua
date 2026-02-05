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
-- Left and right panel assembly for the layout.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Layout = require("nui.layout")

local radio_section = require("spring-initializr.ui.layout.radio_section")
local input_section = require("spring-initializr.ui.layout.input_section")
local dependencies_display =
    require("spring-initializr.ui.components.dependencies.dependencies_display")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Create the left-hand UI panel with responsive radios and inputs.
--
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return Layout.Box                 Left panel
--
----------------------------------------------------------------------------
function M.create_left_panel(form_context)
    local radios = radio_section.create(form_context)
    local inputs = input_section.create(form_context)

    return Layout.Box({
        radios.box,
        inputs,
    }, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
--
-- Create the right-hand panel with dependency management.
--
-- @param close_fn  function  Module closing function from init.lua
--
-- @return Layout.Box         Right panel
--
----------------------------------------------------------------------------
function M.create_right_panel(close_fn)
    return Layout.Box({
        Layout.Box(
            dependencies_display.create_button(dependencies_display.update_display),
            { size = 3 }
        ),
        Layout.Box(dependencies_display.create_display(close_fn), { grow = 1 }),
    }, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
