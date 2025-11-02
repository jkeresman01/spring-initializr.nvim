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
-- Unit tests for spring-initializr/utils/message_utils.lua
--
----------------------------------------------------------------------------

local message_utils = require("spring-initializr.utils.message_utils")

describe("message_utils", function()
    local original_notify
    local captured_calls

    before_each(function()
        -- Capture vim.notify calls
        original_notify = vim.notify
        captured_calls = {}
        vim.notify = function(msg, level)
            table.insert(captured_calls, { msg = msg, level = level })
        end
    end)

    after_each(function()
        -- Restore original notify
        vim.notify = original_notify
    end)

    describe("show_info_message", function()
        it("calls vim.notify with INFO level", function()
            -- Arrange
            local message = "Test info message"

            -- Act
            message_utils.show_info_message(message)

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal(message, captured_calls[1].msg)
            assert.are.equal(vim.log.levels.INFO, captured_calls[1].level)
        end)

        it("handles empty string", function()
            -- Act
            message_utils.show_info_message("")

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal("", captured_calls[1].msg)
        end)

        it("handles multiline message", function()
            -- Arrange
            local message = "Line 1\nLine 2\nLine 3"

            -- Act
            message_utils.show_info_message(message)

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal(message, captured_calls[1].msg)
        end)
    end)

    describe("show_warn_message", function()
        it("calls vim.notify with WARN level", function()
            -- Arrange
            local message = "Test warning message"

            -- Act
            message_utils.show_warn_message(message)

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal(message, captured_calls[1].msg)
            assert.are.equal(vim.log.levels.WARN, captured_calls[1].level)
        end)

        it("handles warning with special characters", function()
            -- Arrange
            local message = "Warning: File 'test.txt' not found!"

            -- Act
            message_utils.show_warn_message(message)

            -- Assert
            assert.are.equal(message, captured_calls[1].msg)
        end)
    end)

    describe("show_error_message", function()
        it("calls vim.notify with ERROR level", function()
            -- Arrange
            local message = "Test error message"

            -- Act
            message_utils.show_error_message(message)

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal(message, captured_calls[1].msg)
            assert.are.equal(vim.log.levels.ERROR, captured_calls[1].level)
        end)

        it("handles error with stack trace", function()
            -- Arrange
            local message = "Error:\n  at line 10\n  in function foo()"

            -- Act
            message_utils.show_error_message(message)

            -- Assert
            assert.are.equal(message, captured_calls[1].msg)
        end)
    end)

    describe("show_debug_message", function()
        it("calls vim.notify with DEBUG level", function()
            -- Arrange
            local message = "Test debug message"

            -- Act
            message_utils.show_debug_message(message)

            -- Assert
            assert.are.equal(1, #captured_calls)
            assert.are.equal(message, captured_calls[1].msg)
            assert.are.equal(vim.log.levels.DEBUG, captured_calls[1].level)
        end)

        it("handles debug with variable dump", function()
            -- Arrange
            local message = "Debug: var = { key = 'value' }"

            -- Act
            message_utils.show_debug_message(message)

            -- Assert
            assert.are.equal(message, captured_calls[1].msg)
        end)
    end)

    describe("multiple messages", function()
        it("handles sequential calls", function()
            -- Act
            message_utils.show_info_message("First")
            message_utils.show_warn_message("Second")
            message_utils.show_error_message("Third")

            -- Assert
            assert.are.equal(3, #captured_calls)
            assert.are.equal("First", captured_calls[1].msg)
            assert.are.equal(vim.log.levels.INFO, captured_calls[1].level)
            assert.are.equal("Second", captured_calls[2].msg)
            assert.are.equal(vim.log.levels.WARN, captured_calls[2].level)
            assert.are.equal("Third", captured_calls[3].msg)
            assert.are.equal(vim.log.levels.ERROR, captured_calls[3].level)
        end)
    end)
end)
