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
local focus = require("spring-initializr.ui.focus")
local radios = require("spring-initializr.ui.radios")
local inputs = require("spring-initializr.ui.inputs")
local deps = require("spring-initializr.ui.deps")
local msg = require("spring-initializr.utils.message")

local M = {}

function M.build_ui(metadata, selections)
    local outer_popup = Popup({
        border = {
            style = "rounded",
            text = { top = "[ Spring Initializr ]", top_align = "center" },
        },
        position = "50%",
        size = { width = "70%", height = "75%" },
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
    })

    local layout = Layout(
        outer_popup,
        Layout.Box({
            Layout.Box({
                radios.create_radio(
                    "Project Type",
                    metadata.type.values,
                    "project_type",
                    selections
                ),
                radios.create_radio("Language", metadata.language.values, "language", selections),
                radios.create_radio(
                    "Spring Boot Version",
                    vim.tbl_map(function(v)
                        return { name = v.name, id = v.id and v.id:gsub("%.RELEASE$", "") }
                    end, metadata.bootVersion.values or {}),
                    "boot_version",
                    selections
                ),

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

                radios.create_radio(
                    "Packaging",
                    metadata.packaging.values,
                    "packaging",
                    selections
                ),
                radios.create_radio(
                    "Java Version",
                    metadata.javaVersion.values,
                    "java_version",
                    selections
                ),
            }, { dir = "col", size = "50%" }),

            Layout.Box({
                Layout.Box(deps.create_button(deps.update_display), { size = "10%" }),
                Layout.Box(deps.create_display(), { size = "90%" }),
            }, { dir = "col", size = "50%" }),
        }, { dir = "row" })
    )

    return {
        layout = layout,
        outer_popup = outer_popup,
    }
end

return M
