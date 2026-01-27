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

describe("HashSet (primitives)", function()
    it("adds unique values and reports size", function()
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
        assert.are.equal(2, set:size())
        assert.is_false(set:is_empty())
    end)

    it("has / remove / clear work as expected", function()
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
        assert.are.equal(0, set:size())
        assert.is_true(set:is_empty())
    end)

    it("toggle adds then removes", function()
        -- Arrange
        local set = HashSet.new()

        -- Act
        local added = set:toggle("k")
        local removed = set:toggle("k")

        -- Assert
        assert.is_true(added)
        assert.is_false(removed)
        assert.is_false(set:has("k"))
    end)

    it("from_list deduplicates", function()
        -- Arrange
        local input = { "a", "a", "b", "b", "c" }

        -- Act
        local set = HashSet.from_list(input)

        -- Assert
        assert.are.equal(3, set:size())
        assert.is_true(set:has("a"))
        assert.is_true(set:has("b"))
        assert.is_true(set:has("c"))
    end)

    it("iter and to_list return all elements (order not guaranteed)", function()
        -- Arrange
        local set = HashSet.from_list({ "d", "c", "b", "a" })

        -- Act
        local seen = {}
        for v in set:iter() do
            seen[v] = true
        end
        local list = set:to_list()

        -- Assert
        for _, v in ipairs({ "a", "b", "c", "d" }) do
            assert.is_true(seen[v])
        end
        assert.are.equal(4, #list)
    end)

    it("set algebra union / intersection / difference", function()
        -- Arrange
        local a = HashSet.from_list({ "a", "b", "c" })
        local b = HashSet.from_list({ "b", "c", "d" })

        -- Act
        local inter = a:intersection(b)
        local diff = a:difference(b)
        a:union(b)

        -- Assert
        assert.are.equal(2, inter:size())
        assert.is_true(inter:has("b"))
        assert.is_true(inter:has("c"))

        assert.are.equal(1, diff:size())
        assert.is_true(diff:has("a"))

        for _, v in ipairs({ "a", "b", "c", "d" }) do
            assert.is_true(a:has(v))
        end
        assert.are.equal(4, a:size())
    end)
end)

describe("HashSet (tables with key_fn)", function()
    local function by_id_lower(dep)
        local id = dep.id or dep.ID or dep.name
        return type(id) == "string" and id:lower() or id
    end

    it("deduplicates by canonical id", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })

        -- Act
        local first = set:add({ id = "Web", label = "Spring Web" })
        local second = set:add({ id = "web", label = "Spring Web (alias)" })

        -- Assert
        assert.is_true(first)
        assert.is_false(second)
        assert.are.equal(1, set:size())
    end)

    it("toggle respects key_fn", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })
        local dep = { id = "DATA-JPA", label = "Spring Data JPA" }

        -- Act
        local added = set:toggle(dep)
        local removed = set:toggle({ id = "data-jpa" })

        -- Assert
        assert.is_true(added)
        assert.is_false(removed)
        assert.is_true(set:is_empty())
    end)

    it("has_key / get access by precomputed key", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })
        local dep = { id = "Actuator" }
        set:add(dep)

        -- Act
        local present = set:has_key("actuator")
        local stored = set:get("actuator")

        -- Assert
        assert.is_true(present)
        assert.are.same(dep, stored)
    end)

    it("to_list / iter return original stored tables", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })
        local a = { id = "a" }
        local b = { id = "b" }
        set:add(a)
        set:add(b)

        -- Act
        local found_a, found_b = false, false
        for v in set:iter() do
            if v == a then
                found_a = true
            end
            if v == b then
                found_b = true
            end
        end

        -- Assert
        assert.is_true(found_a)
        assert.is_true(found_b)
    end)

    it("remove_by_key removes item using key directly", function()
        -- Arrange
        local set = HashSet.new({ key_fn = by_id_lower })
        local dep = { id = "Web", label = "Spring Web" }
        set:add(dep)

        -- Act
        local removed = set:remove_by_key("web")
        local removed_again = set:remove_by_key("web")

        -- Assert
        assert.is_true(removed)
        assert.is_false(removed_again)
        assert.is_true(set:is_empty())
        assert.is_false(set:has(dep))
    end)
end)
