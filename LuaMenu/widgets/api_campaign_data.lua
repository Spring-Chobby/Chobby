--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Data Handler",
		desc      = "",
		author    = "KingRaptor",
		date      = "2016.07.05",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local CAMPAIGN_DIR = "campaign/"

local SAVE_DIR = "Saves/campaign/"
local AUTOSAVE_DIR = SAVE_DIR .. "/auto"
--local MAX_SAVES = 999
local AUTOSAVE_ID = "auto"
local AUTOSAVE_FILENAME = "autosave"

local starmapAnimation = nil

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------
-- this stores anything that goes into a save file
local gamedata = {}

local campaignDefs = {}	-- {name, author, image, definition, starting function call}
local campaignDefsByID = {}

-- loaded when campaign is loaded
local planetDefs = {}
local planetDefsByID = {}
local missionDefs = {}
local codexEntries = {}

local saves = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function ResetGamedata()
	gamedata = {
		chapterTitle = "",
		campaignID = nil,
		vnStory = nil,
		nextMissionScript = nil,
		
		commConfig = {},
		unitsUnlocked = {},
		modulesUnlocked = {},
		retinue = {},
		missionsCompleted = {},
		scenesUnlocked = {},
		codexUnlocked = {},
		codexRead = {},
		
		vars = {},
	}
	planetDefs = {}
	planetDefsByID = {}
	missionDefs = {}
	codexEntries = {}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- FIXME: no way to actually detect if we're missing a rapid mod atm
local function GetGameIfNeeded(game)
	return false
	--[[
	if not game then return false end
	
	if not VFS.HasArchive(game) then
		VFS.DownloadArchive(game, "game")
		return true
	end
	return false
	--]]
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Called on Initialize
local function LoadCampaignDefs()
	local success, err = pcall(function()
		local subdirs = VFS.SubDirs(CAMPAIGN_DIR)
		for i,subdir in pairs(subdirs) do
			local success2, err2 = pcall(function()
				if VFS.FileExists(subdir .. "campaigninfo.lua") then
					local def = VFS.Include(subdir .. "campaigninfo.lua")
					def.dir = subdir
					def.vnDir = subdir .. (def.vnDir or 'vn')
					campaignDefs[#campaignDefs+1] = def
					campaignDefsByID[def.id] = def
				end
			end)
			if (not success2) then
				Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading campaign defs: " .. err2)
			end
		end
		table.sort(campaignDefs, function(a, b) return (a.order or 100) < (b.order or 100) end) 
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading campaign defs: " .. err)
	end
end

-- This is called when a new game is started or a save is loaded
local function LoadCampaign(campaignID)
	local def = campaignDefsByID[campaignID]
	local success, err = pcall(function()
		local planetDefPath = def.dir .. "planetDefs.lua"
		local missionDefPath = def.dir .. "missionDefs.lua"
		local codexDefPath = def.dir .. "codex.lua"
		planetDefs = VFS.FileExists(planetDefPath) and VFS.Include(planetDefPath) or {}
		missionDefs = VFS.FileExists(missionDefPath) and VFS.Include(missionDefPath) or {}
		codexEntries = VFS.FileExists(codexDefPath) and VFS.Include(codexDefPath) or {}
		for i=1,#planetDefs do
			planetDefsByID[planetDefs[i].id] = planetDefs[i]	
		end
		
		GetGameIfNeeded(def.game)
		
		if def.startFunction then
			def.startFunction()
		end
		
		--if WG.MusicHandler then
		--	WG.MusicHandler.StopTrack()
		--end
		
		gamedata.campaignID = campaignID
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading campaign " .. campaignID .. ": " .. err)
	end
end

-- Sets the next Visual Novel script to be played on clicking the Next Episode button in intermission
local function SetNextMissionScript(script)
	gamedata.nextMissionScript = script
end

-- Tells Visual Novel widget to load a story
local function SetVNStory(story, dir)
	if (not story) or story == "" then
		return
	end
	dir = dir or campaignDefsByID[gamedata.campaignID].vnDir
	gamedata.vnStory = story
	WG.VisualNovel.LoadStory(story, dir)
end

-- chapter titles are visible on save file
local function SetChapterTitle(title)
	gamedata.chapterTitle = title
end

local function GetCampaignTitle(campaignID)
	if campaignDefsByID[campaignID] then
		return campaignDefsByID[campaignID].name
	end
	return nil
end

-- TODO mission handler (has its own widget now, just do campaign-specific stuff here)
--[[
local function CleanupAfterMission()
	runningMission = false
	missionCompletionFunc = nil
end

local function GetMissionStartscript(missionID)
	local dir = campaignDefsByID[gamedata.campaignID].dir
	local startscript = missionDefs[missionID].startscript
	startscript = dir .. startscript
	local scriptTable = VFS.Include(startscript)
	return scriptTable
end

-- Checks if we have the map specified in the mission's startscript, if not download it
local function GetMapForMissionIfNeeded(missionID, startscript)
	local startscript = startscript or GetMissionStartscript(missionID)
	local map = startscript["MapName"] or startscript["mapname"]
	if not VFS.HasArchive(map) then
		VFS.DownloadArchive(map, "map")
		requiredMap = map
		return map
	end
	return nil
end

local function ScriptTXT(script)
	local string = '[Game]\n{\n\n'

	-- First write Tables
	for key, value in pairs(script) do
		if type(value) == 'table' then
			string = string..'\t['..key..']\n\t{\n'
			for key, value in pairs(value) do
				string = string..'\t\t'..key..' = '..value..';\n'
			end
			string = string..'\t}\n\n'
		end
	end

	-- Then the rest (purely for aesthetics)
	for key, value in pairs(script) do
		if type(value) ~= 'table' then
			string = string..'\t'..key..' = '..value..';\n'
		end
	end
	string = string..'}'
	return string
end

local function LaunchMission(missionID, func)
	local success, err = pcall(function()
		local dir = campaignDefsByID[gamedata.campaignID].dir
		local startscript = GetMissionStartscript(missionID)
		--missionArchive = dir .. missionDefs[missionName].archive
		--VFS.MapArchive(missionArchive)
		
		-- check for map
		local needMap = GetMapForMissionIfNeeded(missionID, startscript)
		if needMap then
			WG.VisualNovel.scriptFunctions.Exit()
			WG.Chobby.InformationPopup("You do not have the map " .. needMap .. " required for this mission. It will now be downloaded.")
			return
		end
		
		-- TODO: check for game
		local game = campaignDefsByID[gamedata.campaignID].game
		if GetGameIfNeeded(game) then
			WG.VisualNovel.scriptFunctions.Exit()
			WG.Chobby.InformationPopup("You do not have the game " .. game .. " required to play the campaign. It will now be downloaded.")
			return	
		end
		
		-- TODO: might want to edit startscript before we run Spring with it
		local scriptString = ScriptTXT(startscript)
		
		WG.VisualNovel.scriptFunctions.Exit()
		WG.LibLobby.localLobby:StartGameFromString(scriptString)
		runningMission = true
		missionCompletionFunc = func
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error launching mission: " .. err)
	end
end
]]

--------------------------------------------------------------------------------
-- Savegame utlity functions
--------------------------------------------------------------------------------
-- Returns the data stored in a save file
local function GetSave(filepath)
	local ret = nil
	local success, err = pcall(function()
		local saveData = VFS.Include(filepath)
		local campaignDef = campaignDefsByID[saveData.campaignID]
		--if (campaignDef) then
			ret = saveData
		--end
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
	saves = {}
	local savefiles = VFS.DirList(SAVE_DIR, "*.lua")
	for i=1,#savefiles do
		local filepath = savefiles[i]
		local saveData = GetSave(filepath)
		if saveData then
			saves[saveData.name] = saveData
		end
	end
	if VFS.FileExists(SAVE_DIR .. AUTOSAVE_FILENAME .. ".lua") then
		local saveData = GetSave(SAVE_DIR .. AUTOSAVE_FILENAME .. ".lua")
		if saveData then
			saves[AUTOSAVE_FILENAME] = saveData
		end
	end
	return saves
end

-- e.g. if save slots 1, 2, 5, and 7 are used, return 3
--[[
local function FindFirstEmptySaveSlot()
	local start = #saves
	if start == 0 then start = 1 end
	for i=start,MAX_SAVES do
		if saves[i] == nil then
			return i
		end
	end
	return MAX_SAVES
end
]]

--------------------------------------------------------------------------------
-- star map stuff
--------------------------------------------------------------------------------
local function IsMissionUnlocked(missionID)
	local mission = missionDefs[missionID]
	if not mission then
		return false
	end
	-- any completed missions are considered unlocked
	if gamedata.missionsCompleted[missionID] then
		return true
	-- no missions required to lock this
	elseif #(mission.requiredMissions or {}) == 0 then
		return true
	end
	-- check if we have completed any set of required missions
	for j, requiredMissionSet in ipairs(mission.requiredMissions) do
		for k, requiredMissionID in ipairs(requiredMissionSet) do
			if gamedata.missionsCompleted[requiredMissionID] then
				return true
			end
		end
	end
	return false
end

-- returns true if any missions on the planet have been completed or unlocked
local function IsPlanetVisible(planetDef)
	for i=1,#planetDef.missions do
		local missionID = planetDef.missions[i]
		if IsMissionUnlocked(missionID) then
			return true
		end
	end
	return false
end
--------------------------------------------------------------------------------
-- Save/load, progression
--------------------------------------------------------------------------------
local function SaveGame(filename, description, autosave)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		local isAutosave = (id == AUTOSAVE_ID)
		path = SAVE_DIR .. (isAutosave and AUTOSAVE_FILENAME or filename) .. ".lua"
		local saveData = Spring.Utilities.CopyTable(gamedata, true)
		saveData.name = filename
		saveData.date = os.date('*t')
		saveData.description = isAutosave and "" or description
		table.save(saveData, path)
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Saved game to " .. path)
		--Spring.Echo(widget:GetInfo().name .. ": Saved game to " .. path)
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
		LoadCampaign(saveData.campaignID)
		gamedata = Spring.Utilities.MergeTable(saveData, gamedata, true)
		SetVNStory(gamedata.vnStory, campaignDefsByID[gamedata.campaignID].vnDir)
		--Spring.Log(widget:GetInfo().name, LOG.INFO, "Save file " .. path .. " loaded")
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading game: " .. err)
	end
end

local function LoadGameByFilename(filename)
	LoadGame(saves[filename])
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
	if not gamedata.campaignID then
		return
	end
	LoadCampaign(gamedata.campaignID)
end

local function AdvanceCampaign(completedMissionID, nextScript, chapterTitle)
	SetNextMissionScript(nextScript)
	SetChapterTitle(chapterTitle)
	gamedata.missionsCompleted[completedMissionID] = true
	SaveGame(AUTOSAVE_ID)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function UnlockScene(id)
	gamedata.scenesUnlocked[id] = true
end

local function UnlockCodexEntry(id)
	gamedata.codexUnlocked[id] = true
end

local function MarkCodexEntryRead(id)
	gamedata.codexRead[id] = true
end

local function UnlockUnit(id)
	gamedata.unitsUnlocked[id] = true
end

local function UnlockModule(id)
	gamedata.modulesUnlocked[id] = true
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- callins

-- called when returning to menu from a game
function widget:ActivateMenu()
	--Spring.Log(widget:GetInfo().name, LOG.INFO, "ActivateMenu called", runningMission)
	if runningMission then
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Finished running mission")
		if VFS.FileExists(RESULTS_FILE_PATH) then
			local results = VFS.Include(RESULTS_FILE_PATH)
			missionCompletionFunc(results)
		else
			Spring.Log(widget:GetInfo().name, LOG.ERROR, "Unable to load mission results file")
		end
		CleanupAfterMission()
	end
end

function widget:DownloadFinished()
	if requiredMap and VFS.HasArchive(requiredMap) then
		requiredMap = nil
	end
end

local externalFunctions = {
	--GetCurrentData = nil,
	--LoadCampaign = LoadCampaign,
	--GetCampaigns = GetCampaigns
	GetPlanetDefs = function() return planetDefs end,
	GetCodexEntries = function() return codexEntries end,
	GetCampaignTitle = GetCampaignTitle,
	IsCodexEntryRead = function(id) return gamedata.codexRead[id] end,
	
	SaveGame = SaveGame,
	LoadGame = LoadGame,
	LoadGameByFilename = LoadGameByFilename,
	GetSaves = GetSaves,
	
	SetChapterTitle = SetChapterTitle,
	SetVNStory = SetVNStory,
	SetNextMissionScript = SetNextMissionScript,
	AdvanceCampaign = AdvanceCampaign,
	
	UnlockScene = UnlockScene,
	UnlockUnit = UnlockUnit,
	UnlockModule = UnlockModule,
	UnlockCodexEntry = UnlockCodexEntry,
	MarkCodexEntryRead = MarkCodexEntryRead,
	
	SetMapEnabled = function(bool) gamedata.mapEnabled = bool end,
	GetMapForMissionIfNeeded = GetMapForMissionIfNeeded,
	LaunchMission = LaunchMission,
}

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignAPI = externalFunctions
	
	ResetGamedata()
	LoadCampaignDefs()
	
	-- debug
	LoadCampaign('sample')
end

function widget:Shutdown()
	WG.CampaignAPI = nil
end