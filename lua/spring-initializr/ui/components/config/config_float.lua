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
-- UI component for displaying plugin configuration in a floating window.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local PADDING = "  "
local SEPARATOR_CHAR = "━"
local HIGHLIGHT_NS = "SpringInitializrConfig"
local WINDOW_TITLE = " Configuration "
local WIN_HIGHLIGHT = "Normal:NormalFloat,FloatBorder:FloatBorder"
local FLOAT_SIZE_PERCENT = 0.8
local WIDTH_PADDING = 2

local HL_TITLE = "Title"
local HL_COMMENT = "Comment"

----------------------------------------------------------------------------
--
-- Finds the maximum display width across a list of { text } lines.
--
-- @param  lines  table  Array of { text, hl } tables
--
-- @return number        Maximum display width
--
----------------------------------------------------------------------------
local function calculate_max_width(lines)
    local max_width = 0
    for _, line in ipairs(lines) do
        local w = vim.api.nvim_strwidth(line.text)
        if w > max_width then
            max_width = w
        end
    end
    return max_width
end

----------------------------------------------------------------------------
--
-- Builds a separator text matching the given content width.
--
-- @param  max_width  number  Maximum content width
--
-- @return string             Separator text
--
----------------------------------------------------------------------------
local function build_separator(max_width)
    local separator_width = max_width - #PADDING
    return PADDING .. string.rep(SEPARATOR_CHAR, separator_width)
end

----------------------------------------------------------------------------
--
-- Formats a single section into display lines.
--
-- @param  section  table  { title, entries }
--                         Each entry: { label, value, default }
--
-- @return table  Array of { text, hl } tables
--
----------------------------------------------------------------------------
local function format_section_lines(section)
    local lines = {}
    table.insert(lines, { text = PADDING .. section.title .. ":", hl = HL_TITLE })
    for _, entry in ipairs(section.entries) do
        local text = string.format(
            "%s  %s: %s (default: %s)",
            PADDING,
            entry.label,
            tostring(entry.value),
            tostring(entry.default)
        )
        table.insert(lines, { text = text, hl = nil })
    end
    return lines
end

----------------------------------------------------------------------------
--
-- Assembles the final display lines from title, sections, and footer.
--
-- @param  title          table   Title line { text, hl }
-- @param  section_lines  table   Array of section line arrays
-- @param  separator      string  Separator text
--
-- @return table  Array of { text, hl } tables
--
----------------------------------------------------------------------------
local function assemble_lines(title, section_lines, separator)
    local lines = {}
    table.insert(lines, title)
    table.insert(lines, { text = separator, hl = HL_COMMENT })
    table.insert(lines, { text = "", hl = nil })

    for _, section in ipairs(section_lines) do
        for _, line in ipairs(section) do
            table.insert(lines, line)
        end
        table.insert(lines, { text = "", hl = nil })
    end

    table.insert(lines, { text = separator, hl = HL_COMMENT })
    table.insert(lines, { text = PADDING .. "Press q to close", hl = HL_COMMENT })
    table.insert(lines, { text = "", hl = nil })

    return lines
end

----------------------------------------------------------------------------
--
-- Formats configuration entries into display lines.
--
-- @param  sections  table  Array of { title, entries } tables
--                          Each entry: { label, value, default }
--
-- @return table  Array of { text, hl } tables
--
----------------------------------------------------------------------------
function M.format_config(sections)
    local title = { text = PADDING .. "Spring Initializr Configuration", hl = HL_TITLE }

    local section_lines = {}
    local all_content = { title }
    for _, section in ipairs(sections) do
        local formatted = format_section_lines(section)
        table.insert(section_lines, formatted)
        for _, line in ipairs(formatted) do
            table.insert(all_content, line)
        end
    end

    local max_width = calculate_max_width(all_content)
    local separator = build_separator(max_width)

    return assemble_lines(title, section_lines, separator)
end

----------------------------------------------------------------------------
--
-- Creates a scratch buffer with the given text and applies highlights.
--
-- @param  text_lines       table  Array of text strings
-- @param  formatted_lines  table  Array of { text, hl } tables
--
-- @return number  Buffer handle
--
----------------------------------------------------------------------------
local function create_config_buffer(text_lines, formatted_lines)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)

    local ns = vim.api.nvim_create_namespace(HIGHLIGHT_NS)
    for i, line in ipairs(formatted_lines) do
        if line.hl then
            vim.api.nvim_buf_add_highlight(buf, ns, line.hl, i - 1, 0, -1)
        end
    end

    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].buflisted = false
    vim.bo[buf].bufhidden = "wipe"

    return buf
end

----------------------------------------------------------------------------
--
-- Calculates centered window dimensions for the float.
--
-- @param  width   number  Content width
-- @param  height  number  Content height
--
-- @return number, number, number, number  win_width, win_height, row, col
--
----------------------------------------------------------------------------
local function calculate_window_dimensions(width, height)
    local win_width = math.min(width, math.floor(vim.o.columns * FLOAT_SIZE_PERCENT))
    local win_height = math.min(height, math.floor(vim.o.lines * FLOAT_SIZE_PERCENT))
    local row = math.floor((vim.o.lines - win_height) / 2)
    local col = math.floor((vim.o.columns - win_width) / 2)
    return win_width, win_height, row, col
end

----------------------------------------------------------------------------
--
-- Sets up close keymaps (q, Esc) for the floating window.
--
-- @param  buf  number  Buffer handle
-- @param  win  number  Window handle
--
----------------------------------------------------------------------------
local function setup_close_keymaps(buf, win)
    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
end

----------------------------------------------------------------------------
--
-- Displays configuration in a transparent floating window.
--
-- @param  formatted_lines  table  Array of { text, hl } tables
--
----------------------------------------------------------------------------
function M.show_float(formatted_lines)
    local text_lines = {}
    local max_width = 0
    for _, line in ipairs(formatted_lines) do
        table.insert(text_lines, line.text)
        local w = vim.api.nvim_strwidth(line.text)
        if w > max_width then
            max_width = w
        end
    end

    local width = max_width + WIDTH_PADDING
    local height = #text_lines

    local buf = create_config_buffer(text_lines, formatted_lines)
    local win_width, win_height, row, col = calculate_window_dimensions(width, height)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = WINDOW_TITLE,
        title_pos = "center",
    })

    vim.api.nvim_set_option_value("winhighlight", WIN_HIGHLIGHT, { win = win })

    setup_close_keymaps(buf, win)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
