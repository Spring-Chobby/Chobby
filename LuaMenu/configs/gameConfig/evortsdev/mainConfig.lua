local zkBaseConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/evorts/mainConfig.lua")
local shortname = "evortsdev"

local skirmishDefault    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skirmishDefault.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

zkBaseConfig.dirName                 = "evortsdev"
zkBaseConfig.name                    = "EvoRTS Dev"
zkBaseConfig._defaultGameArchiveName = "Evolution RTS - $VERSION"
zkBaseConfig._defaultGameRapidTag    = nil
zkBaseConfig.skirmishDefault         = skirmishDefault

return zkBaseConfig
