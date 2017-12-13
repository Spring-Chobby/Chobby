local evoBaseConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/evorts/mainConfig.lua")
local shortname = "evortsdev"

local skirmishDefault    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skirmishDefault.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

evoBaseConfig.dirName                 = "evortsdev"
evoBaseConfig.name                    = "EvoRTS Dev"
evoBaseConfig.taskbarTitle            = "Evolution RTS Dev"
evoBaseConfig.taskbarTitleShort       = "Evo RTS Dev"
evoBaseConfig._defaultGameArchiveName = "Evolution RTS - $VERSION"
evoBaseConfig._defaultGameRapidTag    = nil
evoBaseConfig.skirmishDefault         = skirmishDefault

return evoBaseConfig
