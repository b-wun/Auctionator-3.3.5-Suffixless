-- Unit tests for AuctionatorQuery pure-logic methods.
-- Run with:  busted tests/spec/query_spec.lua

require("tests.mocks.wow_api")           -- install WoW API stubs
local loader = require("tests.helpers.addon_loader")

-- AuctionatorQuery.lua defines globals (AtrQuery, Atr_NewQuery).
-- Load it by injecting it into the global environment via dofile after loading
-- zcUtils so the addonTable.zc reference is available.

-- First, build a shared addonTable that both files will populate.
local addonTable = loader.load("Auctionator/zcUtils.lua")

-- Now load AuctionatorQuery.lua the same way.
-- busted is expected to be run from the repository root, so the relative path
-- resolves correctly without computing an absolute prefix.
local chunk, err = loadfile("Auctionator/AuctionatorQuery.lua")
assert(chunk, "Could not load AuctionatorQuery.lua: " .. tostring(err))
chunk("Auctionator", addonTable)

-- ─────────────────────────────────────────────────────────────────────────────

describe("AtrQuery:BuildItemIDstr", function()
    local query

    before_each(function()
        query = Atr_NewQuery()
    end)

    it("builds an underscore-delimited ID string when all fields are provided", function()
        local result = query:BuildItemIDstr("Sword", 1, 100, 500, 0)
        assert.equal("Sword_1_100_500_0", result)
    end)

    it("returns empty string when name is nil", function()
        local result = query:BuildItemIDstr(nil, 1, 100, 500, 0)
        assert.equal("", result)
    end)

    it("includes all five fields separated by underscores", function()
        local result = query:BuildItemIDstr("Ring of Power", 5, 200, 1000, 50)
        assert.equal("Ring of Power_5_200_1000_50", result)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("Atr_NewQuery", function()
    it("creates a query with initial state", function()
        local q = Atr_NewQuery()
        assert.is_not_nil(q)
        assert.is_nil(q.prevPage)
        assert.equal(0,  q.numDupPages)
        assert.equal(-1, q.pagenum)
    end)

    it("creates independent query instances", function()
        local q1 = Atr_NewQuery()
        local q2 = Atr_NewQuery()
        q1.numDupPages = 5
        assert.equal(0, q2.numDupPages)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("AtrQuery:CheckForDuplicatePage", function()
    local query
    local originalGetNumAuctionItems

    before_each(function()
        -- Save the original GetNumAuctionItems so we can restore it after each spec.
        originalGetNumAuctionItems = GetNumAuctionItems
        -- Override GetNumAuctionItems so CheckForDuplicatePage gets 0 items
        -- (the code path that never sets prevPage data returns false).
        GetNumAuctionItems = function() return 0, 0 end
        query = Atr_NewQuery()
    end)

    after_each(function()
        -- Restore the original GetNumAuctionItems to avoid leaking state.
        if originalGetNumAuctionItems ~= nil then
            GetNumAuctionItems = originalGetNumAuctionItems
            originalGetNumAuctionItems = nil
        end
    end)

    it("returns false when there are no auction items", function()
        local result = query:CheckForDuplicatePage(0)
        assert.is_false(result)
    end)

    it("returns false for a page never seen before", function()
        -- Same page number on first call – should return false (no prevPage)
        local result = query:CheckForDuplicatePage(1)
        assert.is_false(result)
    end)
end)
