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
---------------------------------------------------------------------------

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

local radios = require("spring-initializr.ui.components.common.radios.radios")
local inputs = require("spring-initializr.ui.components.common.inputs.inputs")
local config = require("spring-initializr.config.config")
local dependencies_display =
    require("spring-initializr.ui.components.dependencies.dependencies_display")

local FormContext = require("spring-initializr.ui.context.form_context")

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
-- Calculate minimum height needed for left panel content.
--
-- @param  metadata  table  Spring Initializr metadata
--
-- @return number            Minimum lines needed
--
----------------------------------------------------------------------------
local function calculate_required_height(metadata)
    local height = 0

    height = height + #metadata.type.values + 2 -- Project Type
    height = height + #metadata.language.values + 2 -- Language
    height = height + #metadata.bootVersion.values + 2 -- Boot Version
    height = height + #metadata.packaging.values + 2 -- Packaging
    height = height + #metadata.javaVersion.values + 2 -- Java Version
    height = height + #metadata.configurationFileFormat.values + 2 -- Config Format

    local input_count = 5 -- Group, Artifact, Name, Description, Package Name
    height = height + (input_count * 3)

    return height
end

----------------------------------------------------------------------------
--
-- Build size for the outer popup with dynamic height calculation.
-- Calculates height based on actual content needs with min/max constraints.
--
-- @param  metadata  table  Spring Initializr metadata for precise calculation
--
-- @return table            Size configuration
--
----------------------------------------------------------------------------
local function outer_size(metadata)
    local screen_height = vim.o.lines

    local required_height = calculate_required_height(metadata)

    -- Cap at 90% of screen height (leave space for status line, command line)
    local max_height = math.floor(screen_height * 0.90)

    -- Use the smaller of required or max
    local actual_height = math.min(required_height, max_height)

    -- Ensure absolute minimum for very small terminals
    actual_height = math.max(actual_height, 45)

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
-- Create the outer wrapper popup window with dynamic sizing.
--
-- @param  metadata  table  Spring Initializr metadata for height calculation
--
-- @return Popup            Main floating container
--
----------------------------------------------------------------------------
local function create_outer_popup(metadata)
    return Popup({
        border = outer_border(),
        position = outer_position(),
        size = outer_size(metadata),
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
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return table                      List of Layout.Box components
--
----------------------------------------------------------------------------
local function create_radio_controls(form_context)
    local metadata = form_context.metadata
    return {
        radios.create_radio(
            form_context:radio_config("Project Type", metadata.type.values, "project_type")
        ),
        radios.create_radio(
            form_context:radio_config("Language", metadata.language.values, "language")
        ),
        radios.create_radio(
            form_context:radio_config(
                "Spring Boot Version",
                format_boot_versions(metadata.bootVersion.values),
                "boot_version"
            )
        ),
        radios.create_radio(
            form_context:radio_config("Packaging", metadata.packaging.values, "packaging")
        ),
        radios.create_radio(
            form_context:radio_config("Java Version", metadata.javaVersion.values, "java_version")
        ),
        radios.create_radio(
            form_context:radio_config(
                "Config Format",
                metadata.configurationFileFormat.values,
                "configurationFileFormat"
            )
        ),
    }
end

----------------------------------------------------------------------------
--
-- Create all input fields.
--
-- @param  form_context  FormContext  Context with selections
--
-- @return table                      List of Layout.Box components
--
----------------------------------------------------------------------------
local function create_input_controls(form_context)
    return {
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
end

----------------------------------------------------------------------------
--
-- Create the left-hand UI panel with all user-configurable fields.
--
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return Layout.Box                 Left panel
--
----------------------------------------------------------------------------
local function create_left_panel(form_context)
    local children = {}
    vim.list_extend(children, create_radio_controls(form_context))
    vim.list_extend(children, create_input_controls(form_context))
    return Layout.Box(children, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
--
-- Create the right-hand panel with dependency management.
--
-- @param close_fn     function  Module closing function from init.lua
--
-- @return Layout.Box            Right panel
--
----------------------------------------------------------------------------
local function create_right_panel(close_fn)
    return Layout.Box({
        Layout.Box(
            dependencies_display.create_button(dependencies_display.update_display),
            { size = 3 }
        ),
        Layout.Box(dependencies_display.create_display(close_fn), { grow = 1 }),
    }, { dir = "col", size = "50%" })
end

----------------------------------------------------------------------------
--
-- Build the entire Spring Initializr layout with dynamic sizing.
--
-- @param  metadata    table     Fetched Spring metadata
-- @param  selections  table     State table of user selections
-- @param  close_fn   function   Module closing function from init.lua
--
-- @return table                 Contains the layout and the outer popup
--
----------------------------------------------------------------------------
function M.build_ui(metadata, selections, close_fn)
    local outer_popup = create_outer_popup(metadata)

    selections.configurationFileFormat = config.get_config_format()

    local form_context = FormContext.new(metadata, selections)

    local layout = Layout(
        outer_popup,
        Layout.Box({
            create_left_panel(form_context),
            create_right_panel(close_fn),
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
