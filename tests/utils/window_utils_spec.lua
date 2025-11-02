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
-- Unit tests for spring-initializr/utils/window_utils.lua
--
----------------------------------------------------------------------------

local window_utils = require("spring-initializr.utils.window_utils")

describe("window_utils.get_winid", function()
    it("returns winid from component with direct winid", function()
        -- Arrange
        local component = { winid = 1001 }

        -- Act
        local result = window_utils.get_winid(component)

        -- Assert
        assert.are.equal(1001, result)
    end)

    it("returns winid from component with popup.winid", function()
        -- Arrange
        local component = {
            popup = { winid = 2002 },
        }

        -- Act
        local result = window_utils.get_winid(component)

        -- Assert
        assert.are.equal(2002, result)
    end)

    it("returns nil when component has no winid", function()
        -- Arrange
        local component = {}

        -- Act
        local result = window_utils.get_winid(component)

        -- Assert
        assert.is_nil(result)
    end)

    it("prefers direct winid over popup.winid", function()
        -- Arrange
        local component = {
            winid = 3003,
            popup = { winid = 4004 },
        }

        -- Act
        local result = window_utils.get_winid(component)

        -- Assert
        assert.are.equal(3003, result)
    end)

    it("returns nil when popup exists but has no winid", function()
        -- Arrange
        local component = {
            popup = {},
        }

        -- Act
        local result = window_utils.get_winid(component)

        -- Assert
        assert.is_nil(result)
    end)
end)

describe("window_utils.safe_close", function()
    local original_win_is_valid
    local original_win_close
    local is_valid_calls
    local close_calls

    before_each(function()
        -- Mock vim.api functions
        original_win_is_valid = vim.api.nvim_win_is_valid
        original_win_close = vim.api.nvim_win_close

        is_valid_calls = {}
        close_calls = {}

        vim.api.nvim_win_is_valid = function(winid)
            table.insert(is_valid_calls, winid)
            -- Simulate valid window for winid >= 1000
            return winid >= 1000
        end

        vim.api.nvim_win_close = function(winid, force)
            table.insert(close_calls, { winid = winid, force = force })
        end
    end)

    after_each(function()
        -- Restore original functions
        vim.api.nvim_win_is_valid = original_win_is_valid
        vim.api.nvim_win_close = original_win_close
    end)

    it("closes valid window", function()
        -- Arrange
        local winid = 1001

        -- Act
        window_utils.safe_close(winid)

        -- Assert
        assert.are.equal(1, #is_valid_calls)
        assert.are.equal(winid, is_valid_calls[1])
        assert.are.equal(1, #close_calls)
        assert.are.equal(winid, close_calls[1].winid)
        assert.is_true(close_calls[1].force)
    end)

    it("does not close invalid window", function()
        -- Arrange
        local winid = 500

        -- Act
        window_utils.safe_close(winid)

        -- Assert
        assert.are.equal(1, #is_valid_calls)
        assert.are.equal(0, #close_calls)
    end)

    it("handles nil winid gracefully", function()
        -- Act
        window_utils.safe_close(nil)

        -- Assert
        assert.are.equal(0, #is_valid_calls)
        assert.are.equal(0, #close_calls)
    end)

    it("handles error during window close", function()
        -- Arrange
        vim.api.nvim_win_close = function()
            error("Window close failed")
        end
        local winid = 1001

        -- Act & Assert - should not throw
        assert.has_no.errors(function()
            window_utils.safe_close(winid)
        end)
    end)
end)
