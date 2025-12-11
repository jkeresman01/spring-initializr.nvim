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
-- Defines and applies highlight groups for the Spring Initializr UI.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

-----------------------------------------------------------------------------
--
-- Sets highlight groups used by the plugin.
--
-----------------------------------------------------------------------------
local function set_highlight_groups()
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#777777" })
    vim.api.nvim_set_hl(0, "NuiMenuSel", { bg = "#44475a", fg = "#ffffff", bold = true })
end

-----------------------------------------------------------------------------
--
-- Registers a ColorScheme autocmd to reapply highlights.
--
-----------------------------------------------------------------------------
local function register_colorscheme_autocmd()
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "*",
        callback = M.configure,
    })
end

-----------------------------------------------------------------------------
--
-- Public method to configure all highlights and hooks.
--
-----------------------------------------------------------------------------
function M.configure()
    set_highlight_groups()
    register_colorscheme_autocmd()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
