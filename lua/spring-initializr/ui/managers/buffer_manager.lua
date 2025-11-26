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
-- Provides functionality to map close and reset keys to UI components.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
--
-- Register the close key ('q') to close UI in normal mode.
--
-- @param comp      table      Component to register
-- @param close_fn  function   Function to close the UI
--
----------------------------------------------------------------------------
function M.register_close_key(comp, close_fn)
    comp:map("n", "q", function()
        close_fn()
    end, { noremap = true, nowait = true })
end

----------------------------------------------------------------------------
--
-- Register the reset key ('<C-r>') to reset form in normal mode.
--
-- @param comp      table      Component to register
-- @param reset_fn  function   Function to reset the form
--
----------------------------------------------------------------------------
function M.register_reset_key(comp, reset_fn)
    comp:map("n", "<C-r>", function()
        reset_fn()
    end, { noremap = true, nowait = true })
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
