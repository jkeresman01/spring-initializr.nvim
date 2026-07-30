----------------------------------------------------------------------------
--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
--
-- Component tests for radio navigation and confirmation behavior.
--
----------------------------------------------------------------------------

local RADIO_MODULE = "spring-initializr.ui.components.common.radios.radios"

describe("radio component", function()
    local original_modules
    local popup
    local reset_handler
    local radio

    local function buffer_lines()
        return vim.api.nvim_buf_get_lines(popup.bufnr, 0, -1, false)
    end

    local function wait_for_lines(expected)
        assert.is_true(vim.wait(200, function()
            return vim.deep_equal(buffer_lines(), expected)
        end))
    end

    local function create_radio(selections)
        popup = radio.create_radio({
            title = "Project",
            key = "type",
            selections = selections,
            values = {
                { id = "maven", name = "Maven Project" },
                { id = "gradle", name = "Gradle Project" },
                { id = "gradle-kotlin", name = "Gradle Kotlin" },
            },
        })
    end

    before_each(function()
        local module_names = {
            "nui.popup",
            "spring-initializr.ui.icons.icons",
            "spring-initializr.ui.managers.focus_manager",
            "spring-initializr.ui.managers.reset_manager",
            "spring-initializr.utils.message_utils",
        }

        original_modules = {}
        for _, module_name in ipairs(module_names) do
            original_modules[module_name] = package.loaded[module_name]
        end

        package.loaded["nui.popup"] = function()
            local instance = {
                bufnr = vim.api.nvim_create_buf(false, true),
                mappings = {},
            }

            function instance:map(_, key, handler)
                self.mappings[key] = handler
            end

            return instance
        end
        package.loaded["spring-initializr.ui.icons.icons"] = {
            get_radio_selected = function()
                return "[x]"
            end,
            get_radio_unselected = function()
                return "[ ]"
            end,
            format_section_title = function(title)
                return title
            end,
        }
        package.loaded["spring-initializr.ui.managers.focus_manager"] = {
            register_component = function() end,
        }
        package.loaded["spring-initializr.ui.managers.reset_manager"] = {
            register_reset_handler = function(handler)
                reset_handler = handler
            end,
        }
        package.loaded["spring-initializr.utils.message_utils"] = {
            show_info_message = function() end,
            show_warn_message = function() end,
        }

        package.loaded[RADIO_MODULE] = nil
        radio = require(RADIO_MODULE)
    end)

    after_each(function()
        if popup and vim.api.nvim_buf_is_valid(popup.bufnr) then
            vim.api.nvim_buf_delete(popup.bufnr, { force = true })
        end

        for module_name, original_module in pairs(original_modules) do
            package.loaded[module_name] = original_module
        end
        package.loaded[RADIO_MODULE] = nil
        popup = nil
        reset_handler = nil
    end)

    it("moves the cursor without confirming until Enter", function()
        local selections = { type = "maven" }
        create_radio(selections)

        wait_for_lines({
            ">   [x] Maven Project",
            "    [ ] Gradle Project",
            "    [ ] Gradle Kotlin",
        })

        popup.mappings.j()

        assert.are.equal("maven", selections.type)
        assert.are.same({
            "    [x] Maven Project",
            ">   [ ] Gradle Project",
            "    [ ] Gradle Kotlin",
        }, buffer_lines())

        popup.mappings["<CR>"]()

        assert.are.equal("gradle", selections.type)
        assert.are.same({
            "    [ ] Maven Project",
            ">   [x] Gradle Project",
            "    [ ] Gradle Kotlin",
        }, buffer_lines())
    end)

    it("resets the cursor and confirmed selection to the first option", function()
        local selections = { type = "maven" }
        create_radio(selections)
        wait_for_lines({
            ">   [x] Maven Project",
            "    [ ] Gradle Project",
            "    [ ] Gradle Kotlin",
        })

        popup.mappings.j()
        popup.mappings["<CR>"]()
        reset_handler()

        wait_for_lines({
            ">   [x] Maven Project",
            "    [ ] Gradle Project",
            "    [ ] Gradle Kotlin",
        })
        assert.are.equal("maven", selections.type)
    end)
end)
