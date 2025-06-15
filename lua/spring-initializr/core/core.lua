--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: core/core.lua
-- Author: Josip Keresman
local ui = require("spring-initializr.ui.init")
local msg = require("spring-initializr.utils.message")
local deps = require("spring-initializr.telescope.telescope")

local url_utils = require("spring-initializr.utils.url")
local http_utils = require("spring-initializr.utils.http")
local file_utils = require("spring-initializr.utils.file")

local M = {}

local SPRING_DOWNLOAD_URL = "https://start.spring.io/starter.zip"

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
    }
end

local function make_download_url(params)
    return SPRING_DOWNLOAD_URL .. "?" .. url_utils.encode_query(params)
end

local function notify_success(cwd)
    ui.close()
    msg.info("Spring Boot project created in " .. cwd)
end

function M.generate_project()
    local params = collect_params()
    local url = make_download_url(params)

    print("Download URL: " .. url)

    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"

    msg.info("Just a second, we are setting things up for you...")

    http_utils.download_file(url, zip_path, function()
        file_utils.unzip(zip_path, cwd, function()
            notify_success(cwd)
        end)
    end, function()
        msg.error("Download failed")
    end)
end

return M
