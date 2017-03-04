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

local externalFunctions = {}

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
-- Game data

local function ResetGamedata()
	gamedata = {
		unitsUnlocked = {map = {}, list = {}},
		planetsCaptured = {map = {}, list = {}},
		retinue = {
			{
				unitDefName = "armpw",
				retinueID = 1,
				experience = 3,
				active = true,
			},
			{
				unitDefName = "armorco",
				retinueID = 2,
				experience = 1,
				active = true,
			},
			{
				unitDefName = "armrock",
				retinueID = 3,
				experience = 1,
				active = false,
			}
		},
	}
end

local function UnlockUnits(unlockList)
	for i = 1, #unlockList do
		UnlockThing(gamedata.unitsUnlocked, unlockList[i])
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Save/Load
-- Returns the data stored in a save file
local function GetSave(filepath)
	local ret = nil
	local success, err = pcall(function()
		local saveData = VFS.Include(filepath)
		ret = saveData
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error getting saves: " .. err)
	else
		return ret
	end
end

-- Loads the list of save files and their contents
local function GetSaves()
	Spring.CreateDir(SAVE_DIR)
	local saves = {}
	local savefiles = VFS.DirList(SAVE_DIR, "*.lua")
	for i = 1, #savefiles do
		local filepath = savefiles[i]
		local saveData = GetSave(filepath)
		if saveData then
			saves[saveData.name] = saveData
		end
	end
	return saves
end

local function SaveGame()
	local fileName = WG.Chobby.Configuration.campaignSaveFile
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		path = SAVE_DIR .. fileName .. ".lua"
		local saveData = Spring.Utilities.CopyTable(gamedata, true)
		saveData.name = fileName
		saveData.date = os.date('*t')
		saveData.description = isAutosave and "" or description
		table.save(saveData, path)
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Saved game to " .. path)
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error saving game: " .. err)
	end
	return success
end

local function LoadGame(saveData)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		ResetGamedata()
		gamedata = Spring.Utilities.MergeTable(saveData, gamedata, true)
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Save file " .. saveData.name .. " loaded")
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading game: " .. err)
	end
end

local function DeleteSave(id)
	local success, err = pcall(function()
		local path = SAVE_DIR .. (id == AUTOSAVE_ID and AUTOSAVE_FILENAME or ("save" .. string.format("%03d", id))) .. ".lua"
		os.remove(path)
		local num = 0
		local parent = nil
		for i=1,#saveLoadControls do
			num = i
			local entry = saveLoadControls[i]
			if entry.id == id then
				parent = entry.container.parent
				entry.container:Dispose()
				table.remove(saveLoadControls, i)
				break
			end
		end
		-- reposition save entry controls
		for i=num,#saveLoadControls do
			local entry = saveLoadControls[i]
			entry.container.y = entry.container.y - (SAVEGAME_BUTTON_HEIGHT)
		end
		parent:Invalidate()
		
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error deleting save " .. id .. ": " .. err)
	end
end

local function StartNewGame()
	local Configuration = WG.Chobby.Configuration
	local planets = Configuration.campaignConfig.planetDefs.initialSetup.planets
	ResetGamedata()
	for i = 1, #planets do
		externalFunctions.CapturePlanet(planets[i])
	end
	SaveGame()
end

local function LoadCampaignData()
	local Configuration = WG.Chobby.Configuration
	local saves = GetSaves()
	local saveData = saves[Configuration.campaignSaveFile]
	if saveData then
		LoadGame(saveData)
		return
	end
	StartNewGame(Configuration.campaignSaveFile)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function externalFunctions.CapturePlanet(planetID)
	local planet = WG.Chobby.Configuration.campaignConfig.planetDefs.planets[planetID]
	if UnlockThing(gamedata.planetsCaptured, planetID) then
		UnlockUnits(planet.completionReward.units)
		SaveGame()
		CallListeners("PlanetCaptured", planetID)
	end
end

function externalFunctions.GetPlanetDefs()
	local planetData = planetDefPath and VFS.FileExists(planetDefPath) and VFS.Include(planetDefPath)
	if planetData then
		return planetData
	end
	return {}
end

function externalFunctions.IsPlanetCaptured(planetID)
	return gamedata.planetsCaptured.map[planetID]
end

function externalFunctions.GetRetinue()
	return gamedata.retinue
end

function externalFunctions.GetActiveRetinue()
	local activeRetinue = {}
	for i = 1, #gamedata.retinue do
		if gamedata.retinue[i].active then
			activeRetinue[#activeRetinue + 1] = gamedata.retinue[i]
		end
	end
	return activeRetinue
end

function externalFunctions.GetPlayerCommander()
	return {
		name = "blubb.",
		chassis = "guardian",
		decorations = {
			icon_overhead = { image = "UW" }
		},
		modules = {
			{
				"commweapon_heavymachinegun",
				"module_dmg_booster"
			},
			{
				"module_dmg_booster",
				"module_dmg_booster"
			},
			{
				"commweapon_rocketlauncher",
				"module_dmg_booster",
				"module_dmg_booster"
			},
			{
				"module_dmg_booster",
				"module_dmg_booster",
				"module_adv_targeting"
			},
			{
				"module_adv_targeting",
				"module_adv_targeting",
				"module_adv_targeting"
			}
		}
	}
end

function externalFunctions.GetPlayerCommanderLevel()
	return 2
end

function externalFunctions.GetSaveSlotControl()
	local window = Control:New {
		name = "saveSlotHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0,0,0,0},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialiazation

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignData = externalFunctions
	
	WG.Delay(LoadCampaignData, 0.1)
end

function widget:Shutdown()
	WG.CampaignData = nil
end
