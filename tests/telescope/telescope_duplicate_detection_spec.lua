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
-- Unit tests for duplicate dependency detection logic
--
-- These tests verify the HashSet-based duplicate detection logic
-- without requiring telescope.nvim to be installed.
--
----------------------------------------------------------------------------

local HashSet = require("spring-initializr.algo.hashset")

describe("duplicate dependency detection logic", function()
    describe("HashSet duplicate detection", function()
        local selected_dependencies_set

        before_each(function()
            selected_dependencies_set = HashSet.new()
        end)

        it("allows first selection of a dependency", function()
            -- Arrange
            local dep_id = "web"

            -- Act - Simulate selection
            local is_duplicate = selected_dependencies_set:has(dep_id)
            if not is_duplicate then
                selected_dependencies_set:add(dep_id)
            end

            -- Assert
            assert.is_false(is_duplicate)
            assert.is_true(selected_dependencies_set:has("web"))
            assert.are.equal(1, selected_dependencies_set:size())
        end)

        it("detects duplicate selection", function()
            -- Arrange - Add first time
            selected_dependencies_set:add("web")

            -- Act - Try to add again
            local is_duplicate = selected_dependencies_set:has("web")
            local initial_count = selected_dependencies_set:size()

            if not is_duplicate then
                selected_dependencies_set:add("web")
            end

            -- Assert
            assert.is_true(is_duplicate)
            assert.are.equal(initial_count, selected_dependencies_set:size())
        end)

        it("allows multiple different dependencies", function()
            -- Arrange
            local deps = {
                { id = "web" },
                { id = "data-jpa" },
                { id = "security" },
            }

            -- Act
            for _, dep in ipairs(deps) do
                if not selected_dependencies_set:has(dep.id) then
                    selected_dependencies_set:add(dep.id)
                end
            end

            -- Assert
            assert.are.equal(3, selected_dependencies_set:size())
            assert.is_true(selected_dependencies_set:has("web"))
            assert.is_true(selected_dependencies_set:has("data-jpa"))
            assert.is_true(selected_dependencies_set:has("security"))
        end)

        it("prevents duplicate when attempting multiple times", function()
            -- Arrange
            local dep = "web"

            -- Act - Try to add 5 times
            local add_count = 0
            for i = 1, 5 do
                if not selected_dependencies_set:has(dep) then
                    selected_dependencies_set:add(dep)
                    add_count = add_count + 1
                end
            end

            -- Assert
            assert.are.equal(1, add_count)
            assert.are.equal(1, selected_dependencies_set:size())
        end)
    end)

    describe("selection workflow simulation", function()
        local selected_dependencies_set

        before_each(function()
            selected_dependencies_set = HashSet.new()
        end)

        it("simulates complete selection workflow", function()
            -- Act & Assert - First selection
            local dep1 = "web"
            local duplicate1 = selected_dependencies_set:has(dep1)
            if not duplicate1 then
                selected_dependencies_set:add(dep1)
            end
            assert.is_false(duplicate1)
            assert.are.equal(1, selected_dependencies_set:size())

            -- Act & Assert - Different selection
            local dep2 = "data-jpa"
            local duplicate2 = selected_dependencies_set:has(dep2)
            if not duplicate2 then
                selected_dependencies_set:add(dep2)
            end
            assert.is_false(duplicate2)
            assert.are.equal(2, selected_dependencies_set:size())

            -- Act & Assert - Duplicate selection
            local dep3 = "web" -- Same as dep1
            local duplicate3 = selected_dependencies_set:has(dep3)
            if not duplicate3 then
                selected_dependencies_set:add(dep3)
            end
            assert.is_true(duplicate3)
            assert.are.equal(2, selected_dependencies_set:size())
        end)

        it("handles mixed new and duplicate selections", function()
            -- Arrange
            local selections = {
                "web",
                "data-jpa",
                "web", -- duplicate
                "security",
                "data-jpa", -- duplicate
                "actuator",
                "web", -- duplicate
            }

            -- Act
            for _, dep in ipairs(selections) do
                selected_dependencies_set:add(dep)
            end

            -- Assert
            assert.are.equal(4, selected_dependencies_set:size())
            assert.is_true(selected_dependencies_set:has("web"))
            assert.is_true(selected_dependencies_set:has("data-jpa"))
            assert.is_true(selected_dependencies_set:has("security"))
            assert.is_true(selected_dependencies_set:has("actuator"))
        end)
    end)

    describe("state management", function()
        it("resets properly when cleared", function()
            -- Arrange
            local selected_dependencies = { "web", "data-jpa", "security" }
            local selected_dependencies_set = HashSet.new()

            for _, dep in ipairs(selected_dependencies) do
                selected_dependencies_set:add(dep)
            end

            -- Act
            selected_dependencies = {}
            selected_dependencies_set:clear()

            -- Assert
            assert.are.equal(0, selected_dependencies_set:size())
            assert.is_true(selected_dependencies_set:is_empty())
        end)

        it("handles lazy initialization", function()
            -- Arrange
            local selected_dependencies_set = nil

            -- Act - Lazy init
            if not selected_dependencies_set then
                selected_dependencies_set = HashSet.new()
            end

            -- Assert
            assert.is_not_nil(selected_dependencies_set)
            assert.are.equal(0, selected_dependencies_set:size())
        end)
    end)

    describe("HashSet behavior verification", function()
        it("add returns true for new items", function()
            -- Arrange
            local set = HashSet.new()

            -- Act
            local added = set:add("web")

            -- Assert
            assert.is_true(added)
            assert.are.equal(1, set:size())
        end)

        it("add returns false for duplicate items", function()
            -- Arrange
            local set = HashSet.new()
            set:add("web")

            -- Act
            local added_again = set:add("web")

            -- Assert
            assert.is_false(added_again)
            assert.are.equal(1, set:size())
        end)

        it("has returns true for existing items", function()
            -- Arrange
            local set = HashSet.new()
            set:add("web")

            -- Act
            local exists = set:has("web")

            -- Assert
            assert.is_true(exists)
        end)

        it("has returns false for non-existent items", function()
            -- Arrange
            local set = HashSet.new()

            -- Act
            local exists = set:has("nonexistent")

            -- Assert
            assert.is_false(exists)
        end)

        it("size increases only on unique additions", function()
            -- Arrange
            local set = HashSet.new()

            -- Act & Assert
            assert.are.equal(0, set:size())

            set:add("web")
            assert.are.equal(1, set:size())

            set:add("web") -- duplicate
            assert.are.equal(1, set:size())

            set:add("data-jpa")
            assert.are.equal(2, set:size())

            set:add("security")
            assert.are.equal(3, set:size())

            set:add("data-jpa") -- duplicate
            assert.are.equal(3, set:size())
        end)
    end)

    describe("edge cases", function()
        it("handles empty string as dependency", function()
            -- Arrange
            local set = HashSet.new()

            -- Act
            set:add("")
            local has_empty = set:has("")

            -- Assert
            assert.is_true(has_empty)
            assert.are.equal(1, set:size())
        end)

        it("handles dependencies with special characters", function()
            -- Arrange
            local set = HashSet.new()
            local deps = { "data-jpa", "cloud-config", "kafka_streams", "spring.boot" }

            -- Act
            for _, dep in ipairs(deps) do
                set:add(dep)
            end

            -- Assert
            assert.are.equal(4, set:size())
            for _, dep in ipairs(deps) do
                assert.is_true(set:has(dep))
            end
        end)

        it("is case-sensitive by default", function()
            -- Arrange
            local set = HashSet.new()

            -- Act
            set:add("web")

            -- Assert
            assert.is_true(set:has("web"))
            assert.is_false(set:has("WEB"))
            assert.is_false(set:has("Web"))
        end)

        it("handles large number of dependencies", function()
            -- Arrange
            local set = HashSet.new()
            local count = 100

            -- Act
            for i = 1, count do
                set:add("dep" .. i)
            end

            -- Assert
            assert.are.equal(count, set:size())
            for i = 1, count do
                assert.is_true(set:has("dep" .. i))
            end
        end)
    end)

    describe("realistic integration scenarios", function()
        it("simulates user adding dependencies one by one", function()
            -- Arrange
            local selected_dependencies_set = HashSet.new()

            -- Act & Assert - User's journey
            -- 1. Add Spring Web
            if not selected_dependencies_set:has("web") then
                selected_dependencies_set:add("web")
            end
            assert.are.equal(1, selected_dependencies_set:size())

            -- 2. Add Spring Data JPA
            if not selected_dependencies_set:has("data-jpa") then
                selected_dependencies_set:add("data-jpa")
            end
            assert.are.equal(2, selected_dependencies_set:size())

            -- 3. Try to add Spring Web again (duplicate)
            local was_duplicate = selected_dependencies_set:has("web")
            if not was_duplicate then
                selected_dependencies_set:add("web")
            end
            assert.is_true(was_duplicate)
            assert.are.equal(2, selected_dependencies_set:size())

            -- 4. Add Spring Security
            if not selected_dependencies_set:has("security") then
                selected_dependencies_set:add("security")
            end
            assert.are.equal(3, selected_dependencies_set:size())

            -- Final check
            assert.are.equal(3, selected_dependencies_set:size())
            assert.is_true(selected_dependencies_set:has("web"))
            assert.is_true(selected_dependencies_set:has("data-jpa"))
            assert.is_true(selected_dependencies_set:has("security"))
        end)

        it("handles reset and reuse of structures", function()
            -- Arrange
            local selected_dependencies_set = HashSet.new()
            selected_dependencies_set:add("web")
            selected_dependencies_set:add("data-jpa")

            -- Act - Reset
            selected_dependencies_set:clear()

            -- Assert - Can be reused
            assert.are.equal(0, selected_dependencies_set:size())

            -- Act - Add new dependencies
            selected_dependencies_set:add("security")

            -- Assert
            assert.are.equal(1, selected_dependencies_set:size())
            assert.is_true(selected_dependencies_set:has("security"))
            assert.is_false(selected_dependencies_set:has("web"))
        end)
    end)
end)
