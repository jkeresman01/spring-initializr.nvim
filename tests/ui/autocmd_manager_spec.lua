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
-- Unit tests for spring-initializr/ui/managers/autocmd_manager.lua
--
----------------------------------------------------------------------------

local autocmd_manager = require("spring-initializr.ui.managers.autocmd_manager")
local events = require("spring-initializr.events.events")

describe("autocmd_manager", function()
    local original_create
    local original_delete
    local create_calls
    local delete_calls

    before_each(function()
        original_create = vim.api.nvim_create_autocmd
        original_delete = vim.api.nvim_del_autocmd
        create_calls = {}
        delete_calls = {}
        autocmd_manager.state.resize_autocmd_id = nil

        vim.api.nvim_create_autocmd = function(event, opts)
            table.insert(create_calls, { event = event, opts = opts })
            return 42 + #create_calls
        end

        vim.api.nvim_del_autocmd = function(id)
            table.insert(delete_calls, id)
        end
    end)

    after_each(function()
        vim.api.nvim_create_autocmd = original_create
        vim.api.nvim_del_autocmd = original_delete
        autocmd_manager.state.resize_autocmd_id = nil
    end)

    it("creates a resize autocmd using the VimResized event", function()
        -- Arrange
        local callback = function() end

        -- Act
        local id = autocmd_manager.setup_resize_autocmd(callback)

        -- Assert
        assert.are.equal(43, id)
        assert.are.equal(1, #create_calls)
        assert.are.equal(events.VIM_RESIZED, create_calls[1].event)
        assert.are.equal(callback, create_calls[1].opts.callback)
        assert.are.equal(43, autocmd_manager.state.resize_autocmd_id)
    end)

    it("replaces an existing resize autocmd before creating a new one", function()
        -- Arrange
        autocmd_manager.state.resize_autocmd_id = 99

        -- Act
        autocmd_manager.setup_resize_autocmd(function() end)

        -- Assert
        assert.are.same({ 99 }, delete_calls)
        assert.are.equal(43, autocmd_manager.state.resize_autocmd_id)
    end)

    it("removes the active resize autocmd", function()
        -- Arrange
        autocmd_manager.state.resize_autocmd_id = 77

        -- Act
        autocmd_manager.remove_resize_autocmd()

        -- Assert
        assert.are.same({ 77 }, delete_calls)
        assert.is_nil(autocmd_manager.state.resize_autocmd_id)
    end)

    it("does nothing when there is no resize autocmd", function()
        -- Act
        autocmd_manager.remove_resize_autocmd()

        -- Assert
        assert.are.equal(0, #delete_calls)
    end)
end)
