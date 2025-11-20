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
----------------------------------------------------------------------------

----------------------------------------------------------------------------
--
-- Handles fetching and caching of Spring Initializr metadata.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local curl = require("plenary.curl")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local METADATA_URL = "https://start.spring.io/metadata/client"
local REQUEST_TIMEOUT = 10000 -- 10 seconds

----------------------------------------------------------------------------
-- Module table
----------------------------------------------------------------------------
local M = {
    state = {
        metadata = nil,
        loaded = false,
        error = nil,
        loading = false,
        callbacks = {},
    },
}

----------------------------------------------------------------------------
--
-- Calls all registered callbacks with the given data or error.
--
-- @param data  table|nil   Decoded metadata table, or nil
-- @param err   string|nil  Error message, or nil
--
----------------------------------------------------------------------------
local function call_callbacks(data, err)
    for _, cb in ipairs(M.state.callbacks) do
        cb(data, err)
    end
    M.state.callbacks = {}
end

----------------------------------------------------------------------------
--
-- Tries to decode a JSON string to a Lua table.
--
-- @param  body    string        JSON payload
--
-- @return table|nil             Decoded table on success, or nil
-- @return string|nil            Error message on failure, or nil
--
----------------------------------------------------------------------------
local function try_decode_json(body)
    if not body or body == "" then
        return nil, "Empty response body"
    end

    local ok, decoded = pcall(vim.json.decode, body)
    if ok and type(decoded) == "table" then
        return decoded, nil
    end
    return nil, "Failed to parse Spring metadata"
end

----------------------------------------------------------------------------
--
-- Updates module state with success metadata and flags.
--
-- @param data  table   Parsed metadata
--
----------------------------------------------------------------------------
local function update_state_success(data)
    M.state.metadata = data
    M.state.loaded = true
    M.state.error = nil
    M.state.loading = false
end

----------------------------------------------------------------------------
--
-- Updates module state with an error and flags.
--
-- @param error_msg  string  Error message
--
----------------------------------------------------------------------------
local function update_state_error(error_msg)
    M.state.error = error_msg
    M.state.loading = false
end

----------------------------------------------------------------------------
--
-- Handle success case: update state and notify callbacks.
--
-- @param data  table  Decoded metadata
--
----------------------------------------------------------------------------
local function handle_success(data)
    update_state_success(data)
    call_callbacks(data, nil)
end

----------------------------------------------------------------------------
--
-- Handle failure case: record error and notify callbacks.
--
-- @param error_msg  string  Error message
--
----------------------------------------------------------------------------
local function handle_failure(error_msg)
    update_state_error(error_msg)
    call_callbacks(nil, M.state.error)
end

----------------------------------------------------------------------------
--
-- Handles curl response and updates state, then invokes callbacks.
--
-- @param response  table  Response from plenary.curl
--
----------------------------------------------------------------------------
local function handle_response(response)
    vim.schedule(function()
        if response.exit ~= 0 then
            handle_failure("Network request failed")
            return
        end

        if response.status < 200 or response.status >= 300 then
            handle_failure(string.format("HTTP error %d", response.status))
            return
        end

        local data, decode_err = try_decode_json(response.body)
        if data then
            handle_success(data)
        else
            handle_failure(decode_err)
        end
    end)
end

----------------------------------------------------------------------------
--
-- Fetches metadata from the Spring Initializr endpoint using plenary.curl.
--
----------------------------------------------------------------------------
local function fetch_from_remote()
    local response = curl.get(METADATA_URL, {
        headers = {
            ["Accept"] = "application/vnd.initializr.v2.3+json",
        },
        timeout = REQUEST_TIMEOUT,
    })

    handle_response(response)
end

----------------------------------------------------------------------------
--
-- Fetches Spring metadata, using cache if already loaded.
--
-- @param callback  function  Function (data, err) to receive result
--
----------------------------------------------------------------------------
function M.fetch_metadata(callback)
    if M.state.loaded and M.state.metadata then
        callback(M.state.metadata, nil)
        return
    end

    table.insert(M.state.callbacks, callback)

    if M.state.loading then
        return
    end

    M.state.loading = true
    fetch_from_remote()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
