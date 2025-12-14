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
-- Unit tests for spring-initializr/ui/managers/commands_manager.lua
--
----------------------------------------------------------------------------

describe("commands_manager", function()
    local commands_manager
    local mock_close_callback
    local mock_reopen_callback

    before_each(function()
        -- Clear any cached module
        package.loaded["spring-initializr.ui.managers.commands_manager"] = nil

        -- Mock vim.api functions
        _G.vim = _G.vim or {}
        _G.vim.api = _G.vim.api or {}
        _G.vim.schedule = function(fn)
            fn()
        end
        _G.vim.defer_fn = function(fn, delay)
            fn()
        end
        _G.vim.notify = function() end
        _G.vim.tbl_count = function(t)
            local count = 0
            for _ in pairs(t) do
                count = count + 1
            end
            return count
        end

        -- Mock autocmd functions
        _G.vim.api.nvim_create_autocmd = function(event, opts)
            return 12345 -- Mock autocmd ID
        end
        _G.vim.api.nvim_del_autocmd = function(id) end
        _G.vim.api.nvim_win_is_valid = function(winid)
            return true
        end
        _G.vim.api.nvim_win_get_config = function(winid)
            -- Default to non-floating
            return { relative = "" }
        end

        -- Create mock callbacks
        mock_close_callback = spy.new(function() end)
        mock_reopen_callback = spy.new(function() end)

        -- Load the module
        commands_manager = require("spring-initializr.ui.managers.commands_manager")
    end)

    after_each(function()
        -- Clean up
        package.loaded["spring-initializr.ui.managers.commands_manager"] = nil
        _G.vim = nil
    end)

    describe("initial state", function()
        it("should start with blocked = false", function()
            assert.is_false(commands_manager.is_blocked())
        end)

        it("should have empty state", function()
            assert.is_false(commands_manager.state.blocked)
            assert.is_nil(commands_manager.state.close_callback)
            assert.is_nil(commands_manager.state.reopen_callback)
            assert.are.same({}, commands_manager.state.ui_windows)
            assert.is_nil(commands_manager.state.winnew_autocmd_id)
            assert.is_false(commands_manager.state.is_handling_split)
        end)
    end)

    describe("set_callbacks_and_windows", function()
        it("should store callbacks and windows", function()
            local windows = { 1000, 2000, 3000 }

            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                windows
            )

            assert.equals(mock_close_callback, commands_manager.state.close_callback)
            assert.equals(mock_reopen_callback, commands_manager.state.reopen_callback)
            assert.is_true(commands_manager.state.ui_windows[1000])
            assert.is_true(commands_manager.state.ui_windows[2000])
            assert.is_true(commands_manager.state.ui_windows[3000])
        end)

        it("should handle empty windows list", function()
            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                {}
            )

            assert.equals(mock_close_callback, commands_manager.state.close_callback)
            assert.equals(mock_reopen_callback, commands_manager.state.reopen_callback)
            assert.are.same({}, commands_manager.state.ui_windows)
        end)

        it("should handle nil windows list", function()
            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                nil
            )

            assert.equals(mock_close_callback, commands_manager.state.close_callback)
            assert.equals(mock_reopen_callback, commands_manager.state.reopen_callback)
            assert.are.same({}, commands_manager.state.ui_windows)
        end)
    end)

    describe("block_splits", function()
        it("should set up WinNew autocmd", function()
            local create_autocmd_spy = spy.on(_G.vim.api, "nvim_create_autocmd")

            commands_manager.block_splits()

            -- Wait for scheduled function
            assert.spy(create_autocmd_spy).was_called()
            assert.spy(create_autocmd_spy).was_called_with("WinNew", match.is_table())
        end)

        it("should set blocked to true", function()
            commands_manager.block_splits()

            assert.is_true(commands_manager.is_blocked())
            assert.is_true(commands_manager.state.blocked)
        end)

        it("should be idempotent", function()
            local create_autocmd_spy = spy.on(_G.vim.api, "nvim_create_autocmd")

            commands_manager.block_splits()
            commands_manager.block_splits()

            -- Should only create autocmd once (after first schedule)
            assert.is_true(commands_manager.is_blocked())
        end)
    end)

    describe("unblock_splits", function()
        it("should remove WinNew autocmd", function()
            local del_autocmd_spy = spy.on(_G.vim.api, "nvim_del_autocmd")

            commands_manager.block_splits()
            commands_manager.unblock_splits()

            assert.spy(del_autocmd_spy).was_called()
        end)

        it("should set blocked to false", function()
            commands_manager.block_splits()
            commands_manager.unblock_splits()

            assert.is_false(commands_manager.is_blocked())
            assert.is_false(commands_manager.state.blocked)
        end)

        it("should clear state", function()
            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                { 1000, 2000 }
            )
            commands_manager.block_splits()
            commands_manager.unblock_splits()

            assert.is_nil(commands_manager.state.close_callback)
            assert.is_nil(commands_manager.state.reopen_callback)
            assert.are.same({}, commands_manager.state.ui_windows)
            assert.is_nil(commands_manager.state.winnew_autocmd_id)
            assert.is_false(commands_manager.state.is_handling_split)
        end)

        it("should be idempotent", function()
            commands_manager.unblock_splits()
            commands_manager.unblock_splits()

            assert.is_false(commands_manager.is_blocked())
        end)
    end)

    describe("split detection and auto-fix", function()
        local autocmd_callback

        before_each(function()
            -- Capture the autocmd callback
            _G.vim.api.nvim_create_autocmd = function(event, opts)
                autocmd_callback = opts.callback
                return 12345
            end

            -- Set up commands_manager
            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                { 1000, 2000 }
            )
            commands_manager.block_splits()
        end)

        it("should ignore floating windows", function()
            _G.vim.api.nvim_get_current_win = function()
                return 3000
            end
            _G.vim.api.nvim_win_get_config = function(winid)
                return { relative = "editor" } -- Floating window
            end

            autocmd_callback()

            assert.spy(mock_close_callback).was_not_called()
            assert.spy(mock_reopen_callback).was_not_called()
        end)

        it("should ignore UI windows", function()
            _G.vim.api.nvim_get_current_win = function()
                return 1000
            end
            _G.vim.api.nvim_win_get_config = function(winid)
                return { relative = "" } -- Non-floating
            end

            autocmd_callback()

            assert.spy(mock_close_callback).was_not_called()
            assert.spy(mock_reopen_callback).was_not_called()
        end)

        it("should detect non-floating, non-UI windows and trigger auto-fix", function()
            _G.vim.api.nvim_get_current_win = function()
                return 3000
            end
            _G.vim.api.nvim_win_get_config = function(winid)
                return { relative = "" } -- Non-floating
            end

            local notify_spy = spy.on(_G.vim, "notify")

            autocmd_callback()

            assert.spy(mock_close_callback).was_called(1)
            assert.spy(mock_reopen_callback).was_called(1)
            assert.spy(notify_spy).was_called_with("Restoring UI layout...", match._)
        end)

        it("should not process if callbacks are not set", function()
            commands_manager.state.close_callback = nil
            commands_manager.state.reopen_callback = nil

            _G.vim.api.nvim_get_current_win = function()
                return 3000
            end
            _G.vim.api.nvim_win_get_config = function(winid)
                return { relative = "" }
            end

            autocmd_callback()

            assert.spy(mock_close_callback).was_not_called()
            assert.spy(mock_reopen_callback).was_not_called()
        end)

        it("should prevent recursive handling", function()
            _G.vim.api.nvim_get_current_win = function()
                return 3000
            end
            _G.vim.api.nvim_win_get_config = function(winid)
                return { relative = "" }
            end

            -- Set handling flag
            commands_manager.state.is_handling_split = true

            autocmd_callback()

            assert.spy(mock_close_callback).was_not_called()
            assert.spy(mock_reopen_callback).was_not_called()
        end)

        it("should ignore invalid windows", function()
            _G.vim.api.nvim_get_current_win = function()
                return 3000
            end
            _G.vim.api.nvim_win_is_valid = function(winid)
                return false
            end

            autocmd_callback()

            assert.spy(mock_close_callback).was_not_called()
            assert.spy(mock_reopen_callback).was_not_called()
        end)
    end)

    describe("integration workflow", function()
        it("should complete full lifecycle", function()
            -- Setup
            commands_manager.set_callbacks_and_windows(
                mock_close_callback,
                mock_reopen_callback,
                { 1000, 2000, 3000 }
            )

            assert.equals(3, vim.tbl_count(commands_manager.state.ui_windows))

            -- Block
            commands_manager.block_splits()
            assert.is_true(commands_manager.is_blocked())

            -- Unblock
            commands_manager.unblock_splits()
            assert.is_false(commands_manager.is_blocked())
            assert.are.same({}, commands_manager.state.ui_windows)
        end)

        it("should handle multiple block/unblock cycles", function()
            for i = 1, 3 do
                commands_manager.set_callbacks_and_windows(
                    mock_close_callback,
                    mock_reopen_callback,
                    { 1000 }
                )
                commands_manager.block_splits()
                assert.is_true(commands_manager.is_blocked())

                commands_manager.unblock_splits()
                assert.is_false(commands_manager.is_blocked())
            end
        end)
    end)
end)
