-- lua/spring_initializer/telescope.lua

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local metadata_loader = require("spring-initializr.metadata")

local M = {}

M.selected_dependencies = {}

--- Show Telescope picker with Spring Boot dependencies grouped by category
M.pick_dependencies = function(opts)
    opts = opts or {}

    metadata_loader.fetch_metadata(function(data, err)
        if err then
            vim.notify("Failed to load Spring metadata: " .. err, vim.log.levels.ERROR)
            return
        end

        local dep_values = data.dependencies.values or {}
        local items = {}

        for _, group in ipairs(dep_values) do
            for _, dep in ipairs(group.values) do
                local label = string.format("[%s] %s", group.name, dep.name)
                table.insert(items, { label = label, id = dep.id })
            end
        end

        pickers
            .new(opts, {
                prompt_title = "Spring Dependencies",
                finder = finders.new_table({
                    results = items,
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry.label,
                            ordinal = entry.label,
                        }
                    end,
                }),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, map)
                    actions.select_default:replace(function()
                        local selection = action_state.get_selected_entry()
                        table.insert(M.selected_dependencies, selection.value.id)
                        vim.notify("Selected Dependency: " .. selection.value.id)
                        actions.close(prompt_bufnr)
                    end)
                    return true
                end,
            })
            :find()
    end)
end

--- Register user commands for selecting dependencies
function M.register()
    vim.api.nvim_create_user_command("SpringPickDependencies", function()
        M.pick_dependencies()
    end, {
        desc = "Pick Spring Boot dependencies via Telescope",
    })
end

return M
