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
-- Manages centralized keybinding registration for Spring Initializr UI
-- components.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local DEFAULT_OPTS = { noremap = true, nowait = true }

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Register a normal-mode keybinding on a component.
--
-- @param comp     table           Component to map key on
-- @param key      string          Keybinding to register
-- @param handler  function        Callback to execute
-- @param opts     table|nil       Mapping options
--
----------------------------------------------------------------------------
local function map(comp, key, handler, opts)
    log.fmt_trace("Registering keymap: %s", key)
    comp:map("n", key, handler, opts or DEFAULT_OPTS)
end

----------------------------------------------------------------------------
--
-- Register focus navigation keybindings on a component.
--
-- @param comp           table     Component to map keys on
-- @param focus_next_fn  function  Focus next callback
-- @param focus_prev_fn  function  Focus previous callback
--
----------------------------------------------------------------------------
function M.register_navigation_keys(comp, focus_next_fn, focus_prev_fn)
    map(comp, "<Tab>", focus_next_fn)
    map(comp, "<S-Tab>", focus_prev_fn)
end

----------------------------------------------------------------------------
--
-- Register the close keybinding on a component.
--
-- @param comp      table     Component to map key on
-- @param close_fn  function  Close callback
--
----------------------------------------------------------------------------
function M.register_close_key(comp, close_fn)
    map(comp, "q", close_fn)
end

----------------------------------------------------------------------------
--
-- Register the reset keybinding on a component.
--
-- @param comp      table     Component to map key on
-- @param reset_fn  function  Reset callback
--
----------------------------------------------------------------------------
function M.register_reset_key(comp, reset_fn)
    map(comp, "<C-r>", reset_fn)
end

----------------------------------------------------------------------------
--
-- Register the dependency picker keybinding on a component.
--
-- @param comp            table     Component to map key on
-- @param open_picker_fn  function  Picker callback
--
----------------------------------------------------------------------------
function M.register_picker_key(comp, open_picker_fn)
    map(comp, "<C-b>", open_picker_fn)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
