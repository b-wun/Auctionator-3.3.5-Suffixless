-- WoW API mocks for unit testing outside the game client.
-- Provides stubs for global functions and objects that Auctionator uses
-- so that pure-logic code can be loaded and tested with busted.

-- ── bit library (WoW ships BitOp; provide a pure-Lua shim for Lua 5.1) ──────
if not bit then
    local ok, bitlib = pcall(require, "bit")
    if ok then
        bit = bitlib
    else
        -- Minimal pure-Lua bit operations needed by zcUtils
        local M = {}
        function M.band(a, b)
            local result = 0
            local bit_val = 1
            while a > 0 and b > 0 do
                if a % 2 == 1 and b % 2 == 1 then result = result + bit_val end
                a = math.floor(a / 2)
                b = math.floor(b / 2)
                bit_val = bit_val * 2
            end
            return result
        end
        function M.rshift(a, n)
            return math.floor(a / (2 ^ n))
        end
        function M.lshift(a, n)
            return a * (2 ^ n)
        end
        bit = M
    end
end

-- ── WoW string helpers ────────────────────────────────────────────────────────
-- strsplit: split string by delimiter string, WoW-style (preserve empty fields)
function strsplit(delim, str)
    local result = {}
    local pos = 1
    -- Use plain string matching so delimiters are treated literally and can be multi-character.
    while true do
        local start_pos, end_pos = string.find(str, delim, pos, true)
        if not start_pos then
            -- No more delimiters; add the remainder (possibly empty)
            table.insert(result, string.sub(str, pos))
            break
        end
        -- Add the segment before the delimiter (possibly empty)
        table.insert(result, string.sub(str, pos, start_pos - 1))
        pos = end_pos + 1
    end
    -- return multiple values like WoW's strsplit
    return unpack(result)
end

-- format is a WoW alias for string.format
format = string.format

-- gsub is also exposed globally in WoW
gsub = string.gsub

-- ── WoW chat frame stub ───────────────────────────────────────────────────────
DEFAULT_CHAT_FRAME = {
    _messages = {},
    AddMessage = function(self, msg, r, g, b)
        table.insert(self._messages, msg)
    end,
}

-- ── WoW time / memory stubs ──────────────────────────────────────────────────
-- WoW provides a global time(); in plain Lua 5.1 it is os.time().
time = os.time
-- These are used only in tested functions that require WoW addon system:
function UpdateAddOnMemoryUsage() end
function GetAddOnMemoryUsage() return 0 end
function debugstack(level) return "" end
local _original_collectgarbage = collectgarbage
function collectgarbage(opt, ...)
    if opt == "count" then
        return 0
    end
    if opt == nil then
        -- Match Lua 5.1 semantics: collectgarbage() with no args is valid
        return _original_collectgarbage()
    end
    -- Delegate all other options to the original implementation
    return _original_collectgarbage(opt, ...)
end

-- ── WoW item API stubs ────────────────────────────────────────────────────────
function GetItemInfo(item)
    -- Return a minimal fake item for testing (matches real WoW GetItemInfo signature)
    -- name, link, quality, iLevel, reqLevel, type, subType, stackCount, equipLoc, icon, vendorPrice
    return "TestItem", "|cffffffff|Hitem:1234:0:0:0:0:0:0:0:0|h[TestItem]|h|r",
           4, 60, 1, "Weapon", "Swords", 1, "", "Interface\\Icons\\INV_Sword_04", 100
end

function GetNumAuctionItems(listType)
    return 0, 0
end

function GetAuctionItemInfo(listType, index)
    return "TestItem", nil, 1, 4, true, 60, 100, 0, 200, 0, nil, "TestPlayer"
end

-- ── Auction house stubs ───────────────────────────────────────────────────────
function GetSellValue() return 0 end
function GetAuctionBuyout() return nil end

-- ── Misc WoW globals ─────────────────────────────────────────────────────────
function GetTime() return 0 end
function UIErrorsFrame() end
function IsAddOnLoaded() return false end

-- Fake WoW UIParent (many OnLoad scripts reference it)
UIParent = {}
