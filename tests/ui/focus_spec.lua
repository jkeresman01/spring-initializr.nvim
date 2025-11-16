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
-- Unit tests for spring-initializr/ui/focus_manager.lua
--
----------------------------------------------------------------------------

local focus_manager = require("spring-initializr.ui.managers.focus_manager")

describe("focus_manager management", function()
    local original_set_current_win
    local set_win_calls
    local mock_components

    before_each(function()
        -- Reset focus_manager state
        focus_manager.reset()

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
        focus_manager.reset()
    end)

    describe("register", function()
        it("adds component to focusables list", function()
            -- Arrange
            local component = mock_components[1]

            -- Act
            focus_manager.register_component(component)

            -- Assert
            assert.are.equal(1, #focus_manager.focusables)
            assert.are.equal(component, focus_manager.focusables[1])
        end)

        it("allows multiple components to be registered", function()
            -- Act
            focus_manager.register(mock_components[1])
            focus_manager.register(mock_components[2])
            focus_manager.register(mock_components[3])

            -- Assert
            assert.are.equal(3, #focus_manager.focusables)
        end)
    end)

    describe("reset", function()
        it("clears all focusables", function()
            -- Arrange
            focus_manager.register(mock_components[1])
            focus_manager.register(mock_components[2])

            -- Act
            focus_manager.reset()

            -- Assert
            assert.are.equal(0, #focus_manager.focusables)
        end)

        it("resets current focus_manager to 1", function()
            -- Arrange
            focus_manager.register(mock_components[1])
            focus_manager.register(mock_components[2])
            focus_manager.current_focus_manager = 2

            -- Act
            focus_manager.reset()

            -- Assert
            assert.are.equal(1, focus_manager.current_focus_manager)
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

            focus_manager.register_component(mock_components[1])
            focus_manager.register_component(mock_components[2])

            -- Act
            focus_manager.enable()

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
            -- Register components and enable focus_manager
            for _, comp in ipairs(mock_components) do
                focus_manager.register_component(comp)
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
            focus_manager.enable()

            -- Act - simulate pressing Tab
            tab_handler()

            -- Assert
            assert.are.equal(2, focus_manager.current_focus_manager)
            assert.are.equal(1, #set_win_calls)
            assert.are.equal(1002, set_win_calls[1])
        end)

        it("wraps to first component after last", function()
            -- Arrange
            focus_manager.current_focus_manager = 3
            local tab_handler
            mock_components[3].map = function(self, mode, key, fn)
                if key == "<Tab>" then
                    tab_handler = fn
                end
            end
            focus_manager.enable_navigation()

            -- Act
            tab_handler()

            -- Assert
            assert.are.equal(1, focus_manager.current_focus_manager)
            assert.are.equal(1001, set_win_calls[#set_win_calls])
        end)

        it("cycles backward through components", function()
            -- Arrange
            focus_manager.current_focus_manager = 2
            local shift_tab_handler
            mock_components[2].map = function(self, mode, key, fn)
                if key == "<S-Tab>" then
                    shift_tab_handler = fn
                end
            end
            focus_manager.enable_navigation()

            -- Act
            shift_tab_handler()

            -- Assert
            assert.are.equal(1, focus_manager.current_focus_manager)
            assert.are.equal(1001, set_win_calls[#set_win_calls])
        end)

        it("wraps to last component from first", function()
            -- Arrange
            focus_manager.current_focus_manager = 1
            local shift_tab_handler
            mock_components[1].map = function(self, mode, key, fn)
                if key == "<S-Tab>" then
                    shift_tab_handler = fn
                end
            end
            focus_manager.enable_navigation()

            -- Act
            shift_tab_handler()

            -- Assert
            assert.are.equal(3, focus_manager.current_focus_manager)
            assert.are.equal(1003, set_win_calls[#set_win_calls])
        end)
    end)

    describe("edge cases", function()
        it("handles single component", function()
            -- Arrange
            focus_manager.register_component(mock_components[1])
            local tab_handler
            mock_components[1].map = function(self, mode, key, fn)
                if key == "<Tab>" then
                    tab_handler = fn
                end
            end
            focus_manager.enable()

            -- Act
            tab_handler()

            -- Assert - should stay on same component
            assert.are.equal(1, focus_manager.current_focus_manager)
        end)

        it("handles no components gracefully", function()
            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                focus_manager.enable_navigation()
            end)
        end)
    end)
end)
