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
local file_utils = require("spring-initializr.utils.file_utils")
local Project = require("spring-initializr.dao.model.project")
local Dependency = require("spring-initializr.dao.model.dependency")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local PROJECT_FILE = "last_project.txt"
local DEPENDENCIES_FILE = "dependencies.txt"

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Saves a project to file.
--
-- @param  project   Project   Project instance to save
--
----------------------------------------------------------------------------
function M.save_project(project)
    -- Save project configuration
    local project_line = project:format_for_file_line()
    local project_path = file_utils.get_data_file_path(PROJECT_FILE)
    file_utils.write_file(project_path, project_line)

    -- Save dependencies
    if project.dependencies and #project.dependencies > 0 then
        local dep_lines = {}
        for _, dep in ipairs(project.dependencies) do
            table.insert(dep_lines, dep:format_for_file_line())
        end
        local deps_path = file_utils.get_data_file_path(DEPENDENCIES_FILE)
        file_utils.write_file(deps_path, table.concat(dep_lines, "\n"))
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
    local project_path = file_utils.get_data_file_path(PROJECT_FILE)

    if not file_utils.file_exists(project_path) then
        return nil
    end

    local content = file_utils.read_file(project_path)
    local project = Project.parse_from_file_line(content)

    local deps_path = file_utils.get_data_file_path(DEPENDENCIES_FILE)
    if file_utils.file_exists(deps_path) then
        local dep_content = file_utils.read_file(deps_path)
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
    local project_path = file_utils.get_data_file_path(PROJECT_FILE)
    return file_utils.file_exists(project_path)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
