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
-- Radio section creation and layout logic.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Layout = require("nui.layout")

local radios = require("spring-initializr.ui.components.common.radios.radios")
local calc = require("spring-initializr.ui.helpers.column_calculator")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

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
            local w = calc.calculate_max_label_width(cfg.values)
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
        local height = calc.calculate_radio_height(cfg.values)
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

        local row_height = calc.find_max_height_in_group(row_configs)
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
function M.create(form_context)
    local radio_configs = create_radio_configs(form_context)
    local available_height = calc.calculate_available_radios_height()
    local columns = calc.determine_columns(radio_configs, available_height)
    local section_height = calc.calculate_radio_section_height(radio_configs, columns)

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
-- Exports
----------------------------------------------------------------------------
return M
