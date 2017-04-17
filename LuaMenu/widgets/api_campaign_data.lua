--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Data Handler",
		desc      = "",
		author    = "KingRaptor & GoogleFrog",
		date      = "2 March 2017",
		license   = "GNU GPL, v2 or later",
		layer     = -1000,
		enabled   = true,  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------

local moduleDefs, chassisDefs, upgradeUtilities, UNBOUNDED_LEVEL, _, moduleDefNames = VFS.Include("Gamedata/commanders/dynamic_comm_defs.lua")

-- this stores anything that goes into a save file
local gamedata = {}

local externalFunctions = {}

local SAVE_DIR = "Saves/campaign/"
local ICONS_DIR = LUA_DIRNAME .. "configs/gameConfig/zk/unitpics/"

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

local function UnlockListOfThings(unlockList, unlocksToAdd)
	for i = 1, #unlocksToAdd do
		UnlockThing(unlockList, unlocksToAdd[i])
	end
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
		modulesUnlocked = {map = {}, list = {}},
		abilitiesUnlocked = {map = {}, list = {}},
		codexEntriesUnlocked = {map = {}, list = {}},
		codexEntryRead = {},
		bonusObjectivesComplete = {map = {}, list = {}},
		planetsCaptured = {map = {}, list = {}},
		commanderExperience = 0,
		commanderLevel = 1,
		commanderLoadout = {},
		retinue = {}, -- Unused
	}
end

local function UnlockRewardSet(rewardSet)
	if rewardSet.units then
		UnlockListOfThings(gamedata.unitsUnlocked, rewardSet.units)
	end
	if rewardSet.modules then
		UnlockListOfThings(gamedata.modulesUnlocked, rewardSet.modules)
	end
	if rewardSet.abilities then
		UnlockListOfThings(gamedata.abilitiesUnlocked, rewardSet.abilities)
	end
	if rewardSet.codexEntries then
		UnlockListOfThings(gamedata.codexEntriesUnlocked, rewardSet.codexEntries)
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

local function SaveGame(fileName)
	if fileName then
		WG.Chobby.Configuration:SetConfigValue("campaignSaveFile", fileName)
	else
		fileName = WG.Chobby.Configuration.campaignSaveFile
	end
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

local function LoadGame(saveData, refreshGUI)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		ResetGamedata()
		gamedata = Spring.Utilities.MergeTable(saveData, gamedata, true)
		if refreshGUI then
			CallListeners("CampaignLoaded")
		end
		WG.Chobby.Configuration:SetConfigValue("campaignSaveFile", saveData.name)
	
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Save file " .. saveData.name .. " loaded")
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading game: " .. err)
	end
end

local function StartNewGame()
	local Configuration = WG.Chobby.Configuration
	ResetGamedata()
	
	local planets = Configuration.campaignConfig.planetDefs.initialPlanets
	UnlockRewardSet(Configuration.campaignConfig.initialUnlocks)
	for i = 1, #planets do
		externalFunctions.CapturePlanet(planets[i])
	end
	SaveGame()
	
	CallListeners("CampaignLoaded")
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
		UnlockRewardSet(planet.completionReward)
		CallListeners("RewardGained", planet.completionReward)
		CallListeners("PlanetCaptured", planetID)
		SaveGame()
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

function externalFunctions.SetCodexEntryRead(entryName)
	if not gamedata.codexEntryRead[entryName] then
		gamedata.codexEntryRead[entryName] = true
		SaveGame()
	end
end

function externalFunctions.GetUnitsUnlocks()
	return gamedata.unitsUnlocked
end

function externalFunctions.GetAbilityUnlocks()
	return gamedata.abilitiesUnlocked
end

function externalFunctions.GetUnitIsUnlocked(unitName)
	return gamedata.unitsUnlocked.map[unitName]
end

function externalFunctions.GetModuleIsUnlocked(moduleName)
	return gamedata.modulesUnlocked.map[moduleName]
end

function externalFunctions.GetAbilityIsUnlocked(abilityName)
	return gamedata.abilitiesUnlocked.map[abilityName]
end

function externalFunctions.GetCodexEntryIsUnlocked(entryName)
	return gamedata.codexEntriesUnlocked.map[entryName], gamedata.codexEntryRead[entryName]
end

function externalFunctions.GetUnitInfo(unitName)
	return WG.Chobby.Configuration.gameConfig.gameUnitInformation.humanNames[unitName] or {}, ICONS_DIR .. unitName .. ".png"
end

function externalFunctions.GetAbilityInfo(abilityName)
	local ability = WG.Chobby.Configuration.campaignConfig.abilityDefs[abilityName] or {}
	return ability, ability.image
end

function externalFunctions.GetModuleInfo(moduleName)
	local index = moduleDefNames[moduleName]
	return index and moduleDefs[index] or {}, ICONS_DIR .. moduleName .. ".png"
end

function externalFunctions.GetCodexEntryInfo(codexEntryName)
	return WG.Chobby.Configuration.campaignConfig.codex[codexEntryName] or {}
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
		chassis = "knight",
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
	return gamedata.commanderLevel
end

function externalFunctions.GetSaves()
	return GetSaves()
end

function externalFunctions.LoadGameByFilename(filename)	
	local saves = GetSaves()
	local saveData = saves[filename]
	if saveData then
		LoadGame(saveData, true)
		return
	else
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Save " .. filename .. " does not exist")
	end
end

function externalFunctions.DeleteSave(filename)
	local Configuration = WG.Chobby.Configuration
	
	local success, err = pcall(function()
		local pathNoExtension = SAVE_DIR .. "/" .. filename
		os.remove(pathNoExtension .. ".lua")
		if (filename == Configuration.campaignSaveFile) then
			-- if this is current save, switch to next available save slot, or revert to "Campaign1" if none are available
			local newName = "Campaign1"
			local saves = GetSaves()
			for name, save in pairs(saves) do
				-- TODO: sort instead of just picking the first one?
				newName = save.name
				LoadGame(save, true)
				break
			end
			WG.Chobby.Configuration:SetConfigValue("campaignSaveFile", newName)
		end
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error deleting save " .. filename .. ": " .. err)
	end
	return success
end

externalFunctions.StartNewGame = StartNewGame

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
