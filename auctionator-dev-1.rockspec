-- LuaRocks specification for Auctionator test dependencies.
-- Install dev dependencies with:
--   luarocks install --deps-only auctionator-dev-1.rockspec

package = "auctionator-dev"
version = "1-0"

source = {
    url = "https://github.com/ayanimea/Auctionator-3.3.5-Fixed",
}

description = {
    summary  = "Auctionator WoW 3.3.5 addon – dev/test dependencies",
    homepage = "https://github.com/ayanimea/Auctionator-3.3.5-Fixed",
}

dependencies = {
    "lua >= 5.1",
    "busted >= 2.0",
    "luacheck >= 1.0",
    "luabitop >= 1.0",
}

build = {
    type = "none",
}
