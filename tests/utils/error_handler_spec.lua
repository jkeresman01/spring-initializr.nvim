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
-- Unit tests for spring-initializr/errors/error_handler.lua
--
----------------------------------------------------------------------------

local error_handler = require("spring-initializr.errors.error_handler")
local log = require("spring-initializr.trace.log")

describe("error_handler", function()
    local original_schedule
    local original_log_error

    before_each(function()
        original_schedule = vim.schedule
        original_log_error = log.error
    end)

    after_each(function()
        vim.schedule = original_schedule
        log.error = original_log_error
    end)

    describe("safe_call", function()
        it("returns success and function result when call succeeds", function()
            local ok, result = error_handler.safe_call(function(a, b)
                return a + b
            end, nil, nil, 2, 3)

            assert.is_true(ok)
            assert.are.equal(5, result)
        end)

        it("returns default value and logs when call fails", function()
            local logged = {}
            log.error = function(...)
                logged = { ... }
            end

            local ok, result = error_handler.safe_call(function()
                error("boom")
            end, "Operation failed:", "fallback")

            assert.is_false(ok)
            assert.are.equal("fallback", result)
            assert.are.equal("Operation failed:", logged[1])
            assert.is_truthy(logged[2])
        end)

        it("does not log when error message is omitted", function()
            local called = false
            log.error = function()
                called = true
            end

            local ok, result = error_handler.safe_call(function()
                error("boom")
            end, nil, "fallback")

            assert.is_false(ok)
            assert.are.equal("fallback", result)
            assert.is_false(called)
        end)
    end)

    describe("with_schedule", function()
        it("schedules wrapped function and passes arguments", function()
            local scheduled_fn
            local received = nil
            vim.schedule = function(fn)
                scheduled_fn = fn
            end

            local wrapped = error_handler.with_schedule(function(value)
                received = value
            end)

            wrapped("test")
            assert.is_not_nil(scheduled_fn)

            scheduled_fn()
            assert.are.equal("test", received)
        end)

        it("logs scheduled errors through safe_call", function()
            local scheduled_fn
            local logged = {}
            vim.schedule = function(fn)
                scheduled_fn = fn
            end
            log.error = function(...)
                logged = { ... }
            end

            local wrapped = error_handler.with_schedule(function()
                error("scheduled boom")
            end, "Scheduled failure:")

            wrapped()
            scheduled_fn()

            assert.are.equal("Scheduled failure:", logged[1])
            assert.is_truthy(logged[2])
        end)
    end)
end)
