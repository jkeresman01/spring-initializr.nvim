--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/layout.lua
-- Author: Josip Keresman

local Layout = require("nui.layout")
local Popup = require("nui.popup")

local radios = require("spring-initializr.ui.radios")
local inputs = require("spring-initializr.ui.inputs")
local deps = require("spring-initializr.ui.deps")

local M = {}

local function create_outer_popup()
    return Popup({
        border = {
            style = "rounded",
            text = { top = "[ Spring Initializr ]", top_align = "center" },
        },
        position = "50%",
        size = { width = "70%", height = "75%" },
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
    })
end

local function create_radio_controls(metadata, selections)
    return {
        radios.create_radio("Project Type", metadata.type.values, "project_type", selections),
        radios.create_radio("Language", metadata.language.values, "language", selections),
        radios.create_radio(
            "Spring Boot Version",
            vim.tbl_map(function(v)
                return { name = v.name, id = v.id and v.id:gsub("%.RELEASE$", "") }
            end, metadata.bootVersion.values or {}),
            "boot_version",
            selections
        ),
        radios.create_radio("Packaging", metadata.packaging.values, "packaging", selections),
        radios.create_radio(
            "Java Version",
            metadata.javaVersion.values,
            "java_version",
            selections
        ),
    }
end

local function create_input_controls(selections)
    return {
        inputs.create_input("Group", "groupId", "com.example", selections),
        inputs.create_input("Artifact", "artifactId", "demo", selections),
        inputs.create_input("Name", "name", "demo", selections),
        inputs.create_input(
            "Description",
            "description",
            "Demo project for Spring Boot",
            selections
        ),
        inputs.create_input("Package Name", "packageName", "com.example.demo", selections),
    }
end

local function create_left_panel(metadata, selections)
    local children = {}
    vim.list_extend(children, create_radio_controls(metadata, selections))
    vim.list_extend(children, create_input_controls(selections))

    return Layout.Box(children, { dir = "col", size = "50%" })
end

local function create_right_panel()
    return Layout.Box({
        Layout.Box(deps.create_button(deps.update_display), { size = "10%" }),
        Layout.Box(deps.create_display(), { size = "90%" }),
    }, { dir = "col", size = "50%" })
end

function M.build_ui(metadata, selections)
    local outer_popup = create_outer_popup()
    local layout = Layout(
        outer_popup,
        Layout.Box({
            create_left_panel(metadata, selections),
            create_right_panel(),
        }, { dir = "row" })
    )

    return {
        layout = layout,
        outer_popup = outer_popup,
    }
end

return M
