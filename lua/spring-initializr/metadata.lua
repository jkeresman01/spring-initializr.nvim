local Job = require("plenary.job")

local M = {}

M.state = {
    metadata = nil,
    loaded = false,
    error = nil,
}

M.fetch_metadata = function(callback)
    if M.state.loaded and M.state.metadata then
        callback(M.state.metadata, nil)
        return
    end

    M.state.callbacks = M.state.callbacks or {}
    table.insert(M.state.callbacks, callback)

    if M.state.loading then
        return -- Already fetching
    end

    M.state.loading = true

    require("plenary.job")
        :new({
            command = "curl",
            args = { "-s", "https://start.spring.io/metadata/client" },

            on_exit = function(j)
                local result = j:result()
                local stderr = j:stderr_result()
                local output = type(result) == "table" and table.concat(result, "\n") or ""
                local ok, data = pcall(vim.json.decode, output)

                vim.schedule(function()
                    M.state.loading = false

                    if ok and type(data) == "table" then
                        M.state.metadata = data
                        M.state.loaded = true
                        for _, cb in ipairs(M.state.callbacks) do
                            cb(data, nil)
                        end
                    else
                        M.state.error = stderr ~= "" and stderr or "Failed to parse Spring metadata"
                        for _, cb in ipairs(M.state.callbacks) do
                            cb(nil, M.state.error)
                        end
                    end

                    M.state.callbacks = {}
                end)
            end,
        })
        :start()
end

return M
