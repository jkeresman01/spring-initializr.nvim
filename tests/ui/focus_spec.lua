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
-- Unit tests for spring-initializr/ui/focus.lua
--
----------------------------------------------------------------------------

local focus = require("spring-initializr.ui.focus")

describe("focus management", function()
    local original_set_current_win
    local set_win_calls
    local mock_components

    before_each(function()
        -- Reset focus state
        focus.reset()

        -- Mock vim.api.nvim_set_current_win
        original_set_current_win = vim.api.nvim_set_current_win
        set_win_calls = {}
        vim.api.nvim_set_current_win = function(winid)
            table.insert(set_win_calls, winid)
        end

        -- Create mock components
        mock_components = {
            {
                winid = 1001,
                map = function() end,
            },
            {
                winid = 1002,
                map = function() end,
            },
            {
                popup = { winid = 1003 },
                map = function() end,
            },
        }
    end)

    after_each(function()
        vim.api.nvim_set_current_win = original_set_current_win
        focus.reset()
    end)

    describe("register", function()
        it("adds component to focusables list", function()
            -- Arrange
            local component = mock_components[1]

            -- Act
            focus.register(component)

            -- Assert
            assert.are.equal(1, #focus.focusables)
            assert.are.equal(component, focus.focusables[1])
        end)

        it("allows multiple components to be registered", function()
            -- Act
            focus.register(mock_components[1])
            focus.register(mock_components[2])
            focus.register(mock_components[3])

            -- Assert
            assert.are.equal(3, #focus.focusables)
        end)
    end)

    describe("reset", function()
        it("clears all focusables", function()
            -- Arrange
            focus.register(mock_components[1])
            focus.register(mock_components[2])

            -- Act
            focus.reset()

            -- Assert
            assert.are.equal(0, #focus.focusables)
        end)

        it("resets current focus to 1", function()
            -- Arrange
            focus.register(mock_components[1])
            focus.register(mock_components[2])
            focus.current_focus = 2

            -- Act
            focus.reset()

            -- Assert
            assert.are.equal(1, focus.current_focus)
        end)
    end)

    describe("enable", function()
        it("maps navigation keys on all components", function()
            -- Arrange
            local map_calls = {}
            for i, comp in ipairs(mock_components) do
                comp.map = function(self, mode, key, fn, opts)
                    table.insert(map_calls, { index = i, mode = mode, key = key })
                end
            end

            focus.register(mock_components[1])
            focus.register(mock_components[2])

            -- Act
            focus.enable()

            -- Assert
            assert.are.equal(4, #map_calls) -- 2 keys per component
            assert.is_true(vim.tbl_contains(
                vim.tbl_map(function(c)
                    return c.key
                end, map_calls),
                "<Tab>"
            ))
            assert.is_true(vim.tbl_contains(
                vim.tbl_map(function(c)
                    return c.key
                end, map_calls),
                "<S-Tab>"
            ))
        end)
    end)

    describe("navigation", function()
        before_each(function()
            -- Register components and enable focus
            for _, comp in ipairs(mock_components) do
                focus.register(comp)
            end
        end)

        it("cycles forward through components", function()
            -- Arrange
            local tab_handler
            mock_components[1].map = function(self, mode, key, fn)
                if key == "<Tab>" then
                    tab_handler = fn
                end
            end
            focus.enable()

            -- Act - simulate pressing Tab
            tab_handler()

            -- Assert
            assert.are.equal(2, focus.current_focus)
            assert.are.equal(1, #set_win_calls)
            assert.are.equal(1002, set_win_calls[1])
        end)

        it("wraps to first component after last", function()
            -- Arrange
            focus.current_focus = 3
            local tab_handler
            mock_components[3].map = function(self, mode, key, fn)
                if key == "<Tab>" then
                    tab_handler = fn
                end
            end
            focus.enable()

            -- Act
            tab_handler()

            -- Assert
            assert.are.equal(1, focus.current_focus)
            assert.are.equal(1001, set_win_calls[#set_win_calls])
        end)

        it("cycles backward through components", function()
            -- Arrange
            focus.current_focus = 2
            local shift_tab_handler
            mock_components[2].map = function(self, mode, key, fn)
                if key == "<S-Tab>" then
                    shift_tab_handler = fn
                end
            end
            focus.enable()

            -- Act
            shift_tab_handler()

            -- Assert
            assert.are.equal(1, focus.current_focus)
            assert.are.equal(1001, set_win_calls[#set_win_calls])
        end)

        it("wraps to last component from first", function()
            -- Arrange
            focus.current_focus = 1
            local shift_tab_handler
            mock_components[1].map = function(self, mode, key, fn)
                if key == "<S-Tab>" then
                    shift_tab_handler = fn
                end
            end
            focus.enable()

            -- Act
            shift_tab_handler()

            -- Assert
            assert.are.equal(3, focus.current_focus)
            assert.are.equal(1003, set_win_calls[#set_win_calls])
        end)
    end)

    describe("edge cases", function()
        it("handles single component", function()
            -- Arrange
            focus.register(mock_components[1])
            local tab_handler
            mock_components[1].map = function(self, mode, key, fn)
                if key == "<Tab>" then
                    tab_handler = fn
                end
            end
            focus.enable()

            -- Act
            tab_handler()

            -- Assert - should stay on same component
            assert.are.equal(1, focus.current_focus)
        end)

        it("handles no components gracefully", function()
            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                focus.enable()
            end)
        end)
    end)
end)
