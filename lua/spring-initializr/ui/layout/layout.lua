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
-- Constructs the full Spring Initializr layout UI using NUI components.
-- Implements responsive flexbox-like layout for radio components.
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
-- Constants
----------------------------------------------------------------------------
local INPUT_HEIGHT = 3
local INPUT_COUNT = 5
local OUTER_BORDER_HEIGHT = 2
local MIN_COLUMNS = 1
local MAX_COLUMNS = 3
local MAX_HEIGHT_PERCENT = 0.90

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
    local max_height = math.floor(screen_height * MAX_HEIGHT_PERCENT)

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
-- Calculate the height needed for a single radio component.
--
-- @param  values  table   List of options
--
-- @return number          Height in lines (options + border)
--
----------------------------------------------------------------------------
local function calculate_radio_height(values)
    return #values + 2
end

----------------------------------------------------------------------------
--
-- Calculate the maximum label width for a radio's values.
--
-- @param  values  table   List of options
--
-- @return number          Max label width in characters
--
----------------------------------------------------------------------------
local function calculate_max_label_width(values)
    local max_width = 0
    for _, v in ipairs(values) do
        local label = v.name or v.id or ""
        if #label > max_width then
            max_width = #label
        end
    end
    -- Add padding for radio icon (2), spacing (2), and borders (2)
    return max_width + 6
end

----------------------------------------------------------------------------
--
-- Calculate total height needed for all radios stacked vertically.
--
-- @param  radio_configs  table  List of radio configurations
--
-- @return number                Total height needed
--
----------------------------------------------------------------------------
local function calculate_total_radios_height(radio_configs)
    local total = 0
    for _, cfg in ipairs(radio_configs) do
        total = total + calculate_radio_height(cfg.values)
    end
    return total
end

----------------------------------------------------------------------------
--
-- Calculate maximum available height for the layout.
--
-- @return number  Maximum height in lines
--
----------------------------------------------------------------------------
local function calculate_max_available_height()
    local screen_height = vim.o.lines
    return math.floor(screen_height * MAX_HEIGHT_PERCENT) - OUTER_BORDER_HEIGHT
end

----------------------------------------------------------------------------
--
-- Calculate available height for radios section.
--
-- @return number  Available height for radios
--
----------------------------------------------------------------------------
local function calculate_available_radios_height()
    local available = calculate_max_available_height()
    local inputs_height = INPUT_COUNT * INPUT_HEIGHT
    return available - inputs_height
end

----------------------------------------------------------------------------
--
-- Find the maximum height among radio configs in a group.
--
-- @param  configs  table   List of radio configurations
--
-- @return number           Maximum height needed
--
----------------------------------------------------------------------------
local function find_max_height_in_group(configs)
    local max_height = 0
    for _, cfg in ipairs(configs) do
        local height = calculate_radio_height(cfg.values)
        if height > max_height then
            max_height = height
        end
    end
    return max_height
end

----------------------------------------------------------------------------
--
-- Calculate total height for radio section based on layout.
--
-- @param  radio_configs  table   List of radio configurations
-- @param  columns        number  Number of columns
--
-- @return number                 Total height needed
--
----------------------------------------------------------------------------
local function calculate_radio_section_height(radio_configs, columns)
    if columns == 1 then
        return calculate_total_radios_height(radio_configs)
    end

    local total_height = 0
    for i = 1, #radio_configs, columns do
        local group = {}
        for j = 0, columns - 1 do
            if radio_configs[i + j] then
                table.insert(group, radio_configs[i + j])
            end
        end
        total_height = total_height + find_max_height_in_group(group)
    end

    return total_height
end

----------------------------------------------------------------------------
--
-- Determine optimal number of columns based on available space.
--
-- @param  radio_configs    table   List of radio configurations
-- @param  available_height number  Available height for radios
--
-- @return number                   Number of columns (1, 2, or 3)
--
----------------------------------------------------------------------------
local function determine_columns(radio_configs, available_height)
    local total_vertical = calculate_total_radios_height(radio_configs)

    -- If everything fits in one column, use one column
    if total_vertical <= available_height then
        return MIN_COLUMNS
    end

    -- Try 2 columns
    local height_for_2_cols = calculate_radio_section_height(radio_configs, 2)

    if height_for_2_cols <= available_height then
        return 2
    end

    -- Use 3 columns
    return MAX_COLUMNS
end

----------------------------------------------------------------------------
--
-- Create radio configurations from metadata.
--
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return table                      List of radio configurations
--
----------------------------------------------------------------------------
local function create_radio_configs(form_context)
    local metadata = form_context.metadata
    return {
        form_context:radio_config("Language", metadata.language.values, "language"),
        form_context:radio_config(
            "Spring Boot Version",
            format_boot_versions(metadata.bootVersion.values),
            "boot_version"
        ),
        form_context:radio_config("Packaging", metadata.packaging.values, "packaging"),
        form_context:radio_config("Java Version", metadata.javaVersion.values, "java_version"),
        form_context:radio_config("Project Type", metadata.type.values, "project_type"),
        form_context:radio_config(
            "Config Format",
            metadata.configurationFileFormat.values,
            "configurationFileFormat"
        ),
    }
end

----------------------------------------------------------------------------
--
-- Create a single row of radio components.
-- 2 items: equal width (50% each)
-- 3 items: proportional width based on content
--
-- @param  configs     table   Radio configurations for this row
-- @param  row_height  number  Height for this row
--
-- @return Layout.Box          Row containing radio components
--
----------------------------------------------------------------------------
local function create_radio_row(configs, row_height)
    local row_children = {}

    -- For 2 items, use equal width; for 3+, use proportional
    if #configs <= 2 then
        local equal_percent = math.floor(100 / #configs)
        for i, cfg in ipairs(configs) do
            local radio_popup = radios.create_radio(cfg)
            local width_percent
            if i == #configs then
                width_percent = 100 - (equal_percent * (#configs - 1))
            else
                width_percent = equal_percent
            end
            table.insert(row_children, Layout.Box(radio_popup, { size = width_percent .. "%" }))
        end
    else
        -- Calculate width needed for each radio based on content
        local widths = {}
        local total_width = 0
        for _, cfg in ipairs(configs) do
            local w = calculate_max_label_width(cfg.values)
            table.insert(widths, w)
            total_width = total_width + w
        end

        -- Create radios with proportional widths
        local used_percent = 0
        for i, cfg in ipairs(configs) do
            local radio_popup = radios.create_radio(cfg)

            local width_percent
            if i == #configs then
                -- Last item gets remainder to ensure 100% total
                width_percent = 100 - used_percent
            else
                width_percent = math.floor((widths[i] / total_width) * 100)
                used_percent = used_percent + width_percent
            end

            table.insert(row_children, Layout.Box(radio_popup, { size = width_percent .. "%" }))
        end
    end

    return Layout.Box(row_children, { dir = "row", size = row_height })
end

----------------------------------------------------------------------------
--
-- Create single-column radio layout.
--
-- @param  radio_configs  table  List of radio configurations
--
-- @return table                 List of Layout.Box children
--
----------------------------------------------------------------------------
local function create_single_column_radios(radio_configs)
    local children = {}
    for _, cfg in ipairs(radio_configs) do
        local height = calculate_radio_height(cfg.values)
        local radio_popup = radios.create_radio(cfg)
        table.insert(children, Layout.Box(radio_popup, { size = height }))
    end
    return children
end

----------------------------------------------------------------------------
--
-- Create multi-column radio layout.
--
-- @param  radio_configs  table   List of radio configurations
-- @param  columns        number  Number of columns per row
--
-- @return table                  List of Layout.Box row children
--
----------------------------------------------------------------------------
local function create_multi_column_radios(radio_configs, columns)
    local rows = {}

    for i = 1, #radio_configs, columns do
        local row_configs = {}
        for j = 0, columns - 1 do
            if radio_configs[i + j] then
                table.insert(row_configs, radio_configs[i + j])
            end
        end

        local row_height = find_max_height_in_group(row_configs)
        table.insert(rows, create_radio_row(row_configs, row_height))
    end

    return rows
end

----------------------------------------------------------------------------
--
-- Create responsive radio section with flexbox-like wrapping.
--
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return table                      { box = Layout.Box, height = number }
--
----------------------------------------------------------------------------
local function create_radio_section(form_context)
    local radio_configs = create_radio_configs(form_context)
    local available_height = calculate_available_radios_height()
    local columns = determine_columns(radio_configs, available_height)
    local section_height = calculate_radio_section_height(radio_configs, columns)

    local children
    if columns == 1 then
        children = create_single_column_radios(radio_configs)
    else
        children = create_multi_column_radios(radio_configs, columns)
    end

    return {
        box = Layout.Box(children, { dir = "col", size = section_height }),
        height = section_height,
    }
end

----------------------------------------------------------------------------
--
-- Calculate total content height needed for left panel.
--
-- @param  metadata  table  Spring Initializr metadata
--
-- @return number           Total height needed
--
----------------------------------------------------------------------------
local function calculate_content_height(metadata)
    -- Build temporary radio configs to calculate height
    local radio_configs = {
        { values = metadata.language.values },
        { values = metadata.bootVersion.values },
        { values = metadata.packaging.values },
        { values = metadata.javaVersion.values },
        { values = metadata.type.values },
        { values = metadata.configurationFileFormat.values },
    }

    local available_height = calculate_available_radios_height()
    local columns = determine_columns(radio_configs, available_height)
    local radio_section_height = calculate_radio_section_height(radio_configs, columns)
    local inputs_height = INPUT_COUNT * INPUT_HEIGHT

    return radio_section_height + inputs_height
end

----------------------------------------------------------------------------
--
-- Create input section with all input fields.
--
-- @param  form_context  FormContext  Context with selections
--
-- @return Layout.Box                 Input section container
--
----------------------------------------------------------------------------
local function create_input_section(form_context)
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

    return Layout.Box(children, { dir = "col", size = INPUT_COUNT * INPUT_HEIGHT })
end

----------------------------------------------------------------------------
--
-- Create the left-hand UI panel with responsive radios and inputs.
--
-- @param  form_context  FormContext  Context with metadata and selections
--
-- @return Layout.Box                 Left panel
--
----------------------------------------------------------------------------
local function create_left_panel(form_context)
    local radio_section = create_radio_section(form_context)
    local input_section = create_input_section(form_context)

    return Layout.Box({
        radio_section.box,
        input_section,
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
    local content_height = calculate_content_height(metadata)
    local outer_popup = create_outer_popup(content_height)

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
