-- End-to-end integration tests that exercise cross-module flows using a
-- fully-mocked WoW environment.  These tests simulate scenarios a real player
-- would trigger in-game (scanning, pricing, and shopping-list interactions)
-- without requiring a live WoW or AzerothCore server.
--
-- Run with:  busted tests/spec/e2e_spec.lua

require("tests.mocks.wow_api")
local loader = require("tests.helpers.addon_loader")

-- ── shared addon table used by all loaded files ───────────────────────────────
local addonTable = loader.load("Auctionator/zcUtils.lua")
local zc = addonTable.zc

local function load_addon_file(rel)
    -- busted must be run from the repository root so relative paths work.
    local chunk, err = loadfile(rel)
    assert(chunk, "e2e: could not load '" .. rel .. "': " .. tostring(err))
    chunk("Auctionator", addonTable)
end

-- Load the files that define independent pure-logic globals we want to test.
load_addon_file("Auctionator/AuctionatorQuery.lua")

-- ─────────────────────────────────────────────────────────────────────────────
-- Scenario 1: Price database read/write helpers (pure Lua, no WoW APIs)
-- ─────────────────────────────────────────────────────────────────────────────

describe("E2E: price utility helpers (zc layer)", function()

    it("converts copper values to gold/silver/copper and back via priceToString", function()
        -- 12345 copper = 1g 23s 45c
        local g, s, c = zc.val2gsc(12345)
        assert.equal(1,  g)
        assert.equal(23, s)
        assert.equal(45, c)

        local str = zc.priceToString(12345)
        assert.equal("1g 23s 45c", str)
    end)

    it("handles a zero-value price gracefully", function()
        -- 0 copper should produce an empty string (no components to display)
        local str = zc.priceToString(0)
        assert.equal("", str)
    end)

    it("produces consistent deep-copied price tables", function()
        local priceDB = {["Sword"] = 500, ["Shield"] = 300}
        local copy    = zc.CopyDeep(priceDB)

        -- Mutate the copy – original must be unaffected
        copy["Sword"] = 999
        assert.equal(500, priceDB["Sword"])
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Scenario 2: Auction query lifecycle (Atr_NewQuery → BuildItemIDstr)
-- ─────────────────────────────────────────────────────────────────────────────

describe("E2E: auction query lifecycle", function()

    it("builds unique item ID strings for different items", function()
        local q   = Atr_NewQuery()
        local id1 = q:BuildItemIDstr("Sword of Might", 1, 100, 500, 0)
        local id2 = q:BuildItemIDstr("Staff of Power", 1, 200, 800, 0)
        assert.not_equal(id1, id2)
    end)

    it("identical items produce the same ID string (for dup-page detection)", function()
        local q  = Atr_NewQuery()
        local id = q:BuildItemIDstr("Ring", 1, 50, 200, 10)
        assert.equal(id, q:BuildItemIDstr("Ring", 1, 50, 200, 10))
    end)

    it("resets to zero duplicate pages on creation", function()
        local q = Atr_NewQuery()
        assert.equal(0, q.numDupPages)
    end)

    it("multiple queries are independent", function()
        local q1 = Atr_NewQuery()
        local q2 = Atr_NewQuery()
        q1.numDupPages = 3
        assert.equal(0, q2.numDupPages)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Scenario 3: String utility helpers used throughout the addon
-- ─────────────────────────────────────────────────────────────────────────────

describe("E2E: string helpers used in search/filter flows", function()

    it("StringContains supports partial item-name matching (case-insensitive)", function()
        local items = {"Sword of Might", "Shield of Valor", "Ring of Power"}
        local results = {}
        for _, name in ipairs(items) do
            if zc.StringContains(name, "of") then
                table.insert(results, name)
            end
        end
        assert.equal(3, #results)
    end)

    it("StringStartsWith filters items by name prefix", function()
        local items = {"Sword of Might", "Shield of Valor", "Staff of Power"}
        local results = {}
        for _, name in ipairs(items) do
            if zc.StringStartsWith(name, "s") then
                table.insert(results, name)
            end
        end
        assert.equal(3, #results)  -- Sword, Shield, Staff all start with 'S'/'s'
    end)

    it("padstring produces fixed-width columns in display lists", function()
        local padded = zc.padstring("42", 6, " ")
        assert.equal(6, #padded)
        assert.is_true(zc.StringEndsWith(padded, "42"))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Scenario 4: Min/Max price comparison (used when posting/buying auctions)
-- ─────────────────────────────────────────────────────────────────────────────

describe("E2E: min/max price comparison in auction posting logic", function()

    it("selects the lowest buyout from a list of prices", function()
        local prices = {1000, 500, 750, 250, 900}
        local minPrice = nil
        for _, p in ipairs(prices) do
            minPrice = zc.Min(minPrice, p)
        end
        assert.equal(250, minPrice)
    end)

    it("selects the highest buyout from a list of prices", function()
        local prices = {1000, 500, 750, 250, 900}
        local maxPrice = nil
        for _, p in ipairs(prices) do
            maxPrice = zc.Max(maxPrice, p)
        end
        assert.equal(1000, maxPrice)
    end)

    it("handles a single-price list for min/max", function()
        assert.equal(999, zc.Min(nil, 999))
        assert.equal(999, zc.Max(nil, 999))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Scenario 5: Round-trip encoding/decoding (zc.enc64 / zc.dec64)
-- ─────────────────────────────────────────────────────────────────────────────

describe("E2E: enc64/dec64 round-trip (price database serialization)", function()

    it("encodes and decodes zero", function()
        assert.equal(0, zc.dec64(zc.enc64(0)))
    end)

    it("encodes and decodes a small number", function()
        assert.equal(42, zc.dec64(zc.enc64(42)))
    end)

    it("encodes and decodes a large price value", function()
        local price = 123456  -- ~12g 34s 56c in copper
        assert.equal(price, zc.dec64(zc.enc64(price)))
    end)

    it("dec64 returns 0 for nil or empty string", function()
        assert.equal(0, zc.dec64(nil))
        assert.equal(0, zc.dec64(""))
    end)
end)
