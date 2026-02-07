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
-- UI component for displaying health check results in a floating window.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local icons = require("spring-initializr.ui.icons.icons")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local PADDING = "  "
local TITLE_TEXT = "Spring Initializr Health Check"
local FAIL_ICON = "✗ "
local STATUS_ALL_PASSED = "Status: All checks passed "
local STATUS_ISSUES_FMT = "Status: %d issue(s) found ✗"
local SEPARATOR_CHAR = "━"
local HIGHLIGHT_NS = "SpringInitializrHealth"
local WINDOW_TITLE = " Health Check "
local WIN_HIGHLIGHT = "Normal:NormalFloat,FloatBorder:FloatBorder"
local FLOAT_SIZE_PERCENT = 0.8
local WIDTH_PADDING = 2

local HL_OK = "DiagnosticOk"
local HL_ERROR = "DiagnosticError"
local HL_TITLE = "Title"
local HL_COMMENT = "Comment"

----------------------------------------------------------------------------
--
-- Formats a single health check result into a display line.
--
-- @param  result       table   { label, ok, detail }
-- @param  checked_icon string  Icon for passed checks
--
-- @return table  { text, hl }
--
----------------------------------------------------------------------------
local function format_check_line(result, checked_icon)
    if result.ok then
        return {
            text = PADDING .. checked_icon .. " " .. result.label .. ": " .. result.detail,
            hl = HL_OK,
        }
    end
    return {
        text = PADDING .. FAIL_ICON .. result.label .. ": " .. result.detail,
        hl = HL_ERROR,
    }
end

----------------------------------------------------------------------------
--
-- Formats the status summary line.
--
-- @param  fail_count   number  Number of failed checks
-- @param  checked_icon string  Icon for passed state
--
-- @return table  { text, hl }
--
----------------------------------------------------------------------------
local function format_status_line(fail_count, checked_icon)
    if fail_count == 0 then
        return {
            text = PADDING .. STATUS_ALL_PASSED .. checked_icon,
            hl = HL_OK,
        }
    end
    return {
        text = string.format(PADDING .. STATUS_ISSUES_FMT, fail_count),
        hl = HL_ERROR,
    }
end

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
-- Assembles the final display lines from title, checks, and status.
--
-- @param  title       table   Title line { text, hl }
-- @param  check_lines table   Array of check result lines
-- @param  status_line table   Status summary line { text, hl }
-- @param  separator   string  Separator text
--
-- @return table  Array of { text, hl } tables
--
----------------------------------------------------------------------------
local function assemble_lines(title, check_lines, status_line, separator)
    local lines = {}
    table.insert(lines, title)
    table.insert(lines, { text = separator, hl = HL_COMMENT })
    table.insert(lines, { text = "", hl = nil })

    for _, line in ipairs(check_lines) do
        table.insert(lines, line)
    end

    table.insert(lines, { text = "", hl = nil })
    table.insert(lines, { text = separator, hl = HL_COMMENT })
    table.insert(lines, status_line)
    table.insert(lines, { text = "", hl = nil })

    return lines
end

----------------------------------------------------------------------------
--
-- Formats health check results into display lines.
--
-- @param  results     table   Array of { label, ok, detail } tables
-- @param  fail_count  number  Number of failed checks
--
-- @return table  Array of { text, hl } tables for each line
--
----------------------------------------------------------------------------
function M.format_results(results, fail_count)
    local checked = icons.get_dependency_checked()
    local title = { text = PADDING .. TITLE_TEXT, hl = HL_TITLE }

    local check_lines = {}
    for _, r in ipairs(results) do
        table.insert(check_lines, format_check_line(r, checked))
    end

    local status_line = format_status_line(fail_count, checked)

    local all_content = { title, status_line }
    for _, line in ipairs(check_lines) do
        table.insert(all_content, line)
    end
    local max_width = calculate_max_width(all_content)

    local separator = build_separator(max_width)

    return assemble_lines(title, check_lines, status_line, separator)
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
local function create_health_buffer(text_lines, formatted_lines)
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
-- Displays health check results in a transparent floating window.
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

    local buf = create_health_buffer(text_lines, formatted_lines)
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
