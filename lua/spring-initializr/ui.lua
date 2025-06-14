local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")
local metadata_loader = require("spring-initializr.metadata")
local telescope_dep = require("spring-initializr.telescope")

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#777777" })
vim.api.nvim_set_hl(0, "NuiMenuSel", { bg = "#44475a", fg = "#ffffff", bold = true })

vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = function()
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#777777" })
        vim.api.nvim_set_hl(0, "NuiMenuSel", { bg = "#44475a", fg = "#ffffff", bold = true })
    end,
})

local M = {
    state = {
        layout = nil,
        selections = {
            dependencies = {},
        },
        metadata = nil,
        dependencies_panel = nil,
        right_panel = nil,
    },
    focusables = {},
    current_focus = 1,
}

function M.register_focusable(component)
    table.insert(M.focusables, component)
end

function M.enable_focus_navigation()
    for _, comp in ipairs(M.focusables) do
        comp:map("n", "<Tab>", function()
            M.current_focus = (M.current_focus % #M.focusables) + 1
            vim.api.nvim_set_current_win(M.focusables[M.current_focus].winid)
        end, { noremap = true, nowait = true })

        comp:map("n", "<S-Tab>", function()
            M.current_focus = (M.current_focus - 2 + #M.focusables) % #M.focusables + 1
            vim.api.nvim_set_current_win(M.focusables[M.current_focus].winid)
        end, { noremap = true, nowait = true })
    end
end

local function make_title(text)
    local popup = Popup({
        border = { style = "none" },
        size = { height = 1, width = 40 },
        enter = false,
        focusable = false,
        buf_options = { modifiable = true, readonly = false },
        win_options = { winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder" },
    })

    vim.schedule(function()
        vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", true)
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, { "  " .. text })
        vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
    end)

    return Layout.Box(popup, { size = 1 })
end

local function make_radio_list(title, items, key)
    local selected = 1

    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = title, top_align = "center" },
        },
        position = "50%",
        size = { width = 30, height = #items + 2 },
        enter = true,
        focusable = true,
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    })

    M.register_focusable(popup)

    local function render()
        local lines = {}
        for i, item in ipairs(items) do
            local mark = (i == selected) and "(x)" or "( )"
            table.insert(lines, string.format("%s %s", mark, item))
        end
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
    end

    popup:map("n", "<CR>", function()
        M.state.selections[key] = items[selected]
        vim.notify(title .. ": " .. items[selected])
    end, { nowait = true, noremap = true })

    popup:map("n", "j", function()
        selected = math.min(selected + 1, #items)
        render()
    end, { nowait = true, noremap = true })

    popup:map("n", "k", function()
        selected = math.max(selected - 1, 1)
        render()
    end, { nowait = true, noremap = true })

    vim.schedule(function()
        render()
    end)

    return Layout.Box(popup, { size = #items + 2 })
end

local function make_input(title, key, default)
    local input = Input({
        border = {
            style = "rounded",
            text = { top = title, top_align = "left" },
        },
        size = { width = 40 },
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    }, {
        default_value = default or "",
        on_submit = function(value)
            M.state.selections[key] = value
            vim.notify(title .. ": " .. value)
        end,
    })

    M.register_focusable(input.popup)
    return Layout.Box(input, { size = 3 })
end

function M.update_dependency_panel()
    local panel = M.state.right_panel
    if not panel then
        return
    end

    local lines = { "Selected Dependencies:" }
    for i, dep in ipairs(telescope_dep.selected_dependencies or {}) do
        table.insert(lines, string.format("%d. %s", i, dep:sub(1, 38)))
    end

    vim.api.nvim_buf_set_lines(panel.bufnr, 0, -1, false, lines)
end

local function make_dependency_button()
    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = "Add Dependencies (Telescope)", top_align = "center" },
        },
        size = { height = 3, width = 40 },
        enter = true,
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
        },
    })

    M.register_focusable(popup)

    popup:map("n", "<CR>", function()
        vim.defer_fn(function()
            telescope_dep.pick_dependencies()
            vim.defer_fn(function()
                M.update_dependency_panel()
            end, 200)
        end, 100)
    end, { noremap = true, nowait = true })

    return Layout.Box(popup, { size = 3 })
end

local function make_dependency_display()
    local popup = Popup({
        border = {
            style = "rounded",
            text = { top = "Selected Dependencies", top_align = "center" },
        },
        position = "50%",
        size = { width = 40, height = 10 },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        win_options = {
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
            wrap = true,
        },
    })

    M.state.dependencies_panel = popup
    return popup
end

local function update_dependency_display()
    local popup = M.state.dependencies_panel
    if not popup then
        return
    end

    local lines = {}
    for _, dep in ipairs(telescope_dep.selected_dependencies) do
        table.insert(lines, ("- " .. dep):sub(1, 38))
    end

    vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
end

M.setup_ui = function()
    metadata_loader.fetch_metadata(function(data, err)
        if err or not data then
            vim.notify("Failed to load metadata: " .. (err or "nil"), vim.log.levels.ERROR)
            return
        end

        vim.schedule(function()
            M.state.metadata = data

            local outer_popup = Popup({
                border = {
                    style = "rounded",
                    text = { top = "[ Spring Initializr ]", top_align = "center" },
                },
                position = "50%",
                size = { width = "70%", height = "75%" },
                win_options = {
                    winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
                },
            })

            local layout = Layout(
                outer_popup,
                Layout.Box({
                    Layout.Box({
                        make_radio_list("Project Type", data.type and vim.tbl_map(function(v)
                            return v.name
                        end, data.type.values or {}) or {}, "project_type"),
                        make_radio_list("Language", data.language and vim.tbl_map(function(v)
                            return v.name
                        end, data.language.values or {}) or {}, "language"),
                        make_radio_list(
                            "Spring Boot Version",
                            data.bootVersion
                                    and vim.tbl_map(function(v)
                                        return v.name
                                    end, data.bootVersion.values or {})
                                or {},
                            "boot_version"
                        ),
                        make_title("Project Metadata"),
                        make_input("Group", "groupId", "com.example"),
                        make_input("Artifact", "artifactId", "demo"),
                        make_input("Name", "name", "demo"),
                        make_input("Description", "description", "Demo project for Spring Boot"),
                        make_input("Package Name", "packageName", "com.example.demo"),
                        make_radio_list(
                            "Packaging",
                            data.packaging
                                    and vim.tbl_map(function(v)
                                        return v.name
                                    end, data.packaging.values or {})
                                or {},
                            "packaging"
                        ),
                        make_radio_list(
                            "Java Version",
                            data.javaVersion
                                    and vim.tbl_map(function(v)
                                        return v.name
                                    end, data.javaVersion.values or {})
                                or {},
                            "java_version"
                        ),
                    }, { dir = "col", size = "50%" }),
                    Layout.Box({
                        Layout.Box(make_dependency_button(), { size = "10%" }),
                        Layout.Box(make_dependency_display(), { size = "90%" }),
                    }, { dir = "col", size = "50%" }),
                }, { dir = "row" })
            )

            M.state.layout = layout
            layout:mount()
            M.enable_focus_navigation()
            M.update_dependency_panel()
        end)
    end)
end

M.update_dependency_display = update_dependency_display

return M
