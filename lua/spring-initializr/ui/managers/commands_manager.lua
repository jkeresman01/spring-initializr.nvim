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
-- Manages blocking of split commands while Spring Initializr UI is active.
-- Detects splits and automatically restores the UI layout.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local log = require("spring-initializr.trace.log")
local events = require("spring-initializr.events.events")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        blocked = false,
        close_callback = nil,
        reopen_callback = nil,
        ui_windows = {},
        winnew_autocmd_id = nil,
        is_handling_split = false,
    },
}

----------------------------------------------------------------------------
--
-- Handle split detection - close and reopen UI to restore layout.
--
----------------------------------------------------------------------------
local function handle_split_detected()
    -- Prevent recursive handling
    if M.state.is_handling_split then
        return
    end

    M.state.is_handling_split = true
    log.info("Split detected - restoring UI layout")

    local close_cb = M.state.close_callback
    local reopen_cb = M.state.reopen_callback

    if close_cb and reopen_cb then
        vim.schedule(function()
            close_cb()

            vim.defer_fn(function()
                reopen_cb()
                M.state.is_handling_split = false
            end, 10)
        end)
    else
        M.state.is_handling_split = false
    end
end

----------------------------------------------------------------------------
--
-- Check if a window is a UI window.
--
-- @param winid  number  Window ID
-- @return boolean  True if it's a UI window
--
----------------------------------------------------------------------------
local function is_ui_window(winid)
    return M.state.ui_windows[winid] == true
end

----------------------------------------------------------------------------
--
-- Check if a window is floating.
--
-- @param winid  number  Window ID
-- @return boolean  True if window is floating
--
----------------------------------------------------------------------------
local function is_floating(winid)
    local config = vim.api.nvim_win_get_config(winid)
    return config.relative ~= ""
end

----------------------------------------------------------------------------
--
-- Set up WinNew autocmd to detect actual splits.
--
----------------------------------------------------------------------------
local function setup_winnew_detector()
    if M.state.winnew_autocmd_id then
        return
    end

    M.state.winnew_autocmd_id = vim.api.nvim_create_autocmd(events.WIN_NEW, {
        callback = function()
            -- Skip if already handling a split
            if M.state.is_handling_split then
                return
            end

            -- Only process if we have callbacks
            if not M.state.close_callback or not M.state.reopen_callback then
                return
            end

            local new_win = vim.api.nvim_get_current_win()

            -- Check if window is valid
            if not vim.api.nvim_win_is_valid(new_win) then
                return
            end

            -- Ignore floating windows (Telescope, popups, etc.)
            if is_floating(new_win) then
                return
            end

            -- Ignore if it's a UI window
            if is_ui_window(new_win) then
                return
            end

            -- This is a non-floating, non-UI window - it's a split!
            log.fmt_warn("Split detected (window %d) - restoring layout", new_win)
            handle_split_detected()
        end,
        desc = "Spring Initializr split detector",
    })

    log.debug("WinNew detector autocmd created")
end

----------------------------------------------------------------------------
--
-- Remove WinNew detector autocmd.
--
----------------------------------------------------------------------------
local function remove_winnew_detector()
    if M.state.winnew_autocmd_id then
        vim.api.nvim_del_autocmd(M.state.winnew_autocmd_id)
        M.state.winnew_autocmd_id = nil
        log.debug("WinNew detector autocmd removed")
    end
end

----------------------------------------------------------------------------
--
-- Set the callbacks and UI windows.
--
-- @param close_callback  function  Function to call to close the UI
-- @param reopen_callback  function  Function to call to reopen the UI
-- @param windows  table  List of UI window IDs
--
----------------------------------------------------------------------------
function M.set_callbacks_and_windows(close_callback, reopen_callback, windows)
    M.state.close_callback = close_callback
    M.state.reopen_callback = reopen_callback
    M.state.ui_windows = {}

    for _, winid in ipairs(windows or {}) do
        M.state.ui_windows[winid] = true
    end

    log.fmt_debug("Callbacks set, registered %d UI windows", vim.tbl_count(M.state.ui_windows))
end

----------------------------------------------------------------------------
--
-- Block split operations by detecting and auto-fixing them.
--
----------------------------------------------------------------------------
function M.block_splits()
    if M.state.blocked then
        log.debug("Splits already blocked, skipping")
        return
    end

    log.info("Setting up split auto-fix")

    -- Delay setup to avoid triggering during UI creation
    vim.schedule(function()
        setup_winnew_detector()
    end)

    M.state.blocked = true
    log.debug("Split auto-fix set up successfully")
end

----------------------------------------------------------------------------
--
-- Unblock split operations.
--
----------------------------------------------------------------------------
function M.unblock_splits()
    if not M.state.blocked then
        log.debug("Splits not blocked, skipping unblock")
        return
    end

    log.info("Removing split auto-fix")

    remove_winnew_detector()

    M.state.blocked = false
    M.state.close_callback = nil
    M.state.reopen_callback = nil
    M.state.ui_windows = {}
    M.state.is_handling_split = false
    log.debug("Split auto-fix removed successfully")
end

----------------------------------------------------------------------------
--
-- Check if splits are currently blocked.
--
-- @return boolean  True if splits are blocked
--
----------------------------------------------------------------------------
function M.is_blocked()
    return M.state.blocked
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
