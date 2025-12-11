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
-- Handles fetching and caching of Spring Initializr metadata.
--
----------------------------------------------------------------------------

----------------------------------------------------------------------------
-- Dependencies
----------------------------------------------------------------------------
local curl = require("plenary.curl")
local log = require("spring-initializr.trace.log")

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
    log.debug("Calling", #M.state.callbacks, "registered callbacks")
    for _, cb in ipairs(M.state.callbacks) do
        cb(data, err)
    end
    M.state.callbacks = {}
    log.trace("Callbacks cleared")
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
    log.trace("Attempting to decode JSON response")

    if not body or body == "" then
        log.error("Empty response body from metadata endpoint")
        return nil, "Empty response body"
    end

    log.fmt_debug("Response body length: %d bytes", #body)

    local ok, decoded = pcall(vim.json.decode, body)
    if ok and type(decoded) == "table" then
        log.info("Successfully decoded metadata JSON")
        log.fmt_debug("Decoded metadata contains %d top-level keys", vim.tbl_count(decoded))
        return decoded, nil
    end

    log.error("Failed to parse metadata JSON:", decoded)
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
    log.info("Updating state with successful metadata")
    M.state.metadata = data
    M.state.loaded = true
    M.state.error = nil
    M.state.loading = false
    log.trace("State updated: loaded=true, error=nil, loading=false")
end

----------------------------------------------------------------------------
--
-- Updates module state with an error and flags.
--
-- @param error_msg  string  Error message
--
----------------------------------------------------------------------------
local function update_state_error(error_msg)
    log.error("Updating state with error:", error_msg)
    M.state.error = error_msg
    M.state.loading = false
    log.trace("State updated: error set, loading=false")
end

----------------------------------------------------------------------------
--
-- Handle success case: update state and notify callbacks.
--
-- @param data  table  Decoded metadata
--
----------------------------------------------------------------------------
local function handle_success(data)
    log.info("Handling successful metadata fetch")
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
    log.warn("Handling metadata fetch failure")
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
    log.debug("Processing HTTP response")

    vim.schedule(function()
        if response.exit ~= 0 then
            log.error("Network request failed with exit code:", response.exit)
            handle_failure("Network request failed")
            return
        end

        log.fmt_debug("HTTP status code: %d", response.status)

        if response.status < 200 or response.status >= 300 then
            log.error("HTTP error:", response.status)
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
    log.info("Fetching metadata from", METADATA_URL)
    log.fmt_debug("Request timeout: %d ms", REQUEST_TIMEOUT)

    local response = curl.get(METADATA_URL, {
        headers = {
            ["Accept"] = "application/vnd.initializr.v2.3+json",
        },
        timeout = REQUEST_TIMEOUT,
    })

    log.trace("HTTP request completed, processing response")
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
    log.debug("fetch_metadata called")

    if M.state.loaded and M.state.metadata then
        log.info("Using cached metadata")
        callback(M.state.metadata, nil)
        return
    end

    log.debug("Registering callback for metadata fetch")
    table.insert(M.state.callbacks, callback)
    log.fmt_trace("Total callbacks registered: %d", #M.state.callbacks)

    if M.state.loading then
        log.debug("Metadata fetch already in progress, callback queued")
        return
    end

    log.info("Starting new metadata fetch")
    M.state.loading = true
    fetch_from_remote()
end

----------------------------------------------------------------------------
-- Exports
----------------------------------------------------------------------------
return M
