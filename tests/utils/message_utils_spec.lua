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

local message_utils = require("spring-initializr.utils.message_utils")

describe("message_utils", function()
    local original_notify
    local notify_calls

    before_each(function()
        -- Save original vim.notify
        original_notify = vim.notify
        notify_calls = {}

        -- Mock vim.notify to capture calls
        vim.notify = function(msg, level, opts)
            table.insert(notify_calls, {
                message = msg,
                level = level,
                opts = opts,
            })
        end
    end)

    after_each(function()
        -- Restore original vim.notify
        vim.notify = original_notify
        notify_calls = {}
    end)

    describe("show_info_message", function()
        it("calls vim.notify with INFO level", function()
            local test_message = "Test info message"

            message_utils.show_info_message(test_message)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(test_message, notify_calls[1].message)
            assert.are.equal(vim.log.levels.INFO, notify_calls[1].level)
        end)

        it("handles empty string", function()
            message_utils.show_info_message("")

            assert.are.equal(1, #notify_calls)
            assert.are.equal("", notify_calls[1].message)
        end)

        it("handles multiline message", function()
            local multiline = "Line 1\nLine 2\nLine 3"

            message_utils.show_info_message(multiline)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(multiline, notify_calls[1].message)
        end)
    end)

    describe("show_warn_message", function()
        it("calls vim.notify with WARN level", function()
            local test_message = "Test warning message"

            message_utils.show_warn_message(test_message)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(test_message, notify_calls[1].message)
            assert.are.equal(vim.log.levels.WARN, notify_calls[1].level)
        end)

        it("handles warning with special characters", function()
            local warning = "Warning: File 'test.txt' not found!"

            message_utils.show_warn_message(warning)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(warning, notify_calls[1].message)
            assert.are.equal(vim.log.levels.WARN, notify_calls[1].level)
        end)
    end)

    describe("show_error_message", function()
        it("calls vim.notify with ERROR level", function()
            local test_message = "Test error message"

            message_utils.show_error_message(test_message)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(test_message, notify_calls[1].message)
            assert.are.equal(vim.log.levels.ERROR, notify_calls[1].level)
        end)

        it("handles error with stack trace", function()
            local error_msg = "Error:\n  at line 10\n  in function foo()"

            message_utils.show_error_message(error_msg)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(error_msg, notify_calls[1].message)
            assert.are.equal(vim.log.levels.ERROR, notify_calls[1].level)
        end)
    end)

    describe("show_debug_message", function()
        it("calls vim.notify with DEBUG level", function()
            local test_message = "Test debug message"

            message_utils.show_debug_message(test_message)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(test_message, notify_calls[1].message)
            assert.are.equal(vim.log.levels.DEBUG, notify_calls[1].level)
        end)

        it("handles debug with variable dump", function()
            local debug_msg = "Debug: var = { key = 'value' }"

            message_utils.show_debug_message(debug_msg)

            assert.are.equal(1, #notify_calls)
            assert.are.equal(debug_msg, notify_calls[1].message)
            assert.are.equal(vim.log.levels.DEBUG, notify_calls[1].level)
        end)
    end)

    describe("multiple messages", function()
        it("handles sequential calls", function()
            message_utils.show_info_message("First")
            message_utils.show_warn_message("Second")
            message_utils.show_error_message("Third")

            assert.are.equal(3, #notify_calls)
            assert.are.equal(vim.log.levels.INFO, notify_calls[1].level)
            assert.are.equal(vim.log.levels.WARN, notify_calls[2].level)
            assert.are.equal(vim.log.levels.ERROR, notify_calls[3].level)
        end)
    end)
end)
