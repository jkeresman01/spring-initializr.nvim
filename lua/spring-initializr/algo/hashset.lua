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
-- Hash set implementation with pluggable key function.
-- Stores unique values by computed key; O(1) add/remove/lookup (amortized).
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Set "class"
----------------------------------------------------------------------------
local Set = {}
Set.__index = Set

----------------------------------------------------------------------------
--
-- Create a new hash set.
--
-- @param  opts   table   { key_fn = function(value) -> hashable_key }
--                         key_fn must return a hashable key (string/number/boolean).
--                         Defaults to identity for primitives.
--
-- @return Set            New set instance
--
----------------------------------------------------------------------------
function M.new(opts)
    opts = opts or {}
    local key_fn = opts.key_fn or function(v)
        return v
    end

    local self = setmetatable({
        _store = {},
        _size = 0,
        _key_fn = key_fn,
    }, Set)

    return self
end

----------------------------------------------------------------------------
--
-- Add a value if absent.
--
-- @param  value  any     Value to insert
-- @return bool           true if inserted, false if already present
--
----------------------------------------------------------------------------
function Set:add(value)
    local k = self._key_fn(value)
    if self._store[k] == nil then
        self._store[k] = value
        self._size = self._size + 1
        return true
    end
    return false
end

----------------------------------------------------------------------------
--
-- Remove a value if present.
--
-- @param  value  any     Value to remove
-- @return bool           true if removed, false if absent
--
----------------------------------------------------------------------------
function Set:remove(value)
    local k = self._key_fn(value)
    if self._store[k] ~= nil then
        self._store[k] = nil
        self._size = self._size - 1
        return true
    end
    return false
end

----------------------------------------------------------------------------
--
-- Check membership by value.
--
-- @param  value  any
-- @return bool
--
----------------------------------------------------------------------------
function Set:has(value)
    local k = self._key_fn(value)
    return self._store[k] ~= nil
end

----------------------------------------------------------------------------
--
-- Number of elements.
--
-- @return integer
--
----------------------------------------------------------------------------
function Set:size()
    return self._size
end

----------------------------------------------------------------------------
--
-- Is the set empty.
--
-- @return bool
--
----------------------------------------------------------------------------
function Set:is_empty()
    return self._size == 0
end

----------------------------------------------------------------------------
--
-- Remove all elements.
--
----------------------------------------------------------------------------
function Set:clear()
    self._store = {}
    self._size = 0
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
M.Set = Set

return M
