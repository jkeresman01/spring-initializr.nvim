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
-- Unit tests for spring-initializr/commands/commands.lua
--
----------------------------------------------------------------------------

local commands = require("spring-initializr.commands.commands")

describe("commands", function()
    local original_create_user_command
    local created_commands

    before_each(function()
        -- Mock vim.api.nvim_create_user_command
        original_create_user_command = vim.api.nvim_create_user_command
        created_commands = {}
        vim.api.nvim_create_user_command = function(name, callback, opts)
            table.insert(created_commands, {
                name = name,
                callback = callback,
                opts = opts,
            })
        end
    end)

    after_each(function()
        vim.api.nvim_create_user_command = original_create_user_command
    end)

    describe("register_cmd_spring_initializr", function()
        it("creates SpringInitializr command", function()
            -- Act
            commands.register_cmd_spring_initializr()

            -- Assert
            assert.are.equal(1, #created_commands)
            assert.are.equal("SpringInitializr", created_commands[1].name)
            assert.is_function(created_commands[1].callback)
            assert.are.equal("Open Spring Initializr UI", created_commands[1].opts.desc)
        end)
    end)

    describe("register_cmd_spring_generate_project", function()
        it("creates SpringGenerateProject command", function()
            -- Act
            commands.register_cmd_spring_generate_project()

            -- Assert
            assert.are.equal(1, #created_commands)
            assert.are.equal("SpringGenerateProject", created_commands[1].name)
            assert.is_function(created_commands[1].callback)
            assert.are.equal("Generate Spring Boot project to CWD", created_commands[1].opts.desc)
        end)
    end)

    describe("register", function()
        it("registers both commands", function()
            -- Act
            commands.register()

            -- Assert
            assert.are.equal(2, #created_commands)

            local command_names = vim.tbl_map(function(cmd)
                return cmd.name
            end, created_commands)

            assert.is_true(vim.tbl_contains(command_names, "SpringInitializr"))
            assert.is_true(vim.tbl_contains(command_names, "SpringGenerateProject"))
        end)

        it("creates commands with proper descriptions", function()
            -- Act
            commands.register()

            -- Assert
            for _, cmd in ipairs(created_commands) do
                assert.is_not_nil(cmd.opts.desc)
                assert.is_string(cmd.opts.desc)
                assert.is_true(#cmd.opts.desc > 0)
            end
        end)
    end)
end)
