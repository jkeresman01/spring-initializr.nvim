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
-- Provides URL encoding and query string generation utilities.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- URL-encodes a string so it can be safely used in HTTP query parameters.
--
-- @param  str  string  String to encode
-- @return string       URL-encoded string
--
----------------------------------------------------------------------------
function M.urlencode(str)
    return tostring(str):gsub("([^%w%-_%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

----------------------------------------------------------------------------
--
-- Encodes a table of key-value pairs into a URL query string.
--
-- @param  params  table   Table of string keys and values
-- @return string          URL query string (e.g., "key1=value1&key2=value2")
--
----------------------------------------------------------------------------
function M.encode_query(params)
    local query = {}
    for k, v in pairs(params) do
        table.insert(query, string.format("%s=%s", M.urlencode(k), M.urlencode(v)))
    end
    return table.concat(query, "&")
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
