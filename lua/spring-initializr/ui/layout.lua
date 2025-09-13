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
-- Constructs the full Spring Initializr layout UI using NUI components.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Layout = require("nui.layout")
local Popup = require("nui.popup")

local radios = require("spring-initializr.ui.radios")
local inputs = require("spring-initializr.ui.inputs")
local deps = require("spring-initializr.ui.deps")

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
-- Build size for the outer popup.
--
-- @return table  Popup size configuration
--
----------------------------------------------------------------------------
local function outer_size()
    return { width = "70%", height = "75%" }
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
-- @return Popup  Main floating container
--
----------------------------------------------------------------------------
local function create_outer_popup()
    return Popup({
        border = outer_border(),
        position = outer_position(),
        size = outer_size(),
        win_options = outer_win_options(),
    })
end

----------------------------------------------------------------------------
--
-- Format boot version list to remove ".RELEASE" suffix.
--
-- @param  values  table  List of version entries
--
-- @return table          Transformed list
--
----------------------------------------------------------------------------
local function format_boot_versions(values)
    return vim.tbl_map(function(v)
        return { name = v.name, id = v.id and v.id:gsub("%.RELEASE$", "") }
    end, values or {})
end

----------------------------------------------------------------------------
--
-- Create all radio components.
--
-- @param  metadata    table  Spring metadata
-- @param  selections  table  State table of user selections
--
-- @return table              List of Layout.Box components
--
----------------------------------------------------------------------------
local function create_radio_controls(metadata, selections)
    return {
        radios.create_radio("Project Type", metadata.type.values, "project_type", selections),
        radios.create_radio("Language", metadata.language.values, "language", selections),
        radios.create_radio(
            "Spring Boot Version",
            format_boot_versions(metadata.bootVersion.values),
            "boot_version",
            selections
        ),
        radios.create_radio("Packaging", metadata.packaging.values, "packaging", selections),
        radios.create_radio(
            "Java Version",
            metadata.javaVersion.values,
            "java_version",
            selections
        ),
    }
end

----------------------------------------------------------------------------
--
-- Create all input fields.
--
-- @param  selections  table  State table of user selections
--
-- @return table              List of Layout.Box components
--
----------------------------------------------------------------------------
local function create_input_controls(selections)
    return {
        inputs.create_input("Group", "groupId", "com.example", selections),
        inputs.create_input("Artifact", "artifactId", "demo", selections),
        inputs.create_input("Name", "name", "demo", selections),
        inputs.create_input(
            "Description",
            "description",
            "Demo project for Spring Boot",
            selections
        ),
        inputs.create_input("Package Name", "packageName", "com.example.demo", selections),
    }
end

----------------------------------------------------------------------------
--
-- Create the left-hand UI panel with all user-configurable fields.
--
-- @param  metadata    table       Spring metadata
-- @param  selections  table       State table of user selections
--
-- @return Layout.Box              Left panel
--
----------------------------------------------------------------------------
local function create_left_panel(metadata, selections)
    local children = {}
    vim.list_extend(children, create_radio_controls(metadata, selections))
    vim.list_extend(children, create_input_controls(selections))
    return Layout.Box(children, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
--
-- Create the right-hand panel with dependency management.
--
-- @return Layout.Box  Right panel
--
----------------------------------------------------------------------------
local function create_right_panel()
    return Layout.Box({
        Layout.Box(deps.create_button(deps.update_display), { size = "10%" }),
        Layout.Box(deps.create_display(), { size = "90%" }),
    }, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
--
-- Build the entire Spring Initializr layout.
--
-- @param  metadata    table  Fetched Spring metadata
-- @param  selections  table  State table of user selections
--
-- @return table              Contains the layout and the outer popup
--
----------------------------------------------------------------------------
function M.build_ui(metadata, selections)
    local outer_popup = create_outer_popup()

    local layout = Layout(
        outer_popup,
        Layout.Box({
            create_left_panel(metadata, selections),
            create_right_panel(),
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
