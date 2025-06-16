--
-- ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
-- ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
-- ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
-- ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
-- ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
-- ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
--
-- File: ui/init.lua
-- Author: Josip Keresman

local layout_builder = require("spring-initializr.ui.layout")
local focus = require("spring-initializr.ui.focus")
local highlights = require("spring-initializr.utils.highlights")
local metadata = require("spring-initializr.metadata.metadata")
local deps = require("spring-initializr.ui.deps")
local msg = require("spring-initializr.utils.message")

local M = {
    state = {
        layout = nil,
        outer_popup = nil,
        selections = { dependencies = {} },
    },
}

local function setup_highlights()
    highlights.configure()
end

local function handle_metadata_error(err)
    msg.error("Failed to load metadata: " .. (err or "unknown error"))
end

local function mount_ui(data)
    M.state.metadata = data

    local ui = layout_builder.build_ui(data, M.state.selections)
    M.state.layout = ui.layout
    M.state.outer_popup = ui.outer_popup

    ui.layout:mount()
    focus.enable()
    deps.update_display()
end

function M.setup()
    setup_highlights()

    metadata.fetch_metadata(function(data, err)
        if err or not data then
            handle_metadata_error(err)
            return
        end

        vim.schedule(function()
            mount_ui(data)
        end)
    end)
end

function M.close()
    if M.state.layout then
        pcall(function()
            M.state.layout:unmount()
        end)
        M.state.layout = nil
    end

    win.safe_close(M.state.outer_popup and M.state.outer_popup.winid)
    M.state.outer_popup = nil

    focus.reset()
end

return M
