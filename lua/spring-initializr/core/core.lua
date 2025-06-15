--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: core.lua
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

local function build_query(params)
    local query = {}
    for k, v in pairs(params) do
        table.insert(query, urlencode(k) .. "=" .. urlencode(v))
    end
    return table.concat(query, "&")
end

local function get_params()
    local selections = ui.state.selections
    local dependencies = table.concat(deps.selected_dependencies or {}, ",")

    return {
        type = selections.project_type,
        language = selections.language,
        bootVersion = selections.boot_version,
        groupId = selections.groupId,
        artifactId = selections.artifactId,
        name = selections.name,
        description = selections.description,
        packageName = selections.packageName,
        packaging = selections.packaging,
        javaVersion = selections.java_version,
        dependencies = dependencies,
    }
end

local function unzip_and_cleanup(zip_path, cwd)
    Job:new({
        command = "unzip",
        args = { "-o", zip_path, "-d", cwd },
        on_exit = function()
            os.remove(zip_path)
            vim.schedule(function()
                ui.close()
                msg.info("Spring Boot project created in " .. cwd)
            end)
        end,
    }):start()
end

local function download_project(url, zip_path, cwd)
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
            vim.schedule(function()
                unzip_and_cleanup(zip_path, cwd)
            end)
        end,
    }):start()
end

function M.generate_project()
    local params = get_params()
    local query = build_query(params)
    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"
    local url = "https://start.spring.io/starter.zip?" .. query

    msg.info("Just a second, we are setting things up for you...")
    download_project(url, zip_path, cwd)
end

return M
