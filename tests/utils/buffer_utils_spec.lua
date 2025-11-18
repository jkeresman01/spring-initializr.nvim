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
-- Unit tests for spring-initializr/utils/buffer_utils.lua
--
----------------------------------------------------------------------------

local buffer_utils = require("spring-initializr.utils.buffer_utils")

describe("buffer_utils", function()
    describe("collect_all_buffers", function()
        it("collects buffer numbers from components with direct bufnr", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
                { bufnr = 1002 },
                { bufnr = 1003 },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(3, #result)
            assert.are.equal(1001, result[1])
            assert.are.equal(1002, result[2])
            assert.are.equal(1003, result[3])
        end)

        it("collects buffer numbers from components with popup.bufnr", function()
            -- Arrange
            local components = {
                { popup = { bufnr = 2001 } },
                { popup = { bufnr = 2002 } },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(2, #result)
            assert.are.equal(2001, result[1])
            assert.are.equal(2002, result[2])
        end)

        it("collects buffer from outer popup", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }
            local popup = { bufnr = 3000 }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, popup)

            -- Assert
            assert.are.equal(2, #result)
            assert.are.equal(1001, result[1])
            assert.are.equal(3000, result[2])
        end)

        it("handles mixed component types", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
                { popup = { bufnr = 2002 } },
                { bufnr = 1003 },
            }
            local popup = { bufnr = 3000 }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, popup)

            -- Assert
            assert.are.equal(4, #result)
            assert.are.equal(1001, result[1])
            assert.are.equal(2002, result[2])
            assert.are.equal(1003, result[3])
            assert.are.equal(3000, result[4])
        end)

        it("ignores components without bufnr", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
                { other_field = "value" },
                { bufnr = 1002 },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(2, #result)
            assert.are.equal(1001, result[1])
            assert.are.equal(1002, result[2])
        end)

        it("handles empty components list", function()
            -- Arrange
            local components = {}

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(0, #result)
        end)

        it("handles nil popup", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(1, #result)
            assert.are.equal(1001, result[1])
        end)

        it("handles popup without bufnr", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }
            local popup = { other_field = "value" }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, popup)

            -- Assert
            assert.are.equal(1, #result)
            assert.are.equal(1001, result[1])
        end)

        it("prefers direct bufnr over popup.bufnr in component", function()
            -- Arrange
            local components = {
                {
                    bufnr = 1001,
                    popup = { bufnr = 2002 },
                },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(1, #result)
            assert.are.equal(1001, result[1])
        end)
    end)

    describe("setup_close_on_buffer_delete", function()
        local original_create_autocmd
        local autocmd_calls
        local autocmd_callbacks

        before_each(function()
            -- Mock vim.api.nvim_create_autocmd
            original_create_autocmd = vim.api.nvim_create_autocmd
            autocmd_calls = {}
            autocmd_callbacks = {}

            vim.api.nvim_create_autocmd = function(events, opts)
                table.insert(autocmd_calls, {
                    events = events,
                    buffer = opts.buffer,
                    once = opts.once,
                })
                autocmd_callbacks[opts.buffer] = opts.callback
                return #autocmd_calls
            end
        end)

        after_each(function()
            vim.api.nvim_create_autocmd = original_create_autocmd
        end)

        it("creates autocmds for all component buffers", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
                { bufnr = 1002 },
                { bufnr = 1003 },
            }
            local close_fn = function() end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)

            -- Assert
            assert.are.equal(3, #autocmd_calls)
        end)

        it("creates autocmd for outer popup buffer", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }
            local popup = { bufnr = 3000 }
            local close_fn = function() end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, popup, close_fn)

            -- Assert
            assert.are.equal(2, #autocmd_calls)
            local popup_autocmd = autocmd_calls[2]
            assert.are.equal(3000, popup_autocmd.buffer)
        end)

        it("uses correct autocmd events", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }
            local close_fn = function() end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)

            -- Assert
            local events = autocmd_calls[1].events
            assert.are.equal(2, #events)
            assert.is_true(vim.tbl_contains(events, "BufDelete"))
            assert.is_true(vim.tbl_contains(events, "BufWipeout"))
        end)

        it("sets autocmd to trigger once", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
            }
            local close_fn = function() end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)

            -- Assert
            assert.is_true(autocmd_calls[1].once)
        end)

        it("attaches callback to correct buffer", function()
            -- Arrange
            local components = {
                { bufnr = 1001 },
                { bufnr = 1002 },
            }
            local close_fn = function() end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)

            -- Assert
            assert.are.equal(1001, autocmd_calls[1].buffer)
            assert.are.equal(1002, autocmd_calls[2].buffer)
        end)

        it("callback is wrapped in vim.schedule", function()
            -- Arrange
            local original_schedule = vim.schedule
            local schedule_called = false
            local scheduled_fn

            vim.schedule = function(fn)
                schedule_called = true
                scheduled_fn = fn
            end

            local components = {
                { bufnr = 1001 },
            }
            local close_called = false
            local close_fn = function()
                close_called = true
            end

            -- Act
            buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)
            local callback = autocmd_callbacks[1001]
            callback()

            -- Assert
            assert.is_true(schedule_called)
            assert.is_not_nil(scheduled_fn)

            -- Execute the scheduled function
            scheduled_fn()
            assert.is_true(close_called)

            -- Cleanup
            vim.schedule = original_schedule
        end)

        it("handles empty components list", function()
            -- Arrange
            local components = {}
            local close_fn = function() end

            -- Act & Assert - should not throw
            assert.has_no.errors(function()
                buffer_utils.setup_close_on_buffer_delete(components, nil, close_fn)
            end)
            assert.are.equal(0, #autocmd_calls)
        end)
    end)

    describe("edge cases", function()
        it("handles components with nested popup structures", function()
            -- Arrange
            local components = {
                {
                    popup = {
                        bufnr = 2001,
                        nested = { data = "value" },
                    },
                },
            }

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(1, #result)
            assert.are.equal(2001, result[1])
        end)

        it("handles large number of components", function()
            -- Arrange
            local components = {}
            for i = 1, 100 do
                table.insert(components, { bufnr = 1000 + i })
            end

            -- Act
            local result = buffer_utils.collect_all_buffers(components, nil)

            -- Assert
            assert.are.equal(100, #result)
            assert.are.equal(1001, result[1])
            assert.are.equal(1100, result[100])
        end)
    end)
end)
