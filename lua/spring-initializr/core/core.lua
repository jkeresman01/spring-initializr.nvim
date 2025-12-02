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
-- Generates a Spring Boot project using selections from UI and metadata.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local ui = require("spring-initializr.ui.init")
local deps = require("spring-initializr.telescope.telescope")
local message_utils = require("spring-initializr.utils.message_utils")
local log = require("spring-initializr.trace.log")
local url_utils = require("spring-initializr.utils.url_utils")
local http_utils = require("spring-initializr.utils.http_utils")
local file_utils = require("spring-initializr.utils.file_utils")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local SPRING_DOWNLOAD_URL = "https://start.spring.io/starter.zip"

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Collect all user selections into Spring Initializr params.
--
----------------------------------------------------------------------------
local function collect_params()
    local s = ui.state.selections
    return {
        type = s.project_type,
        language = s.language,
        bootVersion = s.boot_version,
        groupId = s.groupId,
        artifactId = s.artifactId,
        name = s.name,
        description = s.description,
        packageName = s.packageName,
        packaging = s.packaging,
        javaVersion = s.java_version,
        dependencies = table.concat(deps.selected_dependencies or {}, ","),
        configurationFileFormat = s.configurationFileFormat or "properties",
    }
end

----------------------------------------------------------------------------
--
-- Build the Spring Initializr ZIP download URL with query string.
--
----------------------------------------------------------------------------
local function make_download_url(params)
    return SPRING_DOWNLOAD_URL .. "?" .. url_utils.encode_query(params)
end

----------------------------------------------------------------------------
--
-- Notify success (single responsibility).
--
----------------------------------------------------------------------------
local function notify_success()
    ui.close()
    local cwd = vim.fn.getcwd()
    message_utils.show_info_message("Spring Boot project created in " .. cwd)
end

----------------------------------------------------------------------------
--
-- Extract the downloaded ZIP (single responsibility).
--
----------------------------------------------------------------------------
local function extract_zip_to_dest(zip_path, dest)
    file_utils.unzip(zip_path, dest, notify_success)
end

----------------------------------------------------------------------------
--
-- Handle download error (single responsibility).
--
----------------------------------------------------------------------------
local function on_download_error()
    message_utils.show_error_message("Download failed")
end

----------------------------------------------------------------------------
--
-- Handle download completion by triggering extraction (single responsibility).
--
----------------------------------------------------------------------------
local function on_download_complete(zip_path, dest)
    extract_zip_to_dest(zip_path, dest)
end

----------------------------------------------------------------------------
--
-- Start the download (single responsibility).
--
----------------------------------------------------------------------------
local function start_download(url, zip_path, dest)
    http_utils.download_file(url, zip_path, function()
        on_download_complete(zip_path, dest)
    end, on_download_error)
end

----------------------------------------------------------------------------
--
-- Generate a Spring Boot project from current UI selections.
--
----------------------------------------------------------------------------
function M.generate_project()
    log.info("Starting project generation")

    local params = collect_params()
    log.debug("Project parameters:", params)

    local url = make_download_url(params)
    log.fmt_debug("Download URL: %s", url:sub(1, 100) .. "...")

    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"

    log.fmt_info("Downloading project to: %s", zip_path)
    message_utils.show_info_message("Just a second, we are setting things up for you...")

    start_download(url, zip_path, cwd)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
