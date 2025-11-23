----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═╝╚═╝     ╚═╝     ╚═╝
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
-- Dependency model representing a Spring Boot dependency
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local FIELD_DELIMITER = "|"

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}
M.__index = M

----------------------------------------------------------------------------
--
-- Creates a new Dependency instance.
--
-- @param  id           string  Dependency identifier
-- @param  name         string  Display name
-- @param  description  string  Dependency description
--
-- @return Dependency           New Dependency instance
--
----------------------------------------------------------------------------
function M.new(id, name, description)
    return setmetatable({
        id = id or "",
        name = name or "",
        description = description or "",
    }, M)
end

----------------------------------------------------------------------------
--
-- Formats this dependency as a file line.
--
-- @return string  Formatted line for file storage
--
----------------------------------------------------------------------------
function M:format_for_file_line()
    return string.format(
        "%s%s%s%s%s",
        self.id,
        FIELD_DELIMITER,
        self.name,
        FIELD_DELIMITER,
        self.description
    )
end

----------------------------------------------------------------------------
--
-- Parses a dependency from a file line (static method).
--
-- @param  line  string          File line to parse
--
-- @return Dependency|nil        Parsed dependency or nil on error
-- @return string|nil            Error message if parsing failed
--
----------------------------------------------------------------------------
function M.parse_from_file_line(line)
    if not line or line == "" then
        return nil, "Empty line"
    end

    local fields = {}
    for field in line:gmatch("[^" .. FIELD_DELIMITER .. "]+") do
        table.insert(fields, field)
    end

    if #fields < 3 then
        return nil, "Invalid dependency format"
    end

    return M.new(fields[1], fields[2], fields[3])
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
