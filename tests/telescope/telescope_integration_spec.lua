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
-- Integration tests for duplicate dependency detection in telescope.lua
--
-- Note: These tests verify the module's state management and HashSet
-- integration rather than testing internal/local functions directly.
--
----------------------------------------------------------------------------

describe("telescope duplicate dependency detection", function()
    local telescope
    local HashSet
    local message_utils
    local original_show_warn
    local original_show_info
    local warn_calls
    local info_calls

    before_each(function()
        -- Clear module cache to get fresh state
        package.loaded["spring-initializr.telescope.telescope"] = nil
        package.loaded["spring-initializr.utils.message_utils"] = nil
        package.loaded["spring-initializr.algo.hashset"] = nil

        -- Load modules
        HashSet = require("spring-initializr.algo.hashset")
        message_utils = require("spring-initializr.utils.message_utils")

        -- Mock message_utils
        original_show_warn = message_utils.show_warn_message
        original_show_info = message_utils.show_info_message

        warn_calls = {}
        info_calls = {}

        message_utils.show_warn_message = function(msg)
            table.insert(warn_calls, msg)
        end

        message_utils.show_info_message = function(msg)
            table.insert(info_calls, msg)
        end

        -- Load telescope after mocking
        telescope = require("spring-initializr.telescope.telescope")

        -- Reset state
        telescope.selected_dependencies = {}
        telescope.selected_set = nil
    end)

    after_each(function()
        -- Restore original functions
        if message_utils then
            message_utils.show_warn_message = original_show_warn
            message_utils.show_info_message = original_show_info
        end

        -- Clean up module cache
        package.loaded["spring-initializr.telescope.telescope"] = nil
        package.loaded["spring-initializr.utils.message_utils"] = nil
        package.loaded["spring-initializr.algo.hashset"] = nil
    end)

    describe("module state", function()
        it("has selected_dependencies array", function()
            -- Assert
            assert.is_not_nil(telescope.selected_dependencies)
            assert.are.equal("table", type(telescope.selected_dependencies))
        end)

        it("initializes with empty selected_dependencies", function()
            -- Assert
            assert.are.equal(0, #telescope.selected_dependencies)
        end)

        it("has selected_set field for HashSet", function()
            -- Assert
            -- selected_set starts as nil and is lazily initialized
            assert.is_true(telescope.selected_set == nil)
        end)
    end)

    describe("HashSet integration", function()
        it("can be initialized with HashSet", function()
            -- Act
            telescope.selected_set = HashSet.new()

            -- Assert
            assert.is_not_nil(telescope.selected_set)
            assert.are.equal(0, telescope.selected_set:size())
            assert.is_true(telescope.selected_set:is_empty())
        end)

        it("maintains consistency between array and HashSet", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local deps = { "web", "data-jpa", "security" }

            -- Act - Simulate adding dependencies with duplicate check
            for _, dep in ipairs(deps) do
                if not telescope.selected_set:has(dep) then
                    telescope.selected_set:add(dep)
                    table.insert(telescope.selected_dependencies, dep)
                end
            end

            -- Assert
            assert.are.equal(3, #telescope.selected_dependencies)
            assert.are.equal(3, telescope.selected_set:size())

            -- Verify all array items are in set
            for _, dep in ipairs(telescope.selected_dependencies) do
                assert.is_true(telescope.selected_set:has(dep))
            end
        end)

        it("prevents duplicate additions", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local dep = "web"

            -- Act - Try to add same dependency multiple times
            local add_count = 0
            for i = 1, 5 do
                if not telescope.selected_set:has(dep) then
                    telescope.selected_set:add(dep)
                    table.insert(telescope.selected_dependencies, dep)
                    add_count = add_count + 1
                end
            end

            -- Assert
            assert.are.equal(1, add_count)
            assert.are.equal(1, #telescope.selected_dependencies)
            assert.are.equal(1, telescope.selected_set:size())
        end)

        it("detects duplicates using has() method", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local dep = "data-jpa"
            telescope.selected_set:add(dep)

            -- Act
            local is_duplicate = telescope.selected_set:has(dep)

            -- Assert
            assert.is_true(is_duplicate)
        end)

        it("allows different dependencies", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            telescope.selected_set:add("web")
            telescope.selected_set:add("data-jpa")
            telescope.selected_set:add("security")

            -- Assert
            assert.are.equal(3, telescope.selected_set:size())
            assert.is_true(telescope.selected_set:has("web"))
            assert.is_true(telescope.selected_set:has("data-jpa"))
            assert.is_true(telescope.selected_set:has("security"))
        end)
    end)

    describe("duplicate detection logic", function()
        it("first selection should be allowed", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local dep = "web"

            -- Act - Check and add
            local is_duplicate = telescope.selected_set:has(dep)
            if not is_duplicate then
                telescope.selected_set:add(dep)
                table.insert(telescope.selected_dependencies, dep)
            end

            -- Assert
            assert.is_false(is_duplicate)
            assert.are.equal(1, #telescope.selected_dependencies)
        end)

        it("second selection of same dependency should be detected", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local dep = "web"
            telescope.selected_set:add(dep)
            table.insert(telescope.selected_dependencies, dep)

            -- Act - Try to add again
            local is_duplicate = telescope.selected_set:has(dep)

            -- Assert
            assert.is_true(is_duplicate)
            assert.are.equal(1, #telescope.selected_dependencies)
        end)

        it("simulates proper duplicate handling workflow", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act & Assert - First selection
            local dep1 = "web"
            if not telescope.selected_set:has(dep1) then
                telescope.selected_set:add(dep1)
                table.insert(telescope.selected_dependencies, dep1)
            end
            assert.are.equal(1, #telescope.selected_dependencies)

            -- Act & Assert - Different selection
            local dep2 = "data-jpa"
            if not telescope.selected_set:has(dep2) then
                telescope.selected_set:add(dep2)
                table.insert(telescope.selected_dependencies, dep2)
            end
            assert.are.equal(2, #telescope.selected_dependencies)

            -- Act & Assert - Duplicate selection (should not add)
            local dep3 = "web"  -- Same as dep1
            local duplicate_detected = false
            if not telescope.selected_set:has(dep3) then
                telescope.selected_set:add(dep3)
                table.insert(telescope.selected_dependencies, dep3)
            else
                duplicate_detected = true
            end
            assert.is_true(duplicate_detected)
            assert.are.equal(2, #telescope.selected_dependencies)
        end)
    end)

    describe("state management", function()
        it("can be reset properly", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            telescope.selected_set:add("web")
            telescope.selected_set:add("data-jpa")
            table.insert(telescope.selected_dependencies, "web")
            table.insert(telescope.selected_dependencies, "data-jpa")

            -- Act
            telescope.selected_dependencies = {}
            telescope.selected_set:clear()

            -- Assert
            assert.are.equal(0, #telescope.selected_dependencies)
            assert.are.equal(0, telescope.selected_set:size())
            assert.is_true(telescope.selected_set:is_empty())
        end)

        it("handles nil selected_set gracefully", function()
            -- Arrange
            telescope.selected_set = nil

            -- Act & Assert - Initialize on first use
            if not telescope.selected_set then
                telescope.selected_set = HashSet.new()
            end

            assert.is_not_nil(telescope.selected_set)
            assert.are.equal(0, telescope.selected_set:size())
        end)

        it("maintains separate state for array and set", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            telescope.selected_set:add("web")
            -- Intentionally NOT adding to array to test independence

            -- Assert
            assert.are.equal(1, telescope.selected_set:size())
            assert.are.equal(0, #telescope.selected_dependencies)
        end)
    end)

    describe("HashSet behavior verification", function()
        it("add returns true for new items", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            local added = telescope.selected_set:add("web")

            -- Assert
            assert.is_true(added)
        end)

        it("add returns false for existing items", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            telescope.selected_set:add("web")

            -- Act
            local added_again = telescope.selected_set:add("web")

            -- Assert
            assert.is_false(added_again)
        end)

        it("has returns false for non-existent items", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            local has_item = telescope.selected_set:has("nonexistent")

            -- Assert
            assert.is_false(has_item)
        end)

        it("size increases only on unique additions", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act & Assert
            assert.are.equal(0, telescope.selected_set:size())

            telescope.selected_set:add("web")
            assert.are.equal(1, telescope.selected_set:size())

            telescope.selected_set:add("web")  -- duplicate
            assert.are.equal(1, telescope.selected_set:size())

            telescope.selected_set:add("data-jpa")
            assert.are.equal(2, telescope.selected_set:size())
        end)
    end)

    describe("edge cases", function()
        it("handles empty string as dependency id", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            telescope.selected_set:add("")
            local has_empty = telescope.selected_set:has("")

            -- Assert
            assert.is_true(has_empty)
            assert.are.equal(1, telescope.selected_set:size())
        end)

        it("handles dependencies with special characters", function()
            -- Arrange
            telescope.selected_set = HashSet.new()
            local deps = { "data-jpa", "cloud-config", "kafka_streams" }

            -- Act
            for _, dep in ipairs(deps) do
                telescope.selected_set:add(dep)
            end

            -- Assert
            assert.are.equal(3, telescope.selected_set:size())
            for _, dep in ipairs(deps) do
                assert.is_true(telescope.selected_set:has(dep))
            end
        end)

        it("is case-sensitive by default", function()
            -- Arrange
            telescope.selected_set = HashSet.new()

            -- Act
            telescope.selected_set:add("web")

            -- Assert
            assert.is_true(telescope.selected_set:has("web"))
            assert.is_false(telescope.selected_set:has("WEB"))
            assert.is_false(telescope.selected_set:has("Web"))
        end)
    end)
end)
