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
-- Icon definitions for the Spring Initializr UI.
-- Supports Nerd Fonts with ASCII fallbacks.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local config = require("spring-initializr.config.config")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Nerd Font Icons
-- Reference: https://www.nerdfonts.com/cheat-sheet
----------------------------------------------------------------------------
local nerd_icons = {
    -- Section icons
    sections = {
        project_type = "󰉋",
        language = "󰗀",
        spring_boot = "",
        packaging = "󰏗",
        java_version = "",
        config_format = "󰒓",
        dependencies = "󰐱",
        add_dependencies = "󰭎",
    },

    -- Radio button indicators
    radio = {
        selected = "◉",
        unselected = "○",
    },

    -- Dependency card indicators
    dependency = {
        checked = "󰄴",
        package = "󰏗",
    },

    -- Input field icons
    inputs = {
        group = "󰉋",
        artifact = "󰆧",
        name = "󰓹",
        description = "󰈙",
        package_name = "󰏖",
    },

    -- Action icons
    actions = {
        generate = "󰇚",
        reset = "󰑓",
        close = "󰅖",
    },
}

----------------------------------------------------------------------------
-- ASCII Fallback Icons
----------------------------------------------------------------------------
local ascii_icons = {
    -- Section icons
    sections = {
        project_type = "⊛",
        language = "</>",
        spring_boot = "❀",
        packaging = "◫",
        java_version = "☕",
        config_format = "⚙",
        dependencies = "◈",
        add_dependencies = "⊕",
    },

    -- Radio button indicators
    radio = {
        selected = "(x)",
        unselected = "( )",
    },

    -- Dependency card indicators
    dependency = {
        checked = "[✓]",
        package = "◆",
    },

    -- Input field icons
    inputs = {
        group = "▸",
        artifact = "▸",
        name = "▸",
        description = "▸",
        package_name = "▸",
    },

    -- Action icons
    actions = {
        generate = "↓",
        reset = "↺",
        close = "×",
    },
}

----------------------------------------------------------------------------
--
-- Gets the appropriate icon set based on configuration.
--
-- @return table  Icon set (nerd or ascii)
--
----------------------------------------------------------------------------
local function get_icon_set()
    if config.get_use_nerd_fonts() then
        return nerd_icons
    end
    return ascii_icons
end

----------------------------------------------------------------------------
--
-- Gets a section icon by section name.
--
-- @param  section_key  string  Key for the section (e.g., "project_type")
--
-- @return string               Icon string
--
----------------------------------------------------------------------------
function M.get_section_icon(section_key)
    local icons = get_icon_set()
    return icons.sections[section_key] or ""
end

----------------------------------------------------------------------------
--
-- Gets the selected radio indicator.
--
-- @return string  Selected indicator
--
----------------------------------------------------------------------------
function M.get_radio_selected()
    local icons = get_icon_set()
    return icons.radio.selected
end

----------------------------------------------------------------------------
--
-- Gets the unselected radio indicator.
--
-- @return string  Unselected indicator
--
----------------------------------------------------------------------------
function M.get_radio_unselected()
    local icons = get_icon_set()
    return icons.radio.unselected
end

----------------------------------------------------------------------------
--
-- Gets the checked dependency indicator.
--
-- @return string  Checked indicator
--
----------------------------------------------------------------------------
function M.get_dependency_checked()
    local icons = get_icon_set()
    return icons.dependency.checked
end

----------------------------------------------------------------------------
--
-- Gets the package icon for dependencies.
--
-- @return string  Package icon
--
----------------------------------------------------------------------------
function M.get_dependency_package()
    local icons = get_icon_set()
    return icons.dependency.package
end

----------------------------------------------------------------------------
--
-- Gets an input field icon by field name.
--
-- @param  field_key  string  Key for the field (e.g., "group")
--
-- @return string             Icon string
--
----------------------------------------------------------------------------
function M.get_input_icon(field_key)
    local icons = get_icon_set()
    return icons.inputs[field_key] or ""
end

----------------------------------------------------------------------------
--
-- Gets an action icon by action name.
--
-- @param  action_key  string  Key for the action (e.g., "generate")
--
-- @return string              Icon string
--
----------------------------------------------------------------------------
function M.get_action_icon(action_key)
    local icons = get_icon_set()
    return icons.actions[action_key] or ""
end

----------------------------------------------------------------------------
--
-- Maps section titles to their icon keys.
--
----------------------------------------------------------------------------
local SECTION_TITLE_MAP = {
    ["Project Type"] = "project_type",
    ["Language"] = "language",
    ["Spring Boot Version"] = "spring_boot",
    ["Packaging"] = "packaging",
    ["Java Version"] = "java_version",
    ["Config Format"] = "config_format",
    ["Selected Dependencies"] = "dependencies",
    ["Add Dependencies (Telescope)"] = "add_dependencies",
}

----------------------------------------------------------------------------
--
-- Gets a section icon by section title.
--
-- @param  title  string  Section title (e.g., "Project Type")
--
-- @return string         Icon string
--
----------------------------------------------------------------------------
function M.get_section_icon_by_title(title)
    local key = SECTION_TITLE_MAP[title]
    if key then
        return M.get_section_icon(key)
    end
    return ""
end

----------------------------------------------------------------------------
--
-- Formats a section title with its icon.
--
-- @param  title  string  Section title
--
-- @return string         Formatted title with icon
--
----------------------------------------------------------------------------
function M.format_section_title(title)
    local icon = M.get_section_icon_by_title(title)
    if icon ~= "" then
        return icon .. " " .. title
    end
    return title
end

----------------------------------------------------------------------------
--
-- Maps input titles to their icon keys.
--
----------------------------------------------------------------------------
local INPUT_TITLE_MAP = {
    ["Group"] = "group",
    ["Artifact"] = "artifact",
    ["Name"] = "name",
    ["Description"] = "description",
    ["Package Name"] = "package_name",
}

----------------------------------------------------------------------------
--
-- Formats an input title with its icon.
--
-- @param  title  string  Input title
--
-- @return string         Formatted title with icon
--
----------------------------------------------------------------------------
function M.format_input_title(title)
    local key = INPUT_TITLE_MAP[title]
    if key then
        local icon = M.get_input_icon(key)
        if icon ~= "" then
            return icon .. " " .. title
        end
    end
    return title
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
