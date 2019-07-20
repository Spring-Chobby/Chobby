local shortname = "evorts"

local mapWhitelist       = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/mapWhitelist.lua")
local aiBlacklist        = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/aiBlacklist.lua")
local singleplayerConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/singleplayerMenu.lua")
local skirmishDefault    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skirmishDefault.lua")
local defaultModoptions  = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/ModOptions.lua")
local rankFunction       = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/zk/rankFunction.lua")
local backgroundConfig   = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/skinConfig.lua")

local settingsConfig, settingsNames, settingsDefault = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/settingsMenu.lua")

local headingLarge    = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingLarge.png"
local headingSmall    = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingSmall.png"
local backgroundImage = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/background.jpg"
local taskbarIcon     = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/taskbarLogo.png"

local background = {
	image           = backgroundImage,
	backgroundFocus = backgroundConfig.backgroundFocus,
}

local minimapOverridePath  = LUA_DIRNAME .. "configs/gameConfig/zk/minimapOverride/"
local minimapThumbnailPath = LUA_DIRNAME .. "configs/gameConfig/zk/minimapThumbnail/"

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	dirName                = "evorts",
	name                   = "Evolution RTS",
	--_defaultGameArchiveName = "??", fill this in.
	_defaultGameRapidTag   = "evo:stable", -- Do not read directly
	editor                 = "rapid://sb-evo:test",
	--editor                 = "SpringBoard EVO $VERSION",
	mapWhitelist           = mapWhitelist,
	aiBlacklist            = aiBlacklist,
	settingsConfig         = settingsConfig,
	settingsNames          = settingsNames,
	settingsDefault        = settingsDefault,
	singleplayerConfig     = singleplayerConfig,
	helpSubmenuConfig      = {},
	skirmishDefault        = skirmishDefault,
	defaultModoptions      = defaultModoptions,
	rankFunction           = rankFunction,
	headingLarge           = headingLarge,
	headingSmall           = headingSmall,
	taskbarTitle           = "Evolution RTS",
	taskbarTitleShort      = "Evo RTS",
	taskbarIcon            = taskbarIcon,
	background             = background,
	minimapOverridePath    = minimapOverridePath,
	minimapThumbnailPath   = minimapThumbnailPath,
	ignoreServerVersion    = true,
	disableBattleListHostButton = true, -- Hides "Host" button as this function is not working as one might imagine
	disableSteam 				= true, -- removes settings related to steam
	disablePlanetwars 			= true, -- removes settings related to planetwars
	disableMatchMaking 			= true, -- removes match making
	disableCommunityWindow 		= true, -- removes Community Window
}

function externalFuncAndData.CheckAvailability()
	return true
end

return externalFuncAndData
