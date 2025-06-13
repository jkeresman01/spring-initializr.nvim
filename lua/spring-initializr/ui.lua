local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Menu = require("nui.menu")
local metadata_loader = require("spring-initializr.metadata")

local M = {
    state = {
        layout = nil,
        selections = {},
        metadata = nil,
    },
}

local function make_menu(title, values, key)
    local items = {}

    for _, val in ipairs(values or {}) do
        local label = type(val) == "table" and (val.name or val.id) or nil
        if type(label) == "string" then
            table.insert(items, Menu.item(label))
        end
    end

    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = title, top_align = "center" },
        },
        size = { height = #items + 2, width = 30 },
    })

    local menu = Menu(popup, {
        lines = items,
        max_width = 30,
        on_submit = function(item)
            M.state.selections[key] = item.text
            vim.notify(title .. ": " .. item.text)
        end,
    })

    return Layout.Box(menu, { size = #items + 2 })
end

M.setup_ui = function()
    metadata_loader.fetch_metadata(function(data, err)
        if err or not data then
            vim.notify("Failed to load metadata: " .. (err or "nil"), vim.log.levels.ERROR)
            return
        end

        vim.schedule(function()
            M.state.metadata = data

            local layout = Layout(
                {
                    position = "50%",
                    size = { width = "60%", height = "60%" },
                },
                Layout.Box({
                    make_menu("Project Type", data.type and data.type.values or {}, "project_type"),
                    make_menu("Language", data.language and data.language.values or {}, "language"),
                    make_menu(
                        "Java Version",
                        data.javaVersion and data.javaVersion.values or {},
                        "java_version"
                    ),
                }, { dir = "col" })
            )

            M.state.layout = layout
            layout:mount()
        end)
    end)
end

return M
