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
-- Unit tests for spring-initializr/health
--
----------------------------------------------------------------------------

local health = require("spring-initializr.health.health")
local health_float = require("spring-initializr.ui.components.health.health_float")
local config = require("spring-initializr.config.config")

local nvim_version = require("spring-initializr.health.checks.nvim_version")
local executable = require("spring-initializr.health.checks.executable")
local plugin = require("spring-initializr.health.checks.plugin")
local config_check = require("spring-initializr.health.checks.config")

describe("health", function()
    describe("nvim_version checker", function()
        it("has correct label", function()
            -- Act
            local handler = nvim_version.new()

            -- Assert
            assert.are.equal("Neovim version", handler.label)
        end)

        it("passes on current Neovim version", function()
            -- Act
            local handler = nvim_version.new()
            local ok, detail = handler.check()

            -- Assert
            assert.is_string(detail)
            assert.is_true(detail:match("%d+%.%d+%.%d+") ~= nil)

            -- If Neovim >= 0.10.0, should pass
            local v = vim.version()
            if v.major > 0 or (v.major == 0 and v.minor >= 10) then
                assert.is_true(ok)
            end
        end)
    end)

    describe("executable checker", function()
        it("has correct label", function()
            -- Act
            local handler = executable.new("ls", "ls --version", "(%S+)")

            -- Assert
            assert.are.equal("ls", handler.label)
        end)

        it("detects an installed executable", function()
            -- Act
            local handler = executable.new("ls", "ls --version", "(%S+)")
            local ok, detail = handler.check()

            -- Assert
            assert.is_true(ok)
            assert.is_string(detail)
        end)

        it("reports missing executable", function()
            -- Act
            local handler = executable.new(
                "nonexistent_binary_xyz_123",
                "nonexistent_binary_xyz_123 --version",
                "(%S+)"
            )
            local ok, detail = handler.check()

            -- Assert
            assert.is_false(ok)
            assert.is_true(detail:find("not found") ~= nil)
        end)
    end)

    describe("plugin checker", function()
        it("has correct label", function()
            -- Act
            local handler = plugin.new(
                "spring-initializr.health.health",
                "health.lua",
                "test/health"
            )

            -- Assert
            assert.are.equal("health.lua", handler.label)
        end)

        it("detects a loaded plugin", function()
            -- Act
            local handler = plugin.new(
                "spring-initializr.health.health",
                "health.lua",
                "test/health"
            )
            local ok, detail = handler.check()

            -- Assert
            assert.is_true(ok)
            assert.are.equal("loaded", detail)
        end)

        it("reports missing plugin", function()
            -- Act
            local handler = plugin.new(
                "nonexistent_plugin_xyz_123",
                "nonexistent",
                "test/nonexistent"
            )
            local ok, detail = handler.check()

            -- Assert
            assert.is_false(ok)
            assert.is_true(detail:find("not found") ~= nil)
        end)
    end)

    describe("config checker", function()
        it("has correct label", function()
            -- Act
            local handler = config_check.new()

            -- Assert
            assert.are.equal("Configuration", handler.label)
        end)

        it("passes with default configuration", function()
            -- Arrange
            config.config_format = "properties"
            config.use_nerd_fonts = true

            -- Act
            local handler = config_check.new()
            local ok, detail = handler.check()

            -- Assert
            assert.is_true(ok)
            assert.are.equal("valid", detail)
        end)

        it("passes with yaml config format", function()
            -- Arrange
            config.config_format = "yaml"
            config.use_nerd_fonts = false

            -- Act
            local handler = config_check.new()
            local ok, detail = handler.check()

            -- Assert
            assert.is_true(ok)
            assert.are.equal("valid", detail)
        end)

        it("fails with invalid config_format", function()
            -- Arrange
            config.config_format = "toml"
            config.use_nerd_fonts = true

            -- Act
            local handler = config_check.new()
            local ok, detail = handler.check()

            -- Assert
            assert.is_false(ok)
            assert.is_true(detail:find("toml") ~= nil)

            -- Cleanup
            config.config_format = "properties"
        end)

        it("fails with non-boolean use_nerd_fonts", function()
            -- Arrange
            config.config_format = "properties"
            config.use_nerd_fonts = "yes"

            -- Act
            local handler = config_check.new()
            local ok, detail = handler.check()

            -- Assert
            assert.is_false(ok)
            assert.is_true(detail:find("string") ~= nil)

            -- Cleanup
            config.use_nerd_fonts = true
        end)
    end)

    describe("collect_results", function()
        it("returns results for all handlers in the chain", function()
            -- Act
            local results, fail_count = health.collect_results()

            -- Assert
            assert.is_table(results)
            assert.is_true(#results >= 8)
            assert.is_number(fail_count)

            -- Each result has the expected structure
            for _, r in ipairs(results) do
                assert.is_string(r.label)
                assert.is_boolean(r.ok)
                assert.is_string(r.detail)
            end
        end)
    end)

    describe("format_results", function()
        it("formats all-pass results with success status", function()
            -- Arrange
            local results = {
                { label = "TestA", ok = true, detail = "good" },
                { label = "TestB", ok = true, detail = "fine" },
            }

            -- Act
            local lines = health_float.format_results(results, 0)

            -- Assert
            local text = ""
            for _, line in ipairs(lines) do
                text = text .. line.text .. "\n"
            end
            assert.is_true(text:find("All checks passed") ~= nil)
            assert.is_true(text:find("✓ TestA: good") ~= nil)
            assert.is_true(text:find("✓ TestB: fine") ~= nil)
        end)

        it("formats failed results with failure count", function()
            -- Arrange
            local results = {
                { label = "TestA", ok = true, detail = "good" },
                { label = "TestB", ok = false, detail = "broken" },
            }

            -- Act
            local lines = health_float.format_results(results, 1)

            -- Assert
            local text = ""
            for _, line in ipairs(lines) do
                text = text .. line.text .. "\n"
            end
            assert.is_true(text:find("1 issue%(s%) found") ~= nil)
            assert.is_true(text:find("✓ TestA: good") ~= nil)
            assert.is_true(text:find("✗ TestB: broken") ~= nil)
        end)

        it("applies correct highlight groups", function()
            -- Arrange
            local results = {
                { label = "Pass", ok = true, detail = "ok" },
                { label = "Fail", ok = false, detail = "bad" },
            }

            -- Act
            local lines = health_float.format_results(results, 1)

            -- Assert
            local pass_line, fail_line
            for _, line in ipairs(lines) do
                if line.text:find("Pass") then
                    pass_line = line
                end
                if line.text:find("Fail") then
                    fail_line = line
                end
            end

            assert.are.equal("DiagnosticOk", pass_line.hl)
            assert.are.equal("DiagnosticError", fail_line.hl)
        end)

        it("includes title and separators", function()
            -- Arrange
            local results = {}

            -- Act
            local lines = health_float.format_results(results, 0)

            -- Assert
            assert.are.equal("Title", lines[1].hl)
            assert.is_true(lines[1].text:find("Spring Initializr Health Check") ~= nil)
            assert.are.equal("Comment", lines[2].hl)
        end)
    end)
end)
