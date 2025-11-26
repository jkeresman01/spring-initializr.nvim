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
-- Unit tests for spring-initializr/ui/managers/reset_manager.lua
--
----------------------------------------------------------------------------

describe("reset_manager", function()
    local reset_manager
    local message_utils
    local telescope
    local HashSet
    local original_show_info

    before_each(function()
        -- Clear module cache
        package.loaded["spring-initializr.ui.managers.reset_manager"] = nil
        package.loaded["spring-initializr.utils.message_utils"] = nil
        package.loaded["spring-initializr.telescope.telescope"] = nil
        package.loaded["spring-initializr.algo.hashset"] = nil

        -- Load modules
        reset_manager = require("spring-initializr.ui.managers.reset_manager")
        message_utils = require("spring-initializr.utils.message_utils")
        telescope = require("spring-initializr.telescope.telescope")
        HashSet = require("spring-initializr.algo.hashset")

        -- Mock message_utils
        original_show_info = message_utils.show_info_message
        message_utils.show_info_message = function() end

        -- Reset state
        reset_manager.clear_handlers()
        telescope.selected_dependencies = {}
        telescope.selected_dependencies_full = {}
        telescope.selected_set = nil
    end)

    after_each(function()
        message_utils.show_info_message = original_show_info
    end)

    describe("register_reset_handler", function()
        it("registers a handler function", function()
            -- Arrange
            local handler_called = false
            local handler = function()
                handler_called = true
            end

            -- Act
            reset_manager.register_reset_handler(handler)

            -- Assert
            assert.are.equal(1, #reset_manager.state.reset_handlers)
        end)

        it("allows multiple handlers to be registered", function()
            -- Arrange
            local handler1 = function() end
            local handler2 = function() end
            local handler3 = function() end

            -- Act
            reset_manager.register_reset_handler(handler1)
            reset_manager.register_reset_handler(handler2)
            reset_manager.register_reset_handler(handler3)

            -- Assert
            assert.are.equal(3, #reset_manager.state.reset_handlers)
        end)
    end)

    describe("clear_handlers", function()
        it("clears all registered handlers", function()
            -- Arrange
            reset_manager.register_reset_handler(function() end)
            reset_manager.register_reset_handler(function() end)

            -- Act
            reset_manager.clear_handlers()

            -- Assert
            assert.are.equal(0, #reset_manager.state.reset_handlers)
        end)
    end)

    describe("reset_form", function()
        it("resets input selections to defaults", function()
            -- Arrange
            local selections = {
                groupId = "custom.group",
                artifactId = "custom-artifact",
                name = "Custom Name",
                description = "Custom description",
                packageName = "custom.package",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.are.equal("com.example", selections.groupId)
            assert.are.equal("demo", selections.artifactId)
            assert.are.equal("demo", selections.name)
            assert.are.equal("Demo project for Spring Boot", selections.description)
            assert.are.equal("com.example.demo", selections.packageName)
        end)

        it("clears selected dependencies array", function()
            -- Arrange
            telescope.selected_dependencies = { "web", "data-jpa", "security" }
            telescope.selected_dependencies_full = {
                { id = "web", name = "Spring Web" },
                { id = "data-jpa", name = "Spring Data JPA" },
            }
            local selections = {}

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.are.equal(0, #telescope.selected_dependencies)
            assert.are.equal(0, #telescope.selected_dependencies_full)
        end)

        it("clears selected dependencies HashSet if present", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            telescope.selected_set:add("web")
            telescope.selected_set:add("data-jpa")
            local selections = {}

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.is_true(telescope.selected_set:is_empty())
        end)

        it("handles nil selected_set gracefully", function()
            -- Arrange
            telescope.selected_set = nil
            local selections = {}

            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                reset_manager.reset_form(selections)
            end)
        end)

        it("executes all registered handlers", function()
            -- Arrange
            local handler1_called = false
            local handler2_called = false
            local handler3_called = false

            reset_manager.register_reset_handler(function()
                handler1_called = true
            end)
            reset_manager.register_reset_handler(function()
                handler2_called = true
            end)
            reset_manager.register_reset_handler(function()
                handler3_called = true
            end)

            local selections = {}

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.is_true(handler1_called)
            assert.is_true(handler2_called)
            assert.is_true(handler3_called)
        end)

        it("continues if handler throws error", function()
            -- Arrange
            local handler1_called = false
            local handler2_called = false

            reset_manager.register_reset_handler(function()
                handler1_called = true
            end)
            reset_manager.register_reset_handler(function()
                error("Handler error")
            end)
            reset_manager.register_reset_handler(function()
                handler2_called = true
            end)

            local selections = {}

            -- Act
            reset_manager.reset_form(selections)

            -- Assert - All handlers should be attempted
            assert.is_true(handler1_called)
            assert.is_true(handler2_called)
        end)

        it("preserves other selection fields", function()
            -- Arrange
            local selections = {
                groupId = "custom.group",
                project_type = "gradle-project",
                language = "kotlin",
                custom_field = "preserved",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert - Default fields reset
            assert.are.equal("com.example", selections.groupId)
            -- Other fields preserved
            assert.are.equal("gradle-project", selections.project_type)
            assert.are.equal("kotlin", selections.language)
            assert.are.equal("preserved", selections.custom_field)
        end)
    end)

    describe("integration workflow", function()
        it("simulates complete reset workflow", function()
            -- Arrange - Set up modified state
            local selections = {
                groupId = "com.mycompany",
                artifactId = "myproject",
                name = "My Project",
                description = "My custom description",
                packageName = "com.mycompany.myproject",
                project_type = "gradle-project",
                language = "kotlin",
            }

            telescope.selected_dependencies = { "web", "security" }
            telescope.selected_dependencies_full = {
                { id = "web", name = "Spring Web" },
                { id = "security", name = "Spring Security" },
            }
            telescope.selected_set = HashSet.new()
            telescope.selected_set:add("web")
            telescope.selected_set:add("security")

            local handler_called = false
            reset_manager.register_reset_handler(function()
                handler_called = true
            end)

            -- Act - Reset
            reset_manager.reset_form(selections)

            -- Assert - All state reset
            assert.are.equal("com.example", selections.groupId)
            assert.are.equal("demo", selections.artifactId)
            assert.are.equal("demo", selections.name)
            assert.are.equal("Demo project for Spring Boot", selections.description)
            assert.are.equal("com.example.demo", selections.packageName)

            assert.are.equal(0, #telescope.selected_dependencies)
            assert.are.equal(0, #telescope.selected_dependencies_full)
            assert.is_true(telescope.selected_set:is_empty())
            assert.is_true(handler_called)
        end)
    end)
end)
