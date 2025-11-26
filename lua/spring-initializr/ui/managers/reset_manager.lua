---------------------------------------------------------------------------
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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Provides functionality to reset form selections to defaults
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local message_utils = require("spring-initializr.utils.message_utils")
local telescope = require("spring-initializr.telescope.telescope")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        reset_handlers = {},
    },
}

----------------------------------------------------------------------------
-- Default values for input fields
----------------------------------------------------------------------------
local DEFAULT_VALUES = {
    groupId = "com.example",
    artifactId = "demo",
    name = "demo",
    description = "Demo project for Spring Boot",
    packageName = "com.example.demo",
}

----------------------------------------------------------------------------
--
-- Register a reset handler function.
--
-- @param handler  function  Function to call when reset is triggered
--
----------------------------------------------------------------------------
function M.register_reset_handler(handler)
    table.insert(M.state.reset_handlers, handler)
end

----------------------------------------------------------------------------
--
-- Clear all registered reset handlers.
--
----------------------------------------------------------------------------
function M.clear_handlers()
    M.state.reset_handlers = {}
end

----------------------------------------------------------------------------
--
-- Reset selections to default values.
--
-- @param selections  table  Selections table to reset
--
----------------------------------------------------------------------------
local function reset_selections(selections)
    -- Reset input fields to defaults
    for key, default_value in pairs(DEFAULT_VALUES) do
        selections[key] = default_value
    end
end

----------------------------------------------------------------------------
--
-- Clear selected dependencies.
--
----------------------------------------------------------------------------
local function clear_dependencies()
    telescope.selected_dependencies = {}
    telescope.selected_dependencies_full = {}
    if telescope.selected_set then
        telescope.selected_set:clear()
    end
end

----------------------------------------------------------------------------
--
-- Execute all registered reset handlers.
--
----------------------------------------------------------------------------
local function execute_reset_handlers()
    for _, handler in ipairs(M.state.reset_handlers) do
        pcall(handler)
    end
end

----------------------------------------------------------------------------
--
-- Show reset confirmation message.
--
----------------------------------------------------------------------------
local function show_reset_message()
    message_utils.show_info_message("Form reset to defaults")
end

----------------------------------------------------------------------------
--
-- Reset all form selections and dependencies to defaults.
--
-- @param selections  table  Selections table to reset
--
----------------------------------------------------------------------------
function M.reset_form(selections)
    reset_selections(selections)
    clear_dependencies()
    execute_reset_handlers()
    show_reset_message()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
