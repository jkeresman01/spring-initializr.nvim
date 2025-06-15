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

local Job = require("plenary.job")
local ui = require("spring-initializr.ui.init")
local msg = require("spring-initializr.utils.message")
local deps = require("spring-initializr.telescope.telescope")

local M = {}

local function urlencode(str)
    str = tostring(str)
    return str:gsub("([^%w%-_%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

local function encode_query(params)
    local query = {}
    for k, v in pairs(params) do
        table.insert(query, string.format("%s=%s", urlencode(k), urlencode(v)))
    end
    return table.concat(query, "&")
end

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
    return "https://start.spring.io/starter.zip?" .. encode_query(params)
end

local function notify_success(cwd)
    ui.close()
    msg.info("Spring Boot project created in " .. cwd)
end

local function unzip_file(zip_path, destination, on_done)
    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", destination },
        on_exit = function()
            os.remove(zip_path)
            vim.schedule(on_done)
        end,
    }):start()
end

local function download_zip(url, zip_path, cwd)
    Job:new({
        command = "curl",
        args = { "-L", url, "-o", zip_path },
        on_exit = function(_, return_val)
            if return_val ~= 0 then
                vim.schedule(function()
                    msg.error("Download failed")
                end)
                return
            end
            unzip_file(zip_path, cwd, function()
                notify_success(cwd)
            end)
        end,
    }):start()
end

function M.generate_project()
    local params = collect_params()
    local url = make_download_url(params)
    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"

    msg.info("Just a second, we are setting things up for you...")
    download_zip(url, zip_path, cwd)
end

return M
