----------------------------------------------------------------------------
--
-- Unit tests for spring-initializr/styles/highlights.lua
--
----------------------------------------------------------------------------

local highlights = require("spring-initializr.styles.highlights")

describe("highlights", function()
    local group_names = { "NormalFloat", "FloatBorder", "NuiMenuSel" }
    local original_highlights
    local original_autocmd_ids

    before_each(function()
        original_highlights = {}
        for _, name in ipairs(group_names) do
            original_highlights[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
        end

        original_autocmd_ids = {}
        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "ColorScheme" })) do
            original_autocmd_ids[autocmd.id] = true
        end
    end)

    after_each(function()
        for name, definition in pairs(original_highlights) do
            vim.api.nvim_set_hl(0, name, definition)
        end

        for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "ColorScheme" })) do
            if not original_autocmd_ids[autocmd.id] then
                vim.api.nvim_del_autocmd(autocmd.id)
            end
        end
    end)

    it("preserves user highlights without registering a colorscheme hook", function()
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e", fg = "#cdd6f4" })
        vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1e1e2e", fg = "#89b4fa" })
        vim.api.nvim_set_hl(0, "NuiMenuSel", { bg = "#45475a", fg = "#f5e0dc", bold = true })

        local expected = {}
        for _, name in ipairs(group_names) do
            expected[name] = vim.api.nvim_get_hl(0, { name = name, link = false })
        end
        local autocmd_count = #vim.api.nvim_get_autocmds({ event = "ColorScheme" })

        highlights.configure()

        for _, name in ipairs(group_names) do
            assert.are.same(expected[name], vim.api.nvim_get_hl(0, { name = name, link = false }))
        end
        assert.are.equal(autocmd_count, #vim.api.nvim_get_autocmds({ event = "ColorScheme" }))
    end)
end)
