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
-- File-based repository for persisting Spring Initializr project state
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local Path = require("plenary.path")
local Project = require("spring-initializr.dao.model.project")
local Dependency = require("spring-initializr.dao.model.dependency")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local DATA_DIR = vim.fn.stdpath("data") .. "/spring-initializr"
local PROJECT_FILE = "last_project.txt"
local DEPENDENCIES_FILE = "dependencies.txt"

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Ensures the data directory exists.
--
----------------------------------------------------------------------------
local function ensure_data_directory()
    local dir = Path:new(DATA_DIR)
    if not dir:exists() then
        dir:mkdir({ parents = true })
    end
end

----------------------------------------------------------------------------
--
-- Saves a project to file.
--
-- @param  project   Project   Project instance to save
--
----------------------------------------------------------------------------
function M.save_project(project)
    ensure_data_directory()

    -- Save project configuration
    local project_line = project:format_for_file_line()
    local project_file = Path:new(DATA_DIR .. "/" .. PROJECT_FILE)
    project_file:write(project_line, "w")

    -- Save dependencies
    if project.dependencies and #project.dependencies > 0 then
        local dep_lines = {}
        for _, dep in ipairs(project.dependencies) do
            table.insert(dep_lines, dep:format_for_file_line())
        end
        local deps_file = Path:new(DATA_DIR .. "/" .. DEPENDENCIES_FILE)
        deps_file:write(table.concat(dep_lines, "\n"), "w")
    end
end

----------------------------------------------------------------------------
--
-- Loads a project from file.
--
-- @return Project|nil        Loaded project or nil on error
--
----------------------------------------------------------------------------
function M.load_project()
    local project_file = Path:new(DATA_DIR .. "/" .. PROJECT_FILE)

    if not project_file:exists() then
        return nil
    end

    local content = project_file:read()
    local project = Project.parse_from_file_line(content)

    local deps_file = Path:new(DATA_DIR .. "/" .. DEPENDENCIES_FILE)
    if deps_file:exists() then
        local dep_content = deps_file:read()
        local dependencies = {}
        for line in dep_content:gmatch("[^\r\n]+") do
            local dep = Dependency.parse_from_file_line(line)
            if dep then
                table.insert(dependencies, dep)
            end
        end
        project.dependencies = dependencies
    end

    return project
end

----------------------------------------------------------------------------
--
-- Checks if a saved project exists.
--
-- @return boolean  True if project file exists
--
----------------------------------------------------------------------------
function M.has_saved_project()
    local file = Path:new(DATA_DIR .. "/" .. PROJECT_FILE)
    return file:exists()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
