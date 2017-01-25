local zkBaseConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/zk/mainConfig.lua")
local shortname = "zkdev"

local singleplayerConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/singleplayerMenu.lua")
local skirmishDefault    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skirmishDefault.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

zkBaseConfig.dirName                 = "zkdev"
zkBaseConfig.name                    = "Zero-K Dev"
zkBaseConfig._defaultGameArchiveName = "Zero-K $VERSION"
zkBaseConfig._defaultGameRapidTag    = nil
zkBaseConfig.singleplayerConfig      = singleplayerConfig
zkBaseConfig.skirmishDefault         = skirmishDefault

return zkBaseConfig
