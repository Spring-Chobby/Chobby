--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Load Game Menu",
		desc      = "UI for Spring save games",
		author    = "KingRaptor",
		date      = "2016.11.24",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local SAVEGAME_BUTTON_HEIGHT = 128
local OUTLINE_COLOR = {0.54,0.72,1,0.3}
local SAVE_DIR = "Saves"
local SAVE_DIR_LENGTH = string.len(SAVE_DIR) + 2
local AUTOSAVE_DIR = SAVE_DIR .. "/auto"
local MAX_SAVES = 999
--------------------------------------------------------------------------------
-- Chili elements
--------------------------------------------------------------------------------
local Chili
local Window
local Panel
local Grid
local StackPanel
local ScrollPanel
local Label
local Button

-- chili elements
local loadScreen
local loadGrid	-- TODO not used yet
local loadScroll
local loadControls = {}

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------
local saves = {}

local ingame = false

--------------------------------------------------------------------------------
-- General utility functions
--------------------------------------------------------------------------------
-- Makes a control grey for disabled, or whitish for enabled
local function SetControlGreyout(control, state)
	if state then
		control.backgroundColor = {0.4, 0.4, 0.4, 1}
		control.font.color = {0.4, 0.4, 0.4, 1}
		control:Invalidate()
	else
		control.backgroundColor = {.8,.8,.8,1}
		control.font.color = nil
		control:Invalidate()
	end
end

local function WriteDate(dateTable)
	return string.format("%02d/%02d/%04d", dateTable.day, dateTable.month, dateTable.year)
	.. " " .. string.format("%02d:%02d:%02d", dateTable.hour, dateTable.min, dateTable.sec)
end

local function SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00";
	else
		hours = string.format("%02.f", math.floor(seconds/3600));
		mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
	if seconds >= 3600 then
		return hours..":"..mins..":"..secs
	else
		return mins..":"..secs
	end
	end
end

--------------------------------------------------------------------------------
-- Savegame utlity functions
--------------------------------------------------------------------------------
-- FIXME: currently unused as it doesn't seem to give the correct order
local function SortSavesByDate(a, b)
	if a == nil or b == nil then
		return false
	end
	--Spring.Echo(a.id, b.id, a.date.hour, b.date.hour, a.date.hour>b.date.hour)
	
	if a.date.year > b.date.year then return true end
	if a.date.yday > b.date.yday then return true end
	if a.date.hour > b.date.hour then return true end
	if a.date.min > b.date.min then return true end
	if a.date.sec > b.date.sec then return true end
	return false
end

local function SortSavesByFilename(a, b)
	if a == nil or b == nil then
		return false
	end
	if a.filename and b.filename then
		return a.filename > b.filename
	end
	return false
end

-- Returns the data stored in a save file
local function GetSave(path)
	local ret = nil
	local success, err = pcall(function()
		local saveData = VFS.Include(path)
		saveData.filename = string.sub(path, SAVE_DIR_LENGTH, -5)	-- pure filename without directory or extension
		saveData.path = path
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
	saves = {}
	local savefiles = VFS.DirList(SAVE_DIR, "*.lua")
	for i=1,#savefiles do
		local path = savefiles[i]
		local saveData = GetSave(path)
		if saveData then
			saves[#saves + 1] = saveData
		end
	end
	table.sort(saves, SortSavesByFilename)
end

local function GetSaveDescText(saveFile)
	if not saveFile then return "" end
	return (saveFile.description or "no description")
		.. "\n" .. saveFile.gameName .. " " .. saveFile.gameVersion
		.. "\n" .. saveFile.map
		.. "\n" .. i18n("time_ingame") .. ": " .. SecondsToClock(saveFile.gameframe/30)
		.. "\n" .. WriteDate(saveFile.date)
end

-- remove the controls representing each savegame
local function RemoveSaveControls(filename)
	local function remove(tbl, filename)
		local parent = nil
		for i=1,#tbl do
			local entry = tbl[i]
			if entry.filename == filename then
				parent = entry.container.parent
				entry.container:Dispose()
				table.remove(tbl, i)
				break
			end
		end
		parent:Invalidate()
	end
	remove(loadControls, filename)
end

local function RemoveAllSaveControls()
	for i=1,#loadControls do
		loadControls[i].container:Dispose()
	end
	loadControls = {}
end

-- redefined later
local function OpenLoadMenu()
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function LoadGameByFilename(filename)
	Spring.Echo(filename)
	local saveData = GetSave(SAVE_DIR .. '/' .. filename .. ".lua")
	if saveData then
		local success, err = pcall(function()		
			--Spring.Log(widget:GetInfo().name, LOG.INFO, "Save file " .. path .. " loaded")
			local script = [[
[GAME]
{
	SaveFile=__FILE__;
	IsHost=1;
	OnlyLocal=1;
	MyPlayerName=__PLAYERNAME__;
}
]]
			script = script:gsub("__FILE__", filename .. ".slsf")
			script = script:gsub("__PLAYERNAME__", saveData.playerName)
			Spring.Reload(script)
		end)
		if (not success) then
			Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading game: " .. err)
		end
	else
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Save game " .. filename .. " not found")
	end
end

local function DeleteSave(filename)
	local success, err = pcall(function()
		local pathNoExtension = SAVE_DIR .. "/" .. filename
		os.remove(pathNoExtension .. ".lua")
		os.remove(pathNoExtension .. ".slsf")
		RemoveSaveControls(filename)
		-- TODO notify gameside widget to refresh
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error deleting save " .. filename .. ": " .. err)
	end
end

--------------------------------------------------------------------------------
-- Save/Load UI
--------------------------------------------------------------------------------
local function SaveLoadConfirmationDialogPopup(filename, saveMode)
	local text = i18n("load_confirm")
	local yesFunc = function()
			LoadGameByFilename(filename)
		end
	WG.Chobby.ConfirmationPopup(yesFunc, text, nil, 360, 200)
end

-- Makes a button for a save game on the save/load screen
local function AddSaveEntryButton(saveFile, allowSave)
	local controlsEntry = {filename = saveFile and saveFile.filename}
	local parent = allowSave and saveStack or loadStack	--saveScroll or loadScroll	-- FIXME: use grid?
	
	controlsEntry.container = Panel:New {
		parent = parent,
		height = SAVEGAME_BUTTON_HEIGHT,
		width = "100%",
		x = 0,
		--y = (SAVEGAME_BUTTON_HEIGHT) * count,
		caption = "",
		--backgroundColor = {1,1,1,0},
	}
	controlsEntry.button = Button:New {
		parent = controlsEntry.container,
		x = 4,
		right = (saveFile and 96 + 8 or 0) + 4,
		y = 4,
		bottom = 4,
		caption = "",
		OnClick = { function(self)
				if ingame then
					SaveLoadConfirmationDialogPopup(saveFile.filename, false)
				else
					LoadGameByFilename(saveFile.filename)
				end
			end
		}
	}
	--controlsEntry.stack = StackPanel:New {
	--	parent = controlsEntry.button,
	--	height = "100%",
	--	width = "100%",
	--	orientation = "vertical",
	--	resizeItems = false,
	--	autoArrangeV = false,	
	--}
	local caption = saveFile and saveFile.filename or i18n("save_new_game")
	controlsEntry.titleLabel = Label:New {
		parent = controlsEntry.button,
		caption = caption,
		valign = "center",
		x = 8,
		y = 8,
		font = { size = 16 },
	}
	if saveFile then
		controlsEntry.descTextbox = TextBox:New {
			parent = controlsEntry.button,
			x = 8,
			y = 24,
			right = 8,
			bottom = 8,
			text = GetSaveDescText(saveFile),
			font = { size = 14 },
		}
		
		controlsEntry.deleteButton = Button:New {
			parent = controlsEntry.container,
			width = 96,
			right = 4,
			y = 4,
			bottom = 4,
			caption = i18n("delete"),
			--backgroundColor = {0.4,0.4,0.4,1},
			OnClick = { function(self)
					WG.Chobby.ConfirmationPopup(function(self) DeleteSave(saveFile.filename) end, i18n("delete_confirm"), nil, 360, 200)
				end
			}
		}
	end
	return controlsEntry
end

-- Generates the buttons for the savegames on the save/load screen
local function AddSaveEntryButtons()
	local startIndex = #saves
	for i=startIndex,1,-1 do
		loadControls[#loadControls + 1] = AddSaveEntryButton(saves[i])
	end
end

OpenLoadMenu = function(save)
	GetSaves()
	RemoveAllSaveControls()
	AddSaveEntryButtons(save)
	return loadScreen
end

--------------------------------------------------------------------------------
-- Make Chili controls
--------------------------------------------------------------------------------
local function InitializeLoadWindow()
		loadScroll = ScrollPanel:New {
		name = 'chobby_loadgame_loadScroll',
		orientation = "vertical",
		x = 0,
		y = 56,
		width = "100%",
		bottom = 8,
		children = {}
	}
	loadStack = StackPanel:New {
		name = 'chobby_loadgame_loadStack',
		parent = loadScroll,
		orientation = "vertical",
		width = "100%",
		x = 0,
		y = 0,
		autosize = true,
		resizeItems = false,
		autoArrangeV = false,
	}
	loadScreen = Panel:New {
		--parent = window,
		name = 'chobby_loadgame_load',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_loadgame_loadTitle',
				caption = string.upper(i18n("load")),
				x = 4,
				y = 8,
				font = {
					size = 40,
					outlineWidth = 10,
					outlineHeight = 10,
					outline = true,
					outlineColor = Spring.Utilities.CopyTable(OUTLINE_COLOR),
					autoOutlineColor = false,
				}
			},
			loadScroll,
		}
	}
end

local function InitializeControls()
	Chili = WG.Chili
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	ScrollPanel = Chili.ScrollPanel
	Label = Chili.Label
	Button = Chili.Button
	
	-- window to hold things
	window = Panel:New {
		name = 'chobby_loadgame_window',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		backgroundColor = {0, 0, 0, 0}
	}
	InitializeLoadWindow()
end

--------------------------------------------------------------------------------
-- callins
--------------------------------------------------------------------------------
-- called when returning to menu from a game
function widget:ActivateMenu()
	Spring.Log(widget:GetInfo().name, LOG.INFO, "ActivateMenu called", runningMission)
	ingame = false
end

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	InitializeControls()
	
	WG.LoadWindow = {
		GetWindow = function()
			return OpenLoadMenu(false)
		end,
	}
	
	local function OnBattleAboutToStart()
		ingame = true
	end
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
end

function widget:Shutdown()
	WG.LoadWindow = nil
end