----------------------------------------------------------------------------
--
-- Unit tests for spring-initializr/ui/components/dependencies/dependency_card.lua
-- Verifies name bold, tag normal foreground, and dimmed description highlights.
--
----------------------------------------------------------------------------

local dependency_card = require("spring-initializr.ui.components.dependencies.dependency_card")

describe("dependency_card highlights", function()
    local NS = "spring_dep_cards"

    local function render(dep, width, focused_index)
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, dependency_card.create_card_lines(dep, width))
        dependency_card.apply_highlights(buf, 0, 1, focused_index)
        local ns = vim.api.nvim_create_namespace(NS)
        local marks = vim.api.nvim_buf_get_extmarks(buf, ns, 0, -1, { details = true })
        local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.api.nvim_buf_delete(buf, { force = true })
        return marks, lines
    end

    local function find_mark(marks, line_num, group)
        for _, m in ipairs(marks) do
            local details = m[4]
            if m[2] == line_num and details.hl_group == group then
                return m, details
            end
        end
        return nil
    end

    it("bolds the dependency name on the header line", function()
        -- Arrange
        local dep = { name = "Spring Data JPA", id = "data-jpa", description = "Persist data" }

        -- Act
        local marks, lines = render(dep, 60)
        local mark, details = find_mark(marks, 1, "SpringInitializrDepName")

        -- Assert
        assert.is_not_nil(mark)
        assert.are.equal("Spring Data JPA", lines[2]:sub(mark[3] + 1, details.end_col))
    end)

    it("applies the normal-foreground tag group to the ID tag", function()
        -- Arrange
        local dep = { name = "Spring Data JPA", id = "data-jpa", description = "Persist data" }

        -- Act
        local marks, lines = render(dep, 60)
        local mark, details = find_mark(marks, 1, "SpringInitializrDepTag")

        -- Assert
        assert.is_not_nil(mark)
        assert.are.equal("[DATA-JPA]", lines[2]:sub(mark[3] + 1, details.end_col))
    end)

    it("keeps the Visual highlight on the focused card header and tag", function()
        -- Arrange
        local dep = { name = "Spring Data JPA", id = "data-jpa", description = "Persist data" }

        -- Act
        local marks = render(dep, 60, 1)
        local visual = find_mark(marks, 1, "Visual")
        local tag = find_mark(marks, 1, "SpringInitializrDepTag")

        -- Assert
        assert.is_not_nil(visual)
        assert.is_not_nil(tag)
    end)

    it("dims the description line", function()
        -- Arrange
        local dep = { name = "Spring Data JPA", id = "data-jpa", description = "Persist data" }

        -- Act
        local marks, lines = render(dep, 60)
        local mark, details = find_mark(marks, 2, "SpringInitializrDepDesc")

        -- Assert
        assert.is_not_nil(mark)
        assert.is_not_nil(lines[3]:sub(mark[3] + 1, details.end_col):find("Persist data", 1, true))
    end)
end)
