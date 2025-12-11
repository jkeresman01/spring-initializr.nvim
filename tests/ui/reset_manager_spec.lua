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

local reset_manager = require("spring-initializr.ui.managers.reset_manager")

describe("reset_manager", function()
    local original_telescope
    local mock_telescope

    before_each(function()
        -- Clear handlers before each test
        reset_manager.clear_handlers()

        -- Mock telescope module
        mock_telescope = {
            selected_dependencies = { "web", "data-jpa" },
            selected_dependencies_full = {
                { id = "web", name = "Spring Web", description = "Web support" },
                { id = "data-jpa", name = "Spring Data JPA", description = "JPA support" },
            },
            selected_set = {
                clear = function(self)
                    self._cleared = true
                end,
                _cleared = false,
            },
        }

        -- Store original and replace
        original_telescope = package.loaded["spring-initializr.telescope.telescope"]
        package.loaded["spring-initializr.telescope.telescope"] = mock_telescope
    end)

    after_each(function()
        -- Restore original telescope
        package.loaded["spring-initializr.telescope.telescope"] = original_telescope
        reset_manager.clear_handlers()
    end)

    describe("register_reset_handler", function()
        it("registers a function handler", function()
            -- Arrange
            local handler_called = false
            local handler = function()
                handler_called = true
            end

            -- Act
            reset_manager.register_reset_handler(handler)

            -- Assert - handler should be registered (we verify by calling reset)
            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }
            reset_manager.reset_form(selections)

            assert.is_true(handler_called)
        end)

        it("ignores non-function values", function()
            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                reset_manager.register_reset_handler("not a function")
                reset_manager.register_reset_handler(123)
                reset_manager.register_reset_handler(nil)
                reset_manager.register_reset_handler({})
            end)
        end)

        it("allows multiple handlers to be registered", function()
            -- Arrange
            local call_count = 0
            local handler1 = function()
                call_count = call_count + 1
            end
            local handler2 = function()
                call_count = call_count + 1
            end
            local handler3 = function()
                call_count = call_count + 1
            end

            -- Act
            reset_manager.register_reset_handler(handler1)
            reset_manager.register_reset_handler(handler2)
            reset_manager.register_reset_handler(handler3)

            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }
            reset_manager.reset_form(selections)

            -- Assert
            assert.are.equal(3, call_count)
        end)
    end)

    describe("clear_handlers", function()
        it("removes all registered handlers", function()
            -- Arrange
            local handler_called = false
            local handler = function()
                handler_called = true
            end
            reset_manager.register_reset_handler(handler)

            -- Act
            reset_manager.clear_handlers()

            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }
            reset_manager.reset_form(selections)

            -- Assert - handler should NOT be called after clear
            assert.is_false(handler_called)
        end)
    end)

    describe("reset_form", function()
        it("resets input values to defaults", function()
            -- Arrange
            local selections = {
                groupId = "com.mycompany",
                artifactId = "myproject",
                name = "myproject",
                description = "My custom project",
                packageName = "com.mycompany.myproject",
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

        it("clears selected dependencies arrays", function()
            -- Arrange
            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.are.equal(0, #mock_telescope.selected_dependencies)
            assert.are.equal(0, #mock_telescope.selected_dependencies_full)
        end)

        it("clears selected_set if present", function()
            -- Arrange
            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.is_true(mock_telescope.selected_set._cleared)
        end)

        it("executes all registered handlers", function()
            -- Arrange
            local executed = {}
            reset_manager.register_reset_handler(function()
                table.insert(executed, "handler1")
            end)
            reset_manager.register_reset_handler(function()
                table.insert(executed, "handler2")
            end)

            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert
            assert.are.equal(2, #executed)
            assert.is_true(vim.tbl_contains(executed, "handler1"))
            assert.is_true(vim.tbl_contains(executed, "handler2"))
        end)

        it("continues executing handlers even if one throws", function()
            -- Arrange
            local handler2_called = false
            reset_manager.register_reset_handler(function()
                error("Handler 1 failed!")
            end)
            reset_manager.register_reset_handler(function()
                handler2_called = true
            end)

            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }

            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                reset_manager.reset_form(selections)
            end)

            -- Handler 2 should still be called
            assert.is_true(handler2_called)
        end)

        it("handles nil selected_set gracefully", function()
            -- Arrange
            mock_telescope.selected_set = nil

            local selections = {
                groupId = "com.test",
                artifactId = "test",
                name = "test",
                description = "test",
                packageName = "com.test",
            }

            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                reset_manager.reset_form(selections)
            end)
        end)
    end)

    describe("integration workflow", function()
        it("simulates complete reset cycle", function()
            -- Arrange
            local radio_reset_called = false
            local input_reset_called = false

            reset_manager.register_reset_handler(function()
                radio_reset_called = true
            end)
            reset_manager.register_reset_handler(function()
                input_reset_called = true
            end)

            local selections = {
                groupId = "com.mycompany",
                artifactId = "myproject",
                name = "myproject",
                description = "Custom description",
                packageName = "com.mycompany.myproject",
                project_type = "gradle-project",
                language = "kotlin",
            }

            -- Act
            reset_manager.reset_form(selections)

            -- Assert - input values reset
            assert.are.equal("com.example", selections.groupId)
            assert.are.equal("demo", selections.artifactId)

            -- Assert - handlers called
            assert.is_true(radio_reset_called)
            assert.is_true(input_reset_called)

            -- Assert - dependencies cleared
            assert.are.equal(0, #mock_telescope.selected_dependencies)

            -- Note: project_type and language are NOT reset by reset_manager
            -- They are reset by the radio component handlers
            assert.are.equal("gradle-project", selections.project_type)
            assert.are.equal("kotlin", selections.language)
        end)
    end)
end)
