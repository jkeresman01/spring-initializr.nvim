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
    local title = { text = PADDING .. "Spring Initializr Health Check", hl = "Title" }

    local check_lines = {}
    for _, r in ipairs(results) do
        if r.ok then
            table.insert(check_lines, {
                text = PADDING .. checked .. " " .. r.label .. ": " .. r.detail,
                hl = "DiagnosticOk",
            })
        else
            table.insert(check_lines, {
                text = PADDING .. "✗ " .. r.label .. ": " .. r.detail,
                hl = "DiagnosticError",
            })
        end
    end

    local status_line
    if fail_count == 0 then
        status_line = {
            text = PADDING .. "Status: All checks passed " .. checked,
            hl = "DiagnosticOk",
        }
    else
        status_line = {
            text = string.format(PADDING .. "Status: %d issue(s) found ✗", fail_count),
            hl = "DiagnosticError",
        }
    end

    -- Find max display width across all content lines
    local max_width = vim.api.nvim_strwidth(title.text)
    for _, line in ipairs(check_lines) do
        local w = vim.api.nvim_strwidth(line.text)
        if w > max_width then
            max_width = w
        end
    end
    local sw = vim.api.nvim_strwidth(status_line.text)
    if sw > max_width then
        max_width = sw
    end

    -- Generate separator to match content width
    local separator_width = max_width - #PADDING
    local separator_text = PADDING .. string.rep("━", separator_width)

    -- Assemble final lines
    local lines = {}
    table.insert(lines, title)
    table.insert(lines, { text = separator_text, hl = "Comment" })
    table.insert(lines, { text = "", hl = nil })

    for _, line in ipairs(check_lines) do
        table.insert(lines, line)
    end

    table.insert(lines, { text = "", hl = nil })
    table.insert(lines, { text = separator_text, hl = "Comment" })
    table.insert(lines, status_line)

    table.insert(lines, { text = "", hl = nil })

    return lines
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

    -- Add padding
    local width = max_width + 2
    local height = #text_lines

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, text_lines)

    -- Apply highlights
    local ns = vim.api.nvim_create_namespace("SpringInitializrHealth")
    for i, line in ipairs(formatted_lines) do
        if line.hl then
            vim.api.nvim_buf_add_highlight(buf, ns, line.hl, i - 1, 0, -1)
        end
    end

    -- Buffer options
    vim.bo[buf].modifiable = false
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].buflisted = false
    vim.bo[buf].bufhidden = "wipe"

    -- Window dimensions
    local win_width = math.min(width, math.floor(vim.o.columns * 0.8))
    local win_height = math.min(height, math.floor(vim.o.lines * 0.8))
    local row = math.floor((vim.o.lines - win_height) / 2)
    local col = math.floor((vim.o.columns - win_width) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
        title = " Health Check ",
        title_pos = "center",
    })

    -- Match the transparency style used by all other plugin floats
    vim.api.nvim_set_option_value(
        "winhighlight",
        "Normal:NormalFloat,FloatBorder:FloatBorder",
        { win = win }
    )

    -- Close keymaps
    local close = function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
    end

    vim.keymap.set("n", "q", close, { buffer = buf, nowait = true })
    vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
