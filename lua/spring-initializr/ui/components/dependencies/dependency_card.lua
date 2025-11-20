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
-- Card component for displaying individual dependencies with visual styling.
-- Dynamically adapts to the actual window width.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local CHECKBOX_CHECKED = "[x]"

----------------------------------------------------------------------------
--
-- Truncate text to fit within specified length.
--
-- @param  text        string  Text to truncate
-- @param  max_length  number  Maximum length
--
-- @return string              Truncated text with ellipsis if needed
--
----------------------------------------------------------------------------
local function truncate_text(text, max_length)
    if #text <= max_length then
        return text
    end
    return text:sub(1, max_length - 3) .. "..."
end

----------------------------------------------------------------------------
--
-- Format the dependency ID as a tag.
--
-- @param  id  string  Dependency ID
--
-- @return string      Formatted tag
--
----------------------------------------------------------------------------
local function format_tag(id)
    local tag_content = id:upper():sub(1, 8)
    return "[" .. tag_content .. "]"
end

----------------------------------------------------------------------------
--
-- Create the header line with checkbox, name, and ID tag.
--
-- @param  name           string  Dependency name
-- @param  id             string  Dependency ID
-- @param  content_width  number  Available width for content
--
-- @return string                 Formatted header line
--
----------------------------------------------------------------------------
local function create_header_line(name, id, content_width)
    local tag = format_tag(id)
    local checkbox_width = vim.fn.strwidth(CHECKBOX_CHECKED)
    local tag_width = vim.fn.strwidth(tag)
    local max_name_length = content_width - checkbox_width - tag_width - 2
    max_name_length = math.max(10, max_name_length)
    local truncated_name = truncate_text(name, max_name_length)
    local name_width = vim.fn.strwidth(truncated_name)
    local used_width = checkbox_width + 1 + name_width + tag_width
    local padding_length = content_width - used_width
    local padding = string.rep(" ", math.max(0, padding_length))
    return CHECKBOX_CHECKED .. " " .. truncated_name .. padding .. tag
end

----------------------------------------------------------------------------
--
-- Create the description line.
--
-- @param  description    string  Dependency description
-- @param  content_width  number  Available width for content
--
-- @return string                 Formatted description line
--
----------------------------------------------------------------------------
local function create_description_line(description, content_width)
    local max_desc_length = content_width - 2
    max_desc_length = math.max(10, max_desc_length) -- Minimum 10 chars
    local truncated_desc = truncate_text(description or "No description", max_desc_length)
    return "  " .. truncated_desc
end

----------------------------------------------------------------------------
--
-- Generate the lines for a dependency card.
--
-- @param  dependency  table   Dependency object with name, id, and description
-- @param  card_width  number  Total width of the card including borders
--
-- @return table               List of lines representing the card
--
----------------------------------------------------------------------------
function M.create_card_lines(dependency, card_width)
    local content_width = card_width - 2
    local top_border = "┌" .. string.rep("─", content_width) .. "┐"
    local bottom_border = "└" .. string.rep("─", content_width) .. "┘"

    local header = create_header_line(dependency.name, dependency.id, content_width)
    local description = create_description_line(dependency.description, content_width)

    local function pad_line(line)
        local current_width = vim.fn.strwidth(line)
        local padding_needed = content_width - current_width
        return "│" .. line .. string.rep(" ", math.max(0, padding_needed)) .. "│"
    end

    return {
        top_border,
        pad_line(header),
        pad_line(description),
        bottom_border,
    }
end

----------------------------------------------------------------------------
--
-- Generate all lines for multiple dependency cards.
--
-- @param  dependencies  table   List of dependency objects
-- @param  panel_width   number  Width of the display panel
--
-- @return table                 List of all lines for all cards
--
----------------------------------------------------------------------------
function M.create_all_cards(dependencies, panel_width)
    local all_lines = {}
    panel_width = panel_width or 40 -- Fallback default

    for _, dep in ipairs(dependencies) do
        local card_lines = M.create_card_lines(dep, panel_width)
        for _, line in ipairs(card_lines) do
            table.insert(all_lines, line)
        end
    end

    return all_lines
end

----------------------------------------------------------------------------
--
-- Apply syntax highlighting to a buffer with dependency cards.
-- Uses existing FloatBorder highlight group for consistency.
--
-- @param  bufnr         number  Buffer number to apply highlights
-- @param  line_start    number  Starting line number (0-indexed)
-- @param  num_deps      number  Number of dependencies
--
----------------------------------------------------------------------------
function M.apply_highlights(bufnr, line_start, num_deps)
    local namespace = vim.api.nvim_create_namespace("spring_dep_cards")
    vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
    for i = 0, num_deps - 1 do
        local card_start = line_start + (i * 4)
        for line_offset = 0, 3 do
            vim.api.nvim_buf_add_highlight(
                bufnr,
                namespace,
                "FloatBorder",
                card_start + line_offset,
                0,
                1
            )
            local line = vim.api.nvim_buf_get_lines(
                bufnr,
                card_start + line_offset,
                card_start + line_offset + 1,
                false
            )[1]
            if line then
                local line_width = vim.fn.strwidth(line)
                vim.api.nvim_buf_add_highlight(
                    bufnr,
                    namespace,
                    "FloatBorder",
                    card_start + line_offset,
                    line_width - 1,
                    -1
                )
            end
        end
    end
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
