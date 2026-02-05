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
-- spring-initializr.nvim
--
--
-- Copyright (C) 2025 Josip Keresman
--
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Health check module for spring-initializr.nvim.
-- Builds a chain of health-check handlers and runs them in order.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")
local health_float = require("spring-initializr.ui.components.health.health_float")
local nvim_version = require("spring-initializr.health.checks.nvim_version")
local executable = require("spring-initializr.health.checks.executable")
local plugin = require("spring-initializr.health.checks.plugin")
local network = require("spring-initializr.health.checks.network")
local config_check = require("spring-initializr.health.checks.config")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Chain of health-check handlers
----------------------------------------------------------------------------
local chain = {
    nvim_version.new(),
    executable.new("curl", "curl --version", "curl (%S+)"),
    executable.new("unzip", "unzip -v", "UnZip (%S+)"),
    plugin.new("plenary", "plenary.nvim", "nvim-lua/plenary.nvim"),
    plugin.new("nui.popup", "nui.nvim", "MunifTanjim/nui.nvim"),
    plugin.new("telescope", "telescope.nvim", "nvim-telescope/telescope.nvim"),
    network.new(),
    config_check.new(),
}

----------------------------------------------------------------------------
--
-- Runs all health checks and returns structured results.
--
-- @return table  Array of { label, ok, detail } tables
-- @return number Count of failures
--
----------------------------------------------------------------------------
function M.collect_results()
    local results = {}
    local fail_count = 0
    for _, handler in ipairs(chain) do
        local ok, detail = handler.check()
        table.insert(results, { label = handler.label, ok = ok, detail = detail })
        if not ok then
            fail_count = fail_count + 1
        end
    end
    return results, fail_count
end

----------------------------------------------------------------------------
--
-- Entry point: runs all health checks and displays results in a float.
--
----------------------------------------------------------------------------
function M.run()
    log.info("Running health check")

    local results, fail_count = M.collect_results()
    local formatted = health_float.format_results(results, fail_count)
    health_float.show_float(formatted)

    log.fmt_info("Health check complete: %d issue(s)", fail_count)
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
