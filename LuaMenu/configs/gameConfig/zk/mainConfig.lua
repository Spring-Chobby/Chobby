local shortname = "zk"

local mapWhitelist       = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/mapWhitelist.lua")
local aiBlacklist        = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/aiBlacklist.lua")
local singleplayerConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/singleplayerMenu.lua")
local helpSubmenuConfig  = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/helpSubmenuConfig.lua")
local skirmishDefault    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skirmishDefault.lua")
local defaultModoptions  = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/ModOptions.lua")
local rankFunction       = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/rankFunction.lua")
local backgroundConfig   = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/skinConfig.lua")

local link_reportPlayer, link_userPage, link_homePage, link_replays, link_maps, link_particularMapPage = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/linkFunctions.lua")

local settingsConfig, settingsDefault = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/settingsMenu.lua")

local headingLarge    = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingLarge.png"
local headingSmall    = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingSmall.png"
local backgroundImage = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/background.jpg"
local taskbarIcon     = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/taskbarLogo.png"

local subheadings = {
	large = {
		singleplayer = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingSingleplayerLarge.png",
		multiplayer = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingMultiplayerLarge.png",
		help = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingHelpLarge.png",
		campaign = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingCampaignLarge.png",
	},
	small = {
		singleplayer = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingSingleplayerSmall.png",
		multiplayer = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingMultiplayerSmall.png",
		help = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingHelpSmall.png",
		campaign = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingCampaignSmall.png",
	},
}

local background = {
	image           = backgroundImage,
	backgroundFocus = backgroundConfig.backgroundFocus,
}

local minimapOverridePath  = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/minimapOverride/"
local minimapThumbnailPath = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/minimapThumbnail/"

----- Notes on apparently unused paths -----
-- The lups folder is used by settingsMenu.lua, the lups files are copied next to chobby.exe.
-- Images in rankImages are returned by rankFunction.lua
-- The contents of defaultSettings is copied next to chobby.exe by the wrapper.

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	dirName                 = "zk",
	name                    = "Zero-K",
	_defaultGameArchiveName = "Zero-K v1.5.2.5", -- Do not read directly
	_defaultGameRapidTag    = "zk:stable", -- Do not read directly
	mapWhitelist            = mapWhitelist,
	aiBlacklist             = aiBlacklist,
	settingsConfig          = settingsConfig,
	settingsDefault         = settingsDefault,
	singleplayerConfig      = singleplayerConfig,
	helpSubmenuConfig       = helpSubmenuConfig,
	skirmishDefault         = skirmishDefault,
	defaultModoptions       = defaultModoptions,
	rankFunction            = rankFunction,
	headingLarge            = headingLarge,
	headingSmall            = headingSmall,
	subheadings             = subheadings,
	taskbarIcon             = taskbarIcon,
	background              = background,
	minimapOverridePath     = minimapOverridePath,
	minimapThumbnailPath    = minimapThumbnailPath,
	link_reportPlayer       = link_reportPlayer, 
	link_userPage           = link_userPage, 
	link_homePage           = link_homePage,
	link_replays            = link_replays,
	link_maps               = link_maps,
	link_particularMapPage  = link_particularMapPage,
}

function externalFuncAndData.CheckAvailability()
	return true
end

return externalFuncAndData
