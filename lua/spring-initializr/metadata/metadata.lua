--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: metadata/metadata.lua
-- Author: Josip Keresman

local Job = require("plenary.job")
local msg = require("spring-initializr.utils.message")

local M = {
    state = {
        metadata = nil,
        loaded = false,
        error = nil,
        loading = false,
        callbacks = {},
    },
}

local METADATA_URL = "https://start.spring.io/metadata/client"

local function call_callbacks(data, err)
    for _, cb in ipairs(M.state.callbacks) do
        cb(data, err)
    end
    M.state.callbacks = {}
end

local function handle_response(result, stderr)
    local output = type(result) == "table" and table.concat(result, "\n") or ""
    local ok, decoded = pcall(vim.json.decode, output)

    vim.schedule(function()
        M.state.loading = false
        if ok and type(decoded) == "table" then
            M.state.metadata = decoded
            M.state.loaded = true
            call_callbacks(decoded, nil)
        else
            M.state.error = stderr ~= "" and stderr or "Failed to parse Spring metadata"
            call_callbacks(nil, M.state.error)
        end
    end)
end

local function fetch_from_remote()
    Job:new({
        command = "curl",
        args = { "-s", METADATA_URL },
        on_exit = function(j)
            handle_response(j:result(), j:stderr_result())
        end,
    }):start()
end

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
