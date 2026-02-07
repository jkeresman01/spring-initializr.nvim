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
-- Pure dimension and column calculations for the layout.
-- No NUI dependencies — only uses vim.o.lines for screen size.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
M.INPUT_HEIGHT = 3
M.INPUT_COUNT = 5
M.OUTER_BORDER_HEIGHT = 2
M.MIN_COLUMNS = 1
M.MAX_COLUMNS = 3
M.MAX_HEIGHT_PERCENT = 0.90

----------------------------------------------------------------------------
--
-- Calculate the height needed for a single radio component.
--
-- @param  values  table   List of options
--
-- @return number          Height in lines (options + border)
--
----------------------------------------------------------------------------
function M.calculate_radio_height(values)
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
function M.calculate_max_label_width(values)
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
function M.calculate_total_radios_height(radio_configs)
    local total = 0
    for _, cfg in ipairs(radio_configs) do
        total = total + M.calculate_radio_height(cfg.values)
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
function M.calculate_max_available_height()
    local screen_height = vim.o.lines
    return math.floor(screen_height * M.MAX_HEIGHT_PERCENT) - M.OUTER_BORDER_HEIGHT
end

----------------------------------------------------------------------------
--
-- Calculate available height for radios section.
--
-- @return number  Available height for radios
--
----------------------------------------------------------------------------
function M.calculate_available_radios_height()
    local available = M.calculate_max_available_height()
    local inputs_height = M.INPUT_COUNT * M.INPUT_HEIGHT
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
function M.find_max_height_in_group(configs)
    local max_height = 0
    for _, cfg in ipairs(configs) do
        local height = M.calculate_radio_height(cfg.values)
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
function M.calculate_radio_section_height(radio_configs, columns)
    if columns == 1 then
        return M.calculate_total_radios_height(radio_configs)
    end

    local total_height = 0
    for i = 1, #radio_configs, columns do
        local group = {}
        for j = 0, columns - 1 do
            if radio_configs[i + j] then
                table.insert(group, radio_configs[i + j])
            end
        end
        total_height = total_height + M.find_max_height_in_group(group)
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
function M.determine_columns(radio_configs, available_height)
    local total_vertical = M.calculate_total_radios_height(radio_configs)

    -- If everything fits in one column, use one column
    if total_vertical <= available_height then
        return M.MIN_COLUMNS
    end

    -- Try 2 columns
    local height_for_2_cols = M.calculate_radio_section_height(radio_configs, 2)

    if height_for_2_cols <= available_height then
        return 2
    end

    -- Use 3 columns
    return M.MAX_COLUMNS
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
function M.calculate_content_height(metadata)
    -- Build temporary radio configs to calculate height
    local radio_configs = {
        { values = metadata.language.values },
        { values = metadata.bootVersion.values },
        { values = metadata.packaging.values },
        { values = metadata.javaVersion.values },
        { values = metadata.type.values },
        { values = metadata.configurationFileFormat.values },
    }

    local available_height = M.calculate_available_radios_height()
    local columns = M.determine_columns(radio_configs, available_height)
    local radio_section_height = M.calculate_radio_section_height(radio_configs, columns)
    local inputs_height = M.INPUT_COUNT * M.INPUT_HEIGHT

    return radio_section_height + inputs_height
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
