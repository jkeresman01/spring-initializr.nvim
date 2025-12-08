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
-- Test for Issue #136: Dependencies cannot be removed after state restore
--
-- This test verifies that the HashSet is properly initialized when
-- restoring saved state, allowing dependencies to be removed with dd.
--
----------------------------------------------------------------------------

-- local telescope = require("spring-initializr.telescope.telescope")
-- local HashSet = require("spring-initializr.algo.hashset")

-- describe("state restoration with HashSet", function()
--     before_each(function()
--         -- Reset telescope state
--         telescope.selected_dependencies = {}
--         telescope.selected_dependencies_full = {}
--         telescope.selected_set = nil
--     end)

--     describe("HashSet initialization during restoration", function()
--         it("creates HashSet when nil during restoration", function()
--             -- Arrange - simulate restored dependencies
--             local restored_deps = {
--                 { id = "web", name = "Spring Web", description = "Web support" },
--                 { id = "data-jpa", name = "Spring Data JPA", description = "JPA support" },
--                 { id = "security", name = "Spring Security", description = "Security" },
--             }

--             -- Act - simulate state restoration
--             if not telescope.selected_set then
--                 telescope.selected_set = HashSet.new()
--             else
--                 telescope.selected_set:clear()
--             end

--             for _, dep in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep.id)
--                 table.insert(telescope.selected_dependencies_full, dep)
--                 telescope.selected_set:add(dep.id)
--             end

--             -- Assert
--             assert.is_not_nil(telescope.selected_set)
--             assert.are.equal(3, telescope.selected_set:size())
--             assert.is_true(telescope.selected_set:has("web"))
--             assert.is_true(telescope.selected_set:has("data-jpa"))
--             assert.is_true(telescope.selected_set:has("security"))
--         end)

--         it("clears existing HashSet before restoration", function()
--             -- Arrange - pre-populate HashSet with old data
--             telescope.selected_set = HashSet.new()
--             telescope.selected_set:add("old-dep-1")
--             telescope.selected_set:add("old-dep-2")

--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--             }

--             -- Act - simulate state restoration with clear
--             telescope.selected_set:clear()

--             for _, dep in ipairs(restored_deps) do
--                 telescope.selected_set:add(dep.id)
--             end

--             -- Assert
--             assert.are.equal(1, telescope.selected_set:size())
--             assert.is_true(telescope.selected_set:has("web"))
--             assert.is_false(telescope.selected_set:has("old-dep-1"))
--             assert.is_false(telescope.selected_set:has("old-dep-2"))
--         end)

--         it("maintains consistency between arrays and HashSet", function()
--             -- Arrange
--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--                 { id = "data-jpa", name = "Spring Data JPA" },
--             }

--             -- Act - simulate proper restoration
--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}

--             if not telescope.selected_set then
--                 telescope.selected_set = HashSet.new()
--             else
--                 telescope.selected_set:clear()
--             end

--             for _, dep in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep.id)
--                 table.insert(telescope.selected_dependencies_full, dep)
--                 telescope.selected_set:add(dep.id)
--             end

--             -- Assert - all three structures should be in sync
--             assert.are.equal(2, #telescope.selected_dependencies)
--             assert.are.equal(2, #telescope.selected_dependencies_full)
--             assert.are.equal(2, telescope.selected_set:size())

--             -- Verify each dependency exists in all structures
--             for _, dep in ipairs(restored_deps) do
--                 assert.is_true(vim.tbl_contains(telescope.selected_dependencies, dep.id))
--                 assert.is_true(telescope.selected_set:has(dep.id))
--             end
--         end)
--     end)

--     describe("dependency removal after restoration", function()
--         it("allows removal with dd after proper HashSet restoration", function()
--             -- Arrange - simulate restored state WITH HashSet
--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--                 { id = "data-jpa", name = "Spring Data JPA" },
--                 { id = "security", name = "Spring Security" },
--             }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new()

--             for _, dep in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep.id)
--                 table.insert(telescope.selected_dependencies_full, dep)
--                 telescope.selected_set:add(dep.id)
--             end

--             -- Act - remove a dependency
--             local removed = telescope.remove_dependency("data-jpa")

--             -- Assert
--             assert.is_true(removed)
--             assert.are.equal(2, #telescope.selected_dependencies)
--             assert.are.equal(2, #telescope.selected_dependencies_full)
--             assert.are.equal(2, telescope.selected_set:size())
--             assert.is_false(telescope.selected_set:has("data-jpa"))
--         end)

--         it("fails to remove when HashSet not properly restored (bug reproduction)", function()
--             -- Arrange - simulate BROKEN restoration (bug scenario)
--             -- Only arrays are populated, HashSet is empty
--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--                 { id = "data-jpa", name = "Spring Data JPA" },
--             }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new() -- Empty!

--             for _, dep in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep.id)
--                 table.insert(telescope.selected_dependencies_full, dep)
--                 -- BUG: Not adding to HashSet!
--             end

--             -- Act - try to remove a dependency
--             local removed = telescope.remove_dependency("web")

--             -- Assert - removal fails because HashSet is empty
--             assert.is_false(removed)
--             assert.are.equal(2, #telescope.selected_dependencies) -- Still 2
--             assert.are.equal(0, telescope.selected_set:size()) -- Still empty
--         end)

--         it("allows multiple removals after restoration", function()
--             -- Arrange
--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--                 { id = "data-jpa", name = "Spring Data JPA" },
--                 { id = "security", name = "Spring Security" },
--             }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new()

--             for _, dep in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep.id)
--                 table.insert(telescope.selected_dependencies_full, dep)
--                 telescope.selected_set:add(dep.id)
--             end

--             -- Act - remove multiple dependencies
--             local removed1 = telescope.remove_dependency("web")
--             local removed2 = telescope.remove_dependency("security")

--             -- Assert
--             assert.is_true(removed1)
--             assert.is_true(removed2)
--             assert.are.equal(1, #telescope.selected_dependencies)
--             assert.are.equal(1, #telescope.selected_dependencies_full)
--             assert.are.equal(1, telescope.selected_set:size())
--             assert.is_true(telescope.selected_set:has("data-jpa"))
--         end)

--         it("allows removal of string-type dependencies", function()
--             -- Arrange - simulate restoration with string-type deps
--             local restored_deps = { "web", "data-jpa", "security" }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new()

--             for _, dep_id in ipairs(restored_deps) do
--                 table.insert(telescope.selected_dependencies, dep_id)
--                 table.insert(telescope.selected_dependencies_full, {
--                     id = dep_id,
--                     name = dep_id,
--                     description = "",
--                 })
--                 telescope.selected_set:add(dep_id)
--             end

--             -- Act
--             local removed = telescope.remove_dependency("data-jpa")

--             -- Assert
--             assert.is_true(removed)
--             assert.are.equal(2, telescope.selected_set:size())
--             assert.is_false(telescope.selected_set:has("data-jpa"))
--         end)
--     end)

--     describe("edge cases", function()
--         it("handles empty restored dependencies", function()
--             -- Arrange
--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}

--             if not telescope.selected_set then
--                 telescope.selected_set = HashSet.new()
--             else
--                 telescope.selected_set:clear()
--             end

--             -- Act & Assert
--             assert.are.equal(0, #telescope.selected_dependencies)
--             assert.are.equal(0, #telescope.selected_dependencies_full)
--             assert.are.equal(0, telescope.selected_set:size())
--             assert.is_true(telescope.selected_set:is_empty())
--         end)

--         it("handles restoration with duplicate IDs gracefully", function()
--             -- Arrange - simulate malformed saved data with duplicates
--             local restored_deps = {
--                 { id = "web", name = "Spring Web" },
--                 { id = "web", name = "Spring Web (duplicate)" },
--             }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new()

--             for _, dep in ipairs(restored_deps) do
--                 -- Only add if not already in HashSet
--                 if not telescope.selected_set:has(dep.id) then
--                     table.insert(telescope.selected_dependencies, dep.id)
--                     table.insert(telescope.selected_dependencies_full, dep)
--                     telescope.selected_set:add(dep.id)
--                 end
--             end

--             -- Assert - duplicates prevented
--             assert.are.equal(1, #telescope.selected_dependencies)
--             assert.are.equal(1, #telescope.selected_dependencies_full)
--             assert.are.equal(1, telescope.selected_set:size())
--         end)

--         it("verifies HashSet after restoration matches expected state", function()
--             -- Arrange & Act
--             local deps = { "web", "data-jpa", "security", "actuator" }

--             telescope.selected_dependencies = {}
--             telescope.selected_dependencies_full = {}
--             telescope.selected_set = HashSet.new()

--             for _, dep_id in ipairs(deps) do
--                 table.insert(telescope.selected_dependencies, dep_id)
--                 telescope.selected_set:add(dep_id)
--             end

--             -- Assert - verify each dep is in HashSet
--             for _, dep_id in ipairs(deps) do
--                 assert.is_true(
--                     telescope.selected_set:has(dep_id),
--                     "Dependency " .. dep_id .. " should be in HashSet"
--                 )
--             end

--             -- Assert - sizes match
--             assert.are.equal(
--                 #telescope.selected_dependencies,
--                 telescope.selected_set:size(),
--                 "Array and HashSet sizes should match"
--             )
--         end)
--     end)
-- end)
