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
-- Handles fetching and caching of Spring Initializr metadata.
--
--
-- License: GPL-3.0
-- Author: Josip Keresman
--
----------------------------------------------------------------------------

local Job = require("plenary.job")

local METADATA_URL = "https://start.spring.io/metadata/client"

local M = {
    state = {
        metadata = nil,
        loaded = false,
        error = nil,
        loading = false,
        callbacks = {},
    },
}

-----------------------------------------------------------------------------
--
-- Calls all registered callbacks with the given data or error.
--
-- @param data table|nil
-- @param err string|nil
--
-----------------------------------------------------------------------------
local function call_callbacks(data, err)
    for _, cb in ipairs(M.state.callbacks) do
        cb(data, err)
    end
    M.state.callbacks = {}
end

-----------------------------------------------------------------------------
--
-- Converts the curl result (array of lines) into a single string.
--
-- @param result table
-- @return string
--
-----------------------------------------------------------------------------
local function parse_output(result)
    if type(result) == "table" then
        return table.concat(result, "\n")
    end
    return ""
end

-----------------------------------------------------------------------------
--
-- Tries to decode a JSON string to a Lua table.
--
-- @param output string
-- @return table|nil, string|nil
--
-----------------------------------------------------------------------------
local function try_decode_json(output)
    local ok, decoded = pcall(vim.json.decode, output)
    if ok and type(decoded) == "table" then
        return decoded, nil
    end
    return nil, "Failed to parse Spring metadata"
end

-----------------------------------------------------------------------------
--
-- Updates module state with success metadata and flags.
--
-- @param data table
--
-----------------------------------------------------------------------------
local function update_state_success(data)
    M.state.metadata = data
    M.state.loaded = true
    M.state.error = nil
    M.state.loading = false
end

-----------------------------------------------------------------------------
--
-- Updates module state with an error and flags.
--
-- @param stderr string
-- @param fallback_msg string
--
-----------------------------------------------------------------------------
local function update_state_error(stderr, fallback_msg)
    M.state.error = stderr ~= "" and stderr or fallback_msg
    M.state.loading = false
end

-----------------------------------------------------------------------------
--
-- Handles curl job result and updates state, invokes callbacks.
--
-- @param result table
-- @param stderr table
--
-----------------------------------------------------------------------------
local function handle_response(result, stderr)
    local output = parse_output(result)
    local data, decode_err = try_decode_json(output)

    vim.schedule(function()
        if data then
            update_state_success(data)
            call_callbacks(data, nil)
        else
            update_state_error(table.concat(stderr or {}, "\n"), decode_err)
            call_callbacks(nil, M.state.error)
        end
    end)
end

-----------------------------------------------------------------------------
--
-- Fetches metadata from the Spring Initializr endpoint using curl.
--
-----------------------------------------------------------------------------
local function fetch_from_remote()
    Job:new({
        command = "curl",
        args = { "-s", METADATA_URL },
        on_exit = function(j)
            handle_response(j:result(), j:stderr_result())
        end,
    }):start()
end

-----------------------------------------------------------------------------
--
-- Fetches Spring metadata, using cache if already loaded.
--
-- @param callback function Function to receive metadata or error
--
-----------------------------------------------------------------------------
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

return M
