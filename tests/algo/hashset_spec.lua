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
-- Unit tests (Arrange–Act–Assert) for spring-initializr/algo/hashset.lua
--
-- Run:
--   :lua require('plenary.busted').run()
-- or
--   nvim --headless -c "PlenaryBustedDirectory tests" +q
--
----------------------------------------------------------------------------

local HashSet = require("spring-initializr.algo.hashset")

describe("HashSet API", function()
    it("only exposes operations used by the plugin", function()
        local set = HashSet.new()

        assert.is_nil(HashSet.from_list)
        assert.is_nil(set.toggle)
        assert.is_nil(set.has_key)
        assert.is_nil(set.get)
        assert.is_nil(set.to_list)
        assert.is_nil(set.iter)
        assert.is_nil(set.union)
        assert.is_nil(set.intersection)
        assert.is_nil(set.difference)
    end)
end)

describe("HashSet (primitives)", function()
    it("adds unique values and reports membership", function()
        -- Arrange
        local set = HashSet.new()

        -- Act
        local first_add = set:add("a")
        local second_add = set:add("a")
        local third_add = set:add("b")

        -- Assert
        assert.is_true(first_add)
        assert.is_false(second_add)
        assert.is_true(third_add)
        assert.is_true(set:has("a"))
        assert.is_true(set:has("b"))
        assert.are.equal(2, set:size())
        assert.is_false(set:is_empty())
    end)

    it("removes individual values and clears the set", function()
        -- Arrange
        local set = HashSet.new()
        set:add("x")
        set:add("y")

        -- Act
        local had_x_before = set:has("x")
        local removed_x = set:remove("x")
        local has_x_after = set:has("x")
        local removed_x_again = set:remove("x")
        set:clear()

        -- Assert
        assert.is_true(had_x_before)
        assert.is_true(removed_x)
        assert.is_false(has_x_after)
        assert.is_false(removed_x_again)
        assert.is_false(set:has("y"))
        assert.are.equal(0, set:size())
        assert.is_true(set:is_empty())
    end)
end)

describe("HashSet (tables with key_fn)", function()
    local function by_id_lower(dep)
        local id = dep.id or dep.ID or dep.name
        return type(id) == "string" and id:lower() or id
    end

    it("deduplicates, finds, and removes by canonical id", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })

        -- Act
        local first = set:add({ id = "Web", label = "Spring Web" })
        local second = set:add({ id = "web", label = "Spring Web (alias)" })

        -- Assert
        assert.is_true(first)
        assert.is_false(second)
        assert.is_true(set:has({ id = "WEB" }))
        assert.is_true(set:remove({ id = "web" }))
        assert.is_false(set:has({ id = "Web" }))
    end)
end)
