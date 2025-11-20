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
-- Provides simple HTTP-related utilities for downloading files.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local curl = require("plenary.curl")

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {}

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local DOWNLOAD_TIMEOUT = 30000 -- 30 seconds

----------------------------------------------------------------------------
--
-- Handles download completion.
--
-- @param  response    table     Response from plenary.curl
-- @param  on_success  function  Callback on success
-- @param  on_error    function  Callback on error
--
----------------------------------------------------------------------------
local function handle_download_response(response, on_success, on_error)
    vim.schedule(function()
        if response.exit ~= 0 then
            on_error()
            return
        end

        if response.status < 200 or response.status >= 300 then
            on_error()
            return
        end

        on_success()
    end)
end

----------------------------------------------------------------------------
--
-- Downloads a file from a URL to a given output path using plenary.curl.
--
-- @param  url          string     URL to download
-- @param  output_path  string     Destination file path
-- @param  on_success   function   Callback on success
-- @param  on_error     function   Callback on error
--
----------------------------------------------------------------------------
function M.download_file(url, output_path, on_success, on_error)
    local response = curl.get(url, {
        output = output_path,
        timeout = DOWNLOAD_TIMEOUT,
    })

    handle_download_response(response, on_success, on_error)
end

return M
