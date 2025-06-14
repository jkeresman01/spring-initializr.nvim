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
    local deps =
        table.concat(require("spring-initializr.telescope").selected_dependencies or {}, ",")

    local params = {
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
    }

    local function urlencode(str)
        str = tostring(str)
        return str:gsub("([^%w%-_%.%~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
    end

    local query = {}
    for k, v in pairs(params) do
        table.insert(query, urlencode(k) .. "=" .. urlencode(v))
    end

    local full_url = "https://start.spring.io/starter.zip?" .. table.concat(query, "&")
    local cwd = vim.fn.getcwd()
    local zip_path = cwd .. "/spring-init.zip"

    vim.notify("Downloading Spring project from:\n" .. full_url)

    Job:new({
        command = "curl",
        args = { "-L", full_url, "-o", zip_path },
        on_exit = function(j, return_val)
            if return_val ~= 0 then
                vim.schedule(function()
                    vim.notify("Download failed", vim.log.levels.ERROR)
                end)
                return
            end

            vim.schedule(function()
                Job:new({
                    command = "unzip",
                    args = { "-o", zip_path, "-d", cwd },
                    on_exit = function()
                        os.remove(zip_path)
                        vim.schedule(function()
                            ui.close()
                            vim.notify(
                                "Spring Boot project created in " .. cwd,
                                vim.log.levels.INFO
                            )
                        end)
                    end,
                }):start()
            end)
        end,
    }):start()
end

return M
