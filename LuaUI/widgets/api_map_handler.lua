--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Map Handler API",
		desc      = "Loads maps and provides useful map information.",
		author    = "GoogleFrog",
		date      = "30 June 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -10000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local MapHandler = {}

function MapHandler.GetMapList()
	return {}
end

function MapHandler.GetMapTeamLimit(mapName, gameName) -- Configs should be able to depend on game.
	return false -- false means unlimited. A number means there is a limit.
end

-- Possible TODO
-- MapHandler.GetMapMinimapImage
-- MapHandler.GetMapInfo (dimensions, wind etc...?)

function widget:Initialize()
	WG.MapHandler = MapHandler
end