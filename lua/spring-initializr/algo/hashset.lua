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
-- Hash set implementation with pluggable key function.
-- Stores unique values by computed key; O(1) add/remove/lookup (amortized).
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
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
-- Create a hash set from a list.
--
-- @param  list   table   Array-like list of values
-- @param  opts   table   Passed to M.new (supports key_fn)
--
-- @return Set            New set with elements inserted
--
----------------------------------------------------------------------------
function M.from_list(list, opts)
    local s = M.new(opts)
    for _, v in ipairs(list or {}) do
        s:add(v)
    end
    return s
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
-- Toggle presence of a value.
--
-- @param  value  any     Value to toggle
-- @return bool           true if added, false if removed
--
----------------------------------------------------------------------------
function Set:toggle(value)
    if self:has(value) then
        self:remove(value)
        return false
    else
        self:add(value)
        return true
    end
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
-- Check membership by key (bypasses key_fn).
--
-- @param  key    any
-- @return bool
--
----------------------------------------------------------------------------
function Set:has_key(key)
    return self._store[key] ~= nil
end

----------------------------------------------------------------------------
--
-- Get stored value by key (bypasses key_fn).
--
-- @param  key    any
-- @return any|nil
--
----------------------------------------------------------------------------
function Set:get(key)
    return self._store[key]
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
--
-- Return values as a list (array).
--
-- @return table   Array of stored values
--
----------------------------------------------------------------------------
function Set:to_list()
    local out = {}
    for _, v in pairs(self._store) do
        table.insert(out, v)
    end
    return out
end

----------------------------------------------------------------------------
--
-- Iterator over stored values: for v in set:iter() do ... end
--
-- @return function, table, any    Generic-for iterator triple
--
----------------------------------------------------------------------------
function Set:iter()
    local tbl = self._store
    local next_fn, t, k = next, tbl, nil
    return function()
        k = next_fn(t, k)
        if k ~= nil then
            return tbl[k]
        end
    end
end

----------------------------------------------------------------------------
--
-- Set algebra: union (in place).
--
-- @param  other  Set
--
----------------------------------------------------------------------------
function Set:union(other)
    for v in other:iter() do
        self:add(v)
    end
end

----------------------------------------------------------------------------
--
-- Set algebra: intersection (returns new set).
--
-- @param  other  Set
-- @return Set
--
----------------------------------------------------------------------------
function Set:intersection(other)
    local out = M.new({ key_fn = self._key_fn })
    for v in self:iter() do
        if other:has(v) then
            out:add(v)
        end
    end
    return out
end

----------------------------------------------------------------------------
--
-- Set algebra: difference (returns new set).
--
-- @param  other  Set
-- @return Set
--
----------------------------------------------------------------------------
function Set:difference(other)
    local out = M.new({ key_fn = self._key_fn })
    for v in self:iter() do
        if not other:has(v) then
            out:add(v)
        end
    end
    return out
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
M.Set = Set

return M
