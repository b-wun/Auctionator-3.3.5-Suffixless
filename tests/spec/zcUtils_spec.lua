-- Unit tests for the pure-logic utility functions in zcUtils.lua.
-- Run with:  busted tests/spec/zcUtils_spec.lua

require("tests.mocks.wow_api")          -- install WoW API stubs
local loader = require("tests.helpers.addon_loader")
local zc     = loader.load_zc()

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.RGBtoHEX", function()
    it("converts (1, 0, 0) to red hex", function()
        assert.equal("ff0000", zc.RGBtoHEX(1, 0, 0))
    end)

    it("converts (0, 1, 0) to green hex", function()
        assert.equal("00ff00", zc.RGBtoHEX(0, 1, 0))
    end)

    it("converts (0, 0, 1) to blue hex", function()
        assert.equal("0000ff", zc.RGBtoHEX(0, 0, 1))
    end)

    it("converts (1, 1, 1) to white hex", function()
        assert.equal("ffffff", zc.RGBtoHEX(1, 1, 1))
    end)

    it("converts (0, 0, 0) to black hex", function()
        assert.equal("000000", zc.RGBtoHEX(0, 0, 0))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.Val", function()
    it("returns the value when not nil", function()
        assert.equal(42, zc.Val(42, 0))
    end)

    it("returns the fallback when value is nil", function()
        assert.equal(99, zc.Val(nil, 99))
    end)

    it("returns false (not the fallback) when value is false", function()
        assert.equal(false, zc.Val(false, "default"))
    end)

    it("returns empty string when value is empty string", function()
        assert.equal("", zc.Val("", "default"))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.Min", function()
    it("returns the smaller of two numbers", function()
        assert.equal(3, zc.Min(3, 7))
        assert.equal(3, zc.Min(7, 3))
    end)

    it("returns b when a is nil", function()
        assert.equal(5, zc.Min(nil, 5))
    end)

    it("returns a when b is nil", function()
        assert.equal(5, zc.Min(5, nil))
    end)

    it("handles equal values", function()
        assert.equal(4, zc.Min(4, 4))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.Max", function()
    it("returns the larger of two numbers", function()
        assert.equal(7, zc.Max(3, 7))
        assert.equal(7, zc.Max(7, 3))
    end)

    it("returns b when a is nil", function()
        assert.equal(5, zc.Max(nil, 5))
    end)

    it("returns a when b is nil", function()
        assert.equal(5, zc.Max(5, nil))
    end)

    it("handles equal values", function()
        assert.equal(4, zc.Max(4, 4))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.If", function()
    it("returns x when condition is true", function()
        assert.equal("yes", zc.If(true, "yes", "no"))
    end)

    it("returns y when condition is false", function()
        assert.equal("no", zc.If(false, "yes", "no"))
    end)

    it("returns y when condition is nil", function()
        assert.equal("no", zc.If(nil, "yes", "no"))
    end)

    it("returns x for any truthy non-boolean value", function()
        assert.equal("yes", zc.If(1, "yes", "no"))
        assert.equal("yes", zc.If("str", "yes", "no"))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.GetArrayElemOrFirst", function()
    local arr = {"a", "b", "c"}

    it("returns element at valid index", function()
        assert.equal("b", zc.GetArrayElemOrFirst(arr, 2))
    end)

    it("returns first element when index is nil", function()
        assert.equal("a", zc.GetArrayElemOrFirst(arr, nil))
    end)

    it("returns first element when index is out of range (too high)", function()
        assert.equal("a", zc.GetArrayElemOrFirst(arr, 99))
    end)

    it("returns first element when index is zero", function()
        assert.equal("a", zc.GetArrayElemOrFirst(arr, 0))
    end)

    it("returns nil for empty table", function()
        assert.is_nil(zc.GetArrayElemOrFirst({}, 1))
    end)

    it("returns nil for nil table", function()
        assert.is_nil(zc.GetArrayElemOrFirst(nil, 1))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.GetArrayElemOrNil", function()
    local arr = {"x", "y", "z"}

    it("returns element at valid index", function()
        assert.equal("y", zc.GetArrayElemOrNil(arr, 2))
    end)

    it("returns nil when index is nil", function()
        assert.is_nil(zc.GetArrayElemOrNil(arr, nil))
    end)

    it("returns nil when index is out of range", function()
        assert.is_nil(zc.GetArrayElemOrNil(arr, 99))
    end)

    it("returns nil for empty table", function()
        assert.is_nil(zc.GetArrayElemOrNil({}, 1))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.padstring", function()
    it("pads a short string to the requested length", function()
        assert.equal("00042", zc.padstring("42", 5, "0"))
    end)

    it("does not pad when string is already the right length", function()
        assert.equal("hello", zc.padstring("hello", 5, "0"))
    end)

    it("does not truncate a string that is longer than n", function()
        assert.equal("toolong", zc.padstring("toolong", 3, "0"))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.BoolToString", function()
    it("returns 'true' for truthy", function()
        assert.equal("true", zc.BoolToString(true))
        assert.equal("true", zc.BoolToString(1))
    end)

    it("returns 'false' for false", function()
        assert.equal("false", zc.BoolToString(false))
    end)

    it("returns 'false' for nil", function()
        assert.equal("false", zc.BoolToString(nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.BoolToNum", function()
    it("returns 1 for true", function()
        assert.equal(1, zc.BoolToNum(true))
    end)

    it("returns 0 for false", function()
        assert.equal(0, zc.BoolToNum(false))
    end)

    it("returns 0 for nil", function()
        assert.equal(0, zc.BoolToNum(nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.NumToBool", function()
    it("returns false for 0", function()
        assert.equal(false, zc.NumToBool(0))
    end)

    it("returns true for any non-zero number", function()
        assert.equal(true, zc.NumToBool(1))
        assert.equal(true, zc.NumToBool(-5))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.pluralize / zc.pluralizeIf", function()
    it("pluralize appends 's'", function()
        assert.equal("items", zc.pluralize("item"))
    end)

    it("pluralizeIf returns singular when count is 1", function()
        assert.equal("item", zc.pluralizeIf("item", 1))
    end)

    it("pluralizeIf returns plural when count is not 1", function()
        assert.equal("items", zc.pluralizeIf("item", 0))
        assert.equal("items", zc.pluralizeIf("item", 2))
    end)

    it("pluralizeIf returns plural when count is nil", function()
        assert.equal("items", zc.pluralizeIf("item", nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.round", function()
    it("rounds 0.5 up to 1", function()
        assert.equal(1, zc.round(0.5))
    end)

    it("rounds 1.4 down to 1", function()
        assert.equal(1, zc.round(1.4))
    end)

    it("leaves integers unchanged", function()
        assert.equal(5, zc.round(5))
        assert.equal(0, zc.round(0))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.tableIsEmpty", function()
    it("returns true for an empty table", function()
        assert.is_true(zc.tableIsEmpty({}))
    end)

    it("returns false for a non-empty table", function()
        assert.is_false(zc.tableIsEmpty({1, 2, 3}))
        assert.is_false(zc.tableIsEmpty({key = "value"}))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.StringSame", function()
    it("returns true for identical strings", function()
        assert.is_true(zc.StringSame("hello", "hello"))
    end)

    it("is case-insensitive", function()
        assert.is_true(zc.StringSame("Hello", "hello"))
        assert.is_true(zc.StringSame("WORLD", "world"))
    end)

    it("returns false for different strings", function()
        assert.is_false(zc.StringSame("hello", "world"))
    end)

    it("handles nil,nil as equal", function()
        assert.is_true(zc.StringSame(nil, nil))
    end)

    it("returns false when only one is nil", function()
        assert.is_false(zc.StringSame(nil, "hello"))
        assert.is_false(zc.StringSame("hello", nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.StringContains", function()
    it("returns true when substring is present", function()
        assert.is_true(zc.StringContains("hello world", "world"))
    end)

    it("is case-insensitive", function()
        assert.is_true(zc.StringContains("Hello World", "hello"))
    end)

    it("returns false when substring is absent", function()
        assert.is_false(zc.StringContains("hello world", "xyz"))
    end)

    it("returns false for empty substring", function()
        assert.is_false(zc.StringContains("hello", ""))
    end)

    it("returns false for nil substring", function()
        assert.is_false(zc.StringContains("hello", nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.StringStartsWith", function()
    it("returns true when string starts with prefix", function()
        assert.is_true(zc.StringStartsWith("hello world", "hello"))
    end)

    it("is case-insensitive", function()
        assert.is_true(zc.StringStartsWith("Hello World", "hello"))
    end)

    it("returns false when string does not start with prefix", function()
        assert.is_false(zc.StringStartsWith("hello world", "world"))
    end)

    it("returns false for nil input or nil prefix", function()
        assert.is_false(zc.StringStartsWith(nil, "hello"))
        assert.is_false(zc.StringStartsWith("hello", nil))
        assert.is_false(zc.StringStartsWith("hello", ""))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.StringEndsWith", function()
    it("returns true when string ends with suffix", function()
        assert.is_true(zc.StringEndsWith("hello world", "world"))
    end)

    it("is case-insensitive", function()
        assert.is_true(zc.StringEndsWith("Hello World", "WORLD"))
    end)

    it("returns false when string does not end with suffix", function()
        assert.is_false(zc.StringEndsWith("hello world", "hello"))
    end)

    it("returns false for empty or nil suffix", function()
        assert.is_false(zc.StringEndsWith("hello", ""))
        assert.is_false(zc.StringEndsWith("hello", nil))
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.CopyDeep", function()
    it("copies flat tables", function()
        local src = {a = 1, b = 2}
        local copy = zc.CopyDeep(src)
        assert.equal(1, copy.a)
        assert.equal(2, copy.b)
    end)

    it("makes a deep (independent) copy", function()
        local src = {nested = {x = 10}}
        local copy = zc.CopyDeep(src)
        copy.nested.x = 99
        assert.equal(10, src.nested.x)
    end)

    it("copies arrays", function()
        local src = {10, 20, 30}
        local copy = zc.CopyDeep(src)
        assert.same({10, 20, 30}, copy)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.val2gsc", function()
    it("converts copper correctly", function()
        local g, s, c = zc.val2gsc(50)
        assert.equal(0, g)
        assert.equal(0, s)
        assert.equal(50, c)
    end)

    it("converts silver correctly", function()
        local g, s, c = zc.val2gsc(150)
        assert.equal(0, g)
        assert.equal(1, s)
        assert.equal(50, c)
    end)

    it("converts gold correctly", function()
        local g, s, c = zc.val2gsc(10000)
        assert.equal(1, g)
        assert.equal(0, s)
        assert.equal(0, c)
    end)

    it("converts a mixed value correctly", function()
        -- 1g 23s 45c  =  12345 copper
        local g, s, c = zc.val2gsc(12345)
        assert.equal(1, g)
        assert.equal(23, s)
        assert.equal(45, c)
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────────

describe("zc.priceToString", function()
    it("formats pure copper", function()
        assert.equal("50c", zc.priceToString(50))
    end)

    it("formats silver + copper", function()
        assert.equal("1s 50c", zc.priceToString(150))
    end)

    it("formats gold only", function()
        assert.equal("1g 00s 00c", zc.priceToString(10000))
    end)

    it("formats a mixed value", function()
        -- 1g 23s 45c
        assert.equal("1g 23s 45c", zc.priceToString(12345))
    end)
end)
