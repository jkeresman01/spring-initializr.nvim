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
-- Orchestrator for the Spring Initializr layout UI.
-- Creates the outer popup and delegates panel construction to sub-modules.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Layout = require("nui.layout")
local Popup = require("nui.popup")

local config = require("spring-initializr.config.config")
local FormContext = require("spring-initializr.ui.context.form_context")
local calc = require("spring-initializr.ui.layout.column_calculator")
local panel_builder = require("spring-initializr.ui.layout.panel_builder")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Build border config for the outer popup.
--
-- @return table  Border configuration
--
----------------------------------------------------------------------------
local function outer_border()
    return {
        style = "rounded",
        text = { top = "[ Spring Initializr ]", top_align = "center" },
    }
end

----------------------------------------------------------------------------
--
-- Build position for the outer popup.
--
-- @return string  Popup position
--
----------------------------------------------------------------------------
local function outer_position()
    return "50%"
end

----------------------------------------------------------------------------
--
-- Build size for the outer popup with dynamic height.
--
-- @param  content_height  number  Height needed for content
--
-- @return table                   Size configuration
--
----------------------------------------------------------------------------
local function outer_size(content_height)
    local screen_height = vim.o.lines
    local max_height = math.floor(screen_height * calc.MAX_HEIGHT_PERCENT)

    -- Use content height + border, capped at max
    local actual_height = math.min(content_height, max_height)

    return {
        width = "70%",
        height = actual_height,
    }
end

----------------------------------------------------------------------------
--
-- Build window options for the outer popup.
--
-- @return table  Window options
--
----------------------------------------------------------------------------
local function outer_win_options()
    return { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" }
end

----------------------------------------------------------------------------
--
-- Create the outer wrapper popup window.
--
-- @param  content_height  number  Height needed for content
--
-- @return Popup                   Main floating container
--
----------------------------------------------------------------------------
local function create_outer_popup(content_height)
    return Popup({
        border = outer_border(),
        position = outer_position(),
        relative = "editor",
        size = outer_size(content_height),
        win_options = outer_win_options(),
        focusable = false,
    })
end

----------------------------------------------------------------------------
--
-- Build the entire Spring Initializr layout with responsive design.
--
-- @param  metadata    table     Fetched Spring metadata
-- @param  selections  table     State table of user selections
-- @param  close_fn    function  Module closing function from init.lua
--
-- @return table                 Contains the layout and the outer popup
--
----------------------------------------------------------------------------
function M.build_ui(metadata, selections, close_fn)
    -- Calculate content height first to size outer popup
    local content_height = calc.calculate_content_height(metadata)
    local outer_popup = create_outer_popup(content_height)

    selections.configurationFileFormat = config.get_config_format()

    local form_context = FormContext.new(metadata, selections)

    local layout = Layout(
        outer_popup,
        Layout.Box({
            panel_builder.create_left_panel(form_context),
            panel_builder.create_right_panel(close_fn),
        }, { dir = "row" })
    )

    return {
        layout = layout,
        outer_popup = outer_popup,
    }
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
