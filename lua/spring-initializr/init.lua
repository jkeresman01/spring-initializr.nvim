local ui = require("spring-initializr.ui")
local telescope = require("spring-initializr.telescope")
local Job = require("plenary.job")

local M = {}

function M.register()
    vim.api.nvim_create_user_command("SpringSetupUI", function()
        ui.setup_ui()
    end, {
        desc = "Open Spring Initializer UI",
    })

    vim.api.nvim_create_user_command("SpringPickDependencies", function()
        telescope.pick_dependencies()
    end, {
        desc = "Pick Spring Boot dependencies via Telescope",
    })

    vim.api.nvim_create_user_command("SpringGenerateProject", function()
        M.generate_project()
    end, {
        desc = "Download and extract Spring Boot project to CWD",
    })
end

function M.generate_project()
    local selections = ui.state.selections
    local deps = table.concat(telescope.selected_dependencies, ",")
    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"

    local query = vim.fn.json_encode({
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
        dependencies = deps,
    })

    local curl_args = {
        "-s",
        "-X",
        "POST",
        "-H",
        "Content-Type: application/json",
        "-d",
        query,
        "https://start.spring.io/starter.zip",
        "-o",
        zip_path,
    }

    Job:new({
        command = "curl",
        args = curl_args,
        on_exit = function()
            Job:new({
                command = "unzip",
                args = { zip_path, "-d", cwd },
                on_exit = function()
                    vim.notify("Spring Boot project created in " .. cwd, vim.log.levels.INFO)
                end,
            }):start()
        end,
    }):start()
end

return M
