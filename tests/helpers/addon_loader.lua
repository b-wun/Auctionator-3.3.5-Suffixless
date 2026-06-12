-- Helper that loads an Auctionator source file using a mock WoW addon environment.
-- Returns the addon table so tests can access the exported zc library.
--
-- Usage:
--   local loader = require("tests.helpers.addon_loader")
--   local addonTable = loader.load("Auctionator/zcUtils.lua")
--   local zc = addonTable.zc

local addon_loader = {}

--- Load a Lua source file from the addon directory with a mock WoW addon context.
-- @param relative_path  Path relative to the repository root (e.g. "Auctionator/zcUtils.lua").
--                       busted must be invoked from the repository root so that relative
--                       paths resolve correctly.
-- @return addonTable    The addon-table produced by the file (may be empty for files that
--                       don't populate it).
function addon_loader.load(relative_path)
    local chunk, err = loadfile(relative_path)
    if not chunk then
        error("addon_loader: could not load '" .. relative_path .. "': " .. tostring(err))
    end

    -- Simulate WoW's addon loading convention:
    --   local addonName, addonTable = ...
    local addon_name  = "Auctionator"
    local addon_table = {}

    chunk(addon_name, addon_table)

    return addon_table
end

--- Convenience: load zcUtils.lua and return the zc utility table.
function addon_loader.load_zc()
    local t = addon_loader.load("Auctionator/zcUtils.lua")
    assert(t.zc, "addon_loader: zcUtils.lua did not populate addonTable.zc")
    return t.zc
end

return addon_loader
