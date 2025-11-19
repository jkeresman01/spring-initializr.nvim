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
-- External modules used by this file.
----------------------------------------------------------------------------
local Job = require("plenary.job")

----------------------------------------------------------------------------
-- Constants
----------------------------------------------------------------------------
local METADATA_URL = "https://start.spring.io/metadata/client"

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
-- Converts the curl result (array of lines) into a single string.
--
-- @param  result  table    Lines from stdout
-- @return string           Joined output
--
----------------------------------------------------------------------------
local function parse_output(result)
    if type(result) == "table" then
        return table.concat(result, "\n")
    end
    return ""
end

----------------------------------------------------------------------------
--
-- Tries to decode a JSON string to a Lua table.
--
-- @param  output  string        JSON payload
--
-- @return table|nil             Decoded table on success, or nil
-- @return string|nil            Error message on failure, or nil
--
----------------------------------------------------------------------------
local function try_decode_json(output)
    local ok, decoded = pcall(vim.json.decode, output)
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
-- @param stderr        string  Raw stderr output
-- @param fallback_msg  string  Fallback error message
--
----------------------------------------------------------------------------
local function update_state_error(stderr, fallback_msg)
    M.state.error = stderr ~= "" and stderr or fallback_msg
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
-- @param stderr_lines  table       Lines from stderr
-- @param decode_err    string|nil  JSON decode error (if any)
--
----------------------------------------------------------------------------
local function handle_failure(stderr_lines, decode_err)
    update_state_error(table.concat(stderr_lines or {}, "\n"), decode_err)
    call_callbacks(nil, M.state.error)
end

----------------------------------------------------------------------------
--
-- Handles curl job result and updates state, then invokes callbacks.
--
-- @param result  table  Lines from stdout
-- @param stderr  table  Lines from stderr
--
----------------------------------------------------------------------------
local function handle_response(result, stderr)
    local output = parse_output(result)
    local data, decode_err = try_decode_json(output)

    vim.schedule(function()
        if data then
            handle_success(data)
        else
            handle_failure(stderr, decode_err)
        end
    end)
end

----------------------------------------------------------------------------
--
-- Fetches metadata from the Spring Initializr endpoint using curl.
--
----------------------------------------------------------------------------
local function fetch_from_remote()
    Job:new({
        command = "curl",
        args = {
            "-s",
            "-H",
            "Accept: application/vnd.initializr.v2.3+json",
            METADATA_URL,
        },
        on_exit = function(j)
            handle_response(j:result(), j:stderr_result())
        end,
    }):start()
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
