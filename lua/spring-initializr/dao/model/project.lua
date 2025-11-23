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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Project model representing a Spring Boot project configuration
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local FIELD_DELIMITER = "|"
local DEPENDENCY_SEPARATOR = ","

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}
M.__index = M

----------------------------------------------------------------------------
--
-- Creates a new Project instance.
--
-- @param  selections   table  Table containing all project selections
-- @param  dependencies table  List of Dependency instances
--
-- @return Project             New Project instance
--
----------------------------------------------------------------------------
function M.new(selections, dependencies)
    return setmetatable({
        project_type = selections.project_type or "",
        language = selections.language or "",
        boot_version = selections.boot_version or "",
        groupId = selections.groupId or "",
        artifactId = selections.artifactId or "",
        name = selections.name or "",
        description = selections.description or "",
        packageName = selections.packageName or "",
        packaging = selections.packaging or "",
        java_version = selections.java_version or "",
        configurationFileFormat = selections.configurationFileFormat or "properties",
        dependencies = dependencies or {},
    }, M)
end

----------------------------------------------------------------------------
--
-- Formats this project as a file line.
--
-- @return string  Formatted line for file storage
--
----------------------------------------------------------------------------
function M:format_for_file_line()
    local dep_ids = {}
    for _, dep in ipairs(self.dependencies) do
        table.insert(dep_ids, dep.id)
    end

    local fields = {
        self.project_type,
        self.language,
        self.boot_version,
        self.groupId,
        self.artifactId,
        self.name,
        self.description,
        self.packageName,
        self.packaging,
        self.java_version,
        self.configurationFileFormat,
        table.concat(dep_ids, DEPENDENCY_SEPARATOR),
    }

    return table.concat(fields, FIELD_DELIMITER)
end

----------------------------------------------------------------------------
--
-- Parses a project from a file line (static method).
--
-- @param  line  string       File line to parse
--
-- @return Project|nil        Parsed project or nil on error
-- @return string|nil         Error message if parsing failed
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

    if #fields < 12 then
        return nil, "Invalid project format"
    end

    local selections = {
        project_type = fields[1],
        language = fields[2],
        boot_version = fields[3],
        groupId = fields[4],
        artifactId = fields[5],
        name = fields[6],
        description = fields[7],
        packageName = fields[8],
        packaging = fields[9],
        java_version = fields[10],
        configurationFileFormat = fields[11],
    }

    local dependency_ids = {}
    if fields[12] and fields[12] ~= "" then
        for id in fields[12]:gmatch("[^" .. DEPENDENCY_SEPARATOR .. "]+") do
            table.insert(dependency_ids, id)
        end
    end

    return M.new(selections, dependency_ids)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
