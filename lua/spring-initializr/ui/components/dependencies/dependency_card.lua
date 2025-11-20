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
local MIN_NAME_LENGTH = 10
local MIN_DESC_LENGTH = 10
local TAG_MAX_LENGTH = 8
local CARD_BORDER_WIDTH = 2
local DESC_INDENT = 2

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
    local tag_content = id:upper():sub(1, TAG_MAX_LENGTH)
    return "[" .. tag_content .. "]"
end

----------------------------------------------------------------------------
--
-- Calculate the maximum width available for the dependency name.
--
-- @param  content_width  number  Total available content width
-- @param  tag_width      number  Width of the ID tag
--
-- @return number                 Maximum width for name
--
----------------------------------------------------------------------------
local function calculate_max_name_width(content_width, tag_width)
    local checkbox_width = vim.fn.strwidth(CHECKBOX_CHECKED)
    local spacing = 2 -- Space after checkbox and before tag
    local available = content_width - checkbox_width - tag_width - spacing
    return math.max(MIN_NAME_LENGTH, available)
end

----------------------------------------------------------------------------
--
-- Generate padding string to fill remaining space.
--
-- @param  used_width     number  Width already used by content
-- @param  content_width  number  Total available content width
--
-- @return string                 Padding string
--
----------------------------------------------------------------------------
local function create_padding(used_width, content_width)
    local padding_length = content_width - used_width
    return string.rep(" ", math.max(0, padding_length))
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
    local tag_width = vim.fn.strwidth(tag)
    local max_name_length = calculate_max_name_width(content_width, tag_width)

    local truncated_name = truncate_text(name, max_name_length)
    local name_width = vim.fn.strwidth(truncated_name)

    local checkbox_width = vim.fn.strwidth(CHECKBOX_CHECKED)
    local used_width = checkbox_width + 1 + name_width + tag_width
    local padding = create_padding(used_width, content_width)

    return CHECKBOX_CHECKED .. " " .. truncated_name .. padding .. tag
end

----------------------------------------------------------------------------
--
-- Calculate the maximum width available for description text.
--
-- @param  content_width  number  Total available content width
--
-- @return number                 Maximum width for description
--
----------------------------------------------------------------------------
local function calculate_max_desc_width(content_width)
    local available = content_width - DESC_INDENT
    return math.max(MIN_DESC_LENGTH, available)
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
    local max_desc_length = calculate_max_desc_width(content_width)
    local text = description or "No description"
    local truncated_desc = truncate_text(text, max_desc_length)
    local indent = string.rep(" ", DESC_INDENT)
    return indent .. truncated_desc
end

----------------------------------------------------------------------------
--
-- Create a border line with specified character.
--
-- @param  char           string  Border character (e.g., "─")
-- @param  left_corner    string  Left corner character
-- @param  right_corner   string  Right corner character
-- @param  content_width  number  Width of content area
--
-- @return string                 Complete border line
--
----------------------------------------------------------------------------
local function create_border_line(char, left_corner, right_corner, content_width)
    return left_corner .. string.rep(char, content_width) .. right_corner
end

----------------------------------------------------------------------------
--
-- Create top border line for card.
--
-- @param  content_width  number  Width of content area
--
-- @return string                 Top border line
--
----------------------------------------------------------------------------
local function create_top_border(content_width)
    return create_border_line("─", "┌", "┐", content_width)
end

----------------------------------------------------------------------------
--
-- Create bottom border line for card.
--
-- @param  content_width  number  Width of content area
--
-- @return string                 Bottom border line
--
----------------------------------------------------------------------------
local function create_bottom_border(content_width)
    return create_border_line("─", "└", "┘", content_width)
end

----------------------------------------------------------------------------
--
-- Wrap a content line with vertical borders and padding.
--
-- @param  line           string  Content line to wrap
-- @param  content_width  number  Total width for content
--
-- @return string                 Line wrapped with borders
--
----------------------------------------------------------------------------
local function wrap_line_with_borders(line, content_width)
    local current_width = vim.fn.strwidth(line)
    local padding_needed = content_width - current_width
    local padding = string.rep(" ", math.max(0, padding_needed))
    return "│" .. line .. padding .. "│"
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
    local content_width = card_width - CARD_BORDER_WIDTH

    local top_border = create_top_border(content_width)
    local bottom_border = create_bottom_border(content_width)
    local header = create_header_line(dependency.name, dependency.id, content_width)
    local description = create_description_line(dependency.description, content_width)

    return {
        top_border,
        wrap_line_with_borders(header, content_width),
        wrap_line_with_borders(description, content_width),
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
-- Calculate the starting line number for a card.
--
-- @param  line_start  number  Starting line for all cards
-- @param  card_index  number  Index of current card (0-based)
--
-- @return number              Starting line for this card
--
----------------------------------------------------------------------------
local function get_card_start_line(line_start, card_index)
    local lines_per_card = 4
    return line_start + (card_index * lines_per_card)
end

----------------------------------------------------------------------------
--
-- Highlight the left border character of a line.
--
-- @param  bufnr      number  Buffer number
-- @param  namespace  number  Highlight namespace
-- @param  line_num   number  Line number (0-indexed)
--
----------------------------------------------------------------------------
local function highlight_left_border(bufnr, namespace, line_num)
    vim.api.nvim_buf_add_highlight(bufnr, namespace, "FloatBorder", line_num, 0, 1)
end

----------------------------------------------------------------------------
--
-- Highlight the right border character of a line.
--
-- @param  bufnr      number  Buffer number
-- @param  namespace  number  Highlight namespace
-- @param  line_num   number  Line number (0-indexed)
--
----------------------------------------------------------------------------
local function highlight_right_border(bufnr, namespace, line_num)
    local line = vim.api.nvim_buf_get_lines(bufnr, line_num, line_num + 1, false)[1]
    if not line then
        return
    end

    local line_width = vim.fn.strwidth(line)
    vim.api.nvim_buf_add_highlight(bufnr, namespace, "FloatBorder", line_num, line_width - 1, -1)
end

----------------------------------------------------------------------------
--
-- Highlight both borders of a single line.
--
-- @param  bufnr      number  Buffer number
-- @param  namespace  number  Highlight namespace
-- @param  line_num   number  Line number (0-indexed)
--
----------------------------------------------------------------------------
local function highlight_line_borders(bufnr, namespace, line_num)
    highlight_left_border(bufnr, namespace, line_num)
    highlight_right_border(bufnr, namespace, line_num)
end

----------------------------------------------------------------------------
--
-- Highlight all lines of a single dependency card.
--
-- @param  bufnr       number  Buffer number
-- @param  namespace   number  Highlight namespace
-- @param  card_start  number  Starting line of card (0-indexed)
--
----------------------------------------------------------------------------
local function highlight_card(bufnr, namespace, card_start)
    local lines_per_card = 4
    for line_offset = 0, lines_per_card - 1 do
        local line_num = card_start + line_offset
        highlight_line_borders(bufnr, namespace, line_num)
    end
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
        local card_start = get_card_start_line(line_start, i)
        highlight_card(bufnr, namespace, card_start)
    end
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
