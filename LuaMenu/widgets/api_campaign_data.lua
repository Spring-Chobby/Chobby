--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Data Handler",
		desc      = "",
		author    = "KingRaptor & GoogleFrog",
		date      = "2 March 2017",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------
-- this stores anything that goes into a save file
local gamedata = {}

local SAVE_DIR = "Saves/campaign/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function UnlockThing(thingData, id)
	if thingData.map[id] then
		return false
	end
	thingData.map[id] = true
	thingData.list[#thingData.list + 1] = id
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local listeners = {}

local function CallListeners(event, ...)
	if listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = Spring.Utilities.ShallowCopy(listeners[event])
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		args = {...}
		xpcall(function() listener(listener, unpack(args)) end,
			function(err) Spring.Echo("Campaign Listener Error", err) end )
	end
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Game data

local function ResetGamedata()
	gamedata = {
		unitsUnlocked = {map = {}, list = {}},
		planetsCaptured = {map = {}, list = {}},
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local externalFunctions = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listener handler

function externalFunctions.AddListener(event, listener)
	if listener == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function externalFunctions.RemoveListener(event, listener)
	if listeners[event] then
		for k, v in pairs(listeners[event]) do
			if v == listener then
				table.remove(listeners[event], k)
				if #listeners[event] == 0 then
					listeners[event] = nil
				end
				break
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function externalFunctions.UnlockUnits(unlockList)
	for i = 1, #unlockList do
		UnlockThing(gamedata.unitsUnlocked, unlockList[i])
	end
end

function externalFunctions.CapturePlanet(planetID, unlockList)
	if UnlockThing(gamedata.planetsCaptured, planetID) then
		UnlockUnits(unlockList)
	end
end

function externalFunctions.GetPlanetDefs()
	local planetData = planetDefPath and VFS.FileExists(planetDefPath) and VFS.Include(planetDefPath)
	if planetData then
		return planetData
	end
	return {}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callouts

function externalFunctions.IsPlanetCaptured(planetID)
	return gamedata.planetsCaptured.map[planetID]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialiazation

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignData = externalFunctions
	
	ResetGamedata()
end

function widget:Shutdown()
	WG.CampaignData = nil
end
