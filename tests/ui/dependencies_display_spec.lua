----------------------------------------------------------------------------
--
-- Unit tests for the selected dependencies display.
--
----------------------------------------------------------------------------

local picker = {
    selected_dependencies_full = {},
}
package.loaded["nui.popup"] = function() end
package.loaded["spring-initializr.telescope.telescope"] = picker

local dependencies_display =
    require("spring-initializr.ui.components.dependencies.dependencies_display")

describe("dependencies_display", function()
    local bufnr
    local original_selected_dependencies_full

    before_each(function()
        bufnr = vim.api.nvim_create_buf(false, true)
        dependencies_display.state.dependencies_panel = { bufnr = bufnr }
        original_selected_dependencies_full = picker.selected_dependencies_full
        picker.selected_dependencies_full = {}
    end)

    after_each(function()
        picker.selected_dependencies_full = original_selected_dependencies_full
        dependencies_display.state.dependencies_panel = nil

        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
        end
    end)

    it("shows how to add dependencies when the selection is empty", function()
        dependencies_display.update_display()

        assert.are.same({
            "No dependencies selected",
            "Press <CR> on Add Dependencies to select dependencies.",
        }, vim.api.nvim_buf_get_lines(bufnr, 0, -1, false))
    end)

    it("hides the selection hint when a dependency is selected", function()
        picker.selected_dependencies_full = {
            {
                id = "web",
                name = "Spring Web",
                description = "Build web applications",
            },
        }

        dependencies_display.update_display()

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        assert.is_false(
            vim.tbl_contains(lines, "Press <CR> on Add Dependencies to select dependencies.")
        )
    end)
end)
