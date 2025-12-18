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
-- Provides utility functions for working with Neovim buffers.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local events = require("spring-initializr.events.events")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Extracts buffer number from a component.
--
-- @param  comp        table       Component object with `bufnr` or `popup.bufnr`
-- @return number|nil              Buffer number, or nil if not found
--
----------------------------------------------------------------------------
local function get_bufnr_from_component(comp)
    return comp.bufnr or (comp.popup and comp.popup.bufnr)
end

----------------------------------------------------------------------------
--
-- Collects buffer numbers from a list of components.
--
-- @param  components  table   List of component objects
-- @return table               List of buffer numbers
--
----------------------------------------------------------------------------
local function collect_buffers_from_components(components)
    local buffers = {}
    for _, comp in ipairs(components) do
        local bufnr = get_bufnr_from_component(comp)
        if bufnr then
            table.insert(buffers, bufnr)
        end
    end
    return buffers
end

----------------------------------------------------------------------------
--
-- Adds a buffer number to the list if it exists and is valid.
--
-- @param  buffers     table       List of buffer numbers to append to
-- @param  popup       table|nil   Popup object that may contain bufnr
--
----------------------------------------------------------------------------
local function add_popup_buffer(buffers, popup)
    if popup and popup.bufnr then
        table.insert(buffers, popup.bufnr)
    end
end

----------------------------------------------------------------------------
--
-- Creates an autocmd callback that closes the UI on buffer deletion.
--
-- @param  close_fn    function    Function to call when buffer is deleted
-- @return function                Autocmd callback function
--
----------------------------------------------------------------------------
local function create_close_callback(close_fn)
    return function()
        vim.schedule(close_fn)
    end
end

----------------------------------------------------------------------------
--
-- Sets up a BufDelete/BufWipeout autocmd for a specific buffer.
--
-- @param  bufnr       number      Buffer number to watch
-- @param  close_fn    function    Function to call when buffer is deleted
--
----------------------------------------------------------------------------
local function setup_buffer_autocmd(bufnr, close_fn)
    vim.api.nvim_create_autocmd({ events.BUF_DELETE, events.BUF_WIPEOUT }, {
        buffer = bufnr,
        once = true,
        callback = create_close_callback(close_fn),
    })
end

----------------------------------------------------------------------------
--
-- Sets up autocmds for multiple buffers.
--
-- @param  buffers     table       List of buffer numbers
-- @param  close_fn    function    Function to call when any buffer is deleted
--
----------------------------------------------------------------------------
local function setup_autocmds_for_buffers(buffers, close_fn)
    for _, bufnr in ipairs(buffers) do
        setup_buffer_autocmd(bufnr, close_fn)
    end
end

----------------------------------------------------------------------------
--
-- Collects all buffer numbers from components and optional popup.
--
-- @param  components  table       List of component objects
-- @param  popup       table|nil   Optional outer popup object
-- @return table                   List of all buffer numbers
--
----------------------------------------------------------------------------
function M.collect_all_buffers(components, popup)
    local buffers = collect_buffers_from_components(components)
    add_popup_buffer(buffers, popup)
    return buffers
end

----------------------------------------------------------------------------
--
-- Sets up autocmds to close UI when any component buffer is deleted.
-- When any buffer is closed via :q, :bd, :bw, etc., the close_fn is called.
--
-- @param  components  table       List of component objects
-- @param  popup       table|nil   Optional outer popup object
-- @param  close_fn    function    Function to call when any buffer is deleted
--
----------------------------------------------------------------------------
function M.setup_close_on_buffer_delete(components, popup, close_fn)
    local buffers = M.collect_all_buffers(components, popup)
    setup_autocmds_for_buffers(buffers, close_fn)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
