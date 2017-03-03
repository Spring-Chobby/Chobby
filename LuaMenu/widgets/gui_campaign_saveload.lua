--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Save/Load Old",
		desc      = "see title",
		author    = "KingRaptor",
		date      = "2016.11.24",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = false  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local SAVEGAME_BUTTON_HEIGHT = 128
local OUTLINE_COLOR = {0.54,0.72,1,0.3}
local SAVE_DIR = "Saves/campaign"
local SAVE_DIR_LENGTH = string.len(SAVE_DIR) + 2
local AUTOSAVE_DIR = SAVE_DIR .. "/auto"

local Configuration
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

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------
local ingame = false

--------------------------------------------------------------------------------
-- General utility functions
--------------------------------------------------------------------------------
local function WriteDate(dateTable)
	return string.format("%02d/%02d/%04d", dateTable.day, dateTable.month, dateTable.year)
	.. "\n" .. string.format("%02d:%02d:%02d", dateTable.hour, dateTable.min, dateTable.sec)
end

local function DateToString(dateTable)
	return string.format("%04d%02d%02d", dateTable.year, dateTable.month, dateTable.day)
	.. " " .. string.format("%02d%02d%02d", dateTable.hour, dateTable.min, dateTable.sec)
end

local function SecondsToClock(seconds)
	local seconds = tonumber(seconds)

	if seconds <= 0 then
		return "00:00";
	else
		hours = string.format("%02d", math.floor(seconds/3600));
		mins = string.format("%02d", math.floor(seconds/60 - (hours*60)));
		secs = string.format("%02d", math.floor(seconds - hours*3600 - mins *60));
		if seconds >= 3600 then
			return hours..":"..mins..":"..secs
		else
			return mins..":"..secs
		end
	end
end

local function trim(str)
  return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetSaveDescText(saveFile)
	if not saveFile then return "" end
	return (saveFile.description or "no description")
		.. "\n" .. saveFile.chapterTitle
end

local function SaveGame(filename, description, isAutoSave)
	local result = WG.CampaignAPI.SaveGame(filename, description, isAutoSave)
	if result then
		WG.CampaignSaveLoadWindow.PopulateSaveList()
	end
end

local function LoadGame(filename)
	WG.CampaignAPI.LoadGameByFilename(filename)
end

local function DeleteSave(filename, saveList)
	local success, err = pcall(function()
		local pathNoExtension = SAVE_DIR .. "/" .. filename
		os.remove(pathNoExtension .. ".lua")
		
		saveList:RemoveItem(filename)
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error deleting save " .. filename .. ": " .. err)
	end
end

--------------------------------------------------------------------------------
-- Save/Load UI
--------------------------------------------------------------------------------
local function SaveLoadConfirmationDialogPopup(filename, description, saveMode)
	local text = saveMode and i18n("save_overwrite_confirm") or i18n("load_confirm")
	local yesFunc = function()
			if saveMode then
				SaveGame(filename, description, false)
			else
				LoadGame(filename)
			end
		end
	WG.Chobby.ConfirmationPopup(yesFunc, text, nil, 360, 200)
end

local function PromptSave(filename, description)
	if not filename then
		-- throw error message?
	end
	filename = trim(filename)
	local saveExists = filename and VFS.FileExists(SAVE_DIR .. "/" .. filename .. ".lua") or false
	if saveExists then
		SaveLoadConfirmationDialogPopup(filename, description, true)
	else
		SaveGame(filename, description, false)
	end
end

-- Makes a button for a save game on the save/load screen
local function AddSaveEntryButton(saveFile, saveList)	
	local container = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	-- load button
	local loadButton = Button:New {
		x = 3,
		y = 3,
		bottom = 3,
		width = 80,
		caption = i18n("load"),
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				if true then	-- FIXME check if currently in a campaign game
					SaveLoadConfirmationDialogPopup(saveFile.name, false)
				else
					LoadGameByFilename(saveFile.name)
				end
			end
		},
		parent = container,
	}
	
	-- save name
	local x = 95
	local saveName = TextBox:New {
		name = "saveName",
		x = x,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = saveFile.name,
		parent = container,
	}
	
	-- save's campaign name
	x = x + 200
	local campaignNameStr = WG.CampaignAPI.GetCampaignTitle(saveFile.campaignID) or saveFile.campaignID
	local campaignName = TextBox:New {
		name = "gameName",
		x = x,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = campaignNameStr,
		parent = container,
	}
	
	-- save date
	x = x + 220
	local saveDate = TextBox:New {
		name = "saveDate",
		x = x,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = WriteDate(saveFile.date),
		parent = container,
	}
	
	-- save details
	x = x + 140
	local details = TextBox:New {
		name = "saveDetails",
		x = x,
		y = 12,
		right = 0,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(2).size,
		text = GetSaveDescText(saveFile),
		parent = container,
	}
	
	-- delete button
	x = x + 200
	local deleteButton = Button:New {
		parent = container,
		x = x,
		width = 65,
		y = 4,
		bottom = 4,
		caption = i18n("delete"),
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(2),
		OnClick = { function(self)
				WG.Chobby.ConfirmationPopup(function(self) DeleteSave(saveFile.name, saveList) end, i18n("delete_confirm"), nil, 360, 200)
			end
		}
	}
	
	return container, {saveFile.name, campaignNameStr, DateToString(saveFile.date)}
end

local function PopulateSaveList(saveList)
	saveList:Clear()
	local saves = WG.CampaignAPI.GetSaves()
	local items = {}
	for filepath, save in pairs(saves) do
		local controls, order = AddSaveEntryButton(save, saveList)
		items[#items + 1] = {save.name, controls, order}
	end
		
	saveList:AddItems(items)
end
--------------------------------------------------------------------------------
-- Make Chili controls
--------------------------------------------------------------------------------

local function InitializeControls(parent, saveMode)
	Configuration = WG.Chobby.Configuration
	
	Label:New {
		x = 15,
		y = 11,
		width = 180,
		height = 30,
		parent = parent,
		font = Configuration:GetFont(3),
		caption = string.upper(saveMode and i18n("save") or i18n("load")),
	}
	
	-------------------------
	-- Generate List
	-------------------------
	
	local listHolder = Control:New {
		x = 12,
		right = 15,
		y = saveMode and 110 or 80,
		bottom = 15,
		parent = parent,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local headings = {
		{name = "Name", x = 97, width = 200},
		{name = "Campaign", x = 97 + 200, width = 220},
		{name = "Date", x = 97 + 200 + 220, width = 140},
	}

	local saveList = WG.Chobby.SortableList(listHolder, headings, 80, 3)
	PopulateSaveList(saveList)
	
	if saveMode then
		local saveFilenameEdit = EditBox:New {
			x = 12,
			right = 96,
			y = 51,
			height = 28,
			hint = "Save Filename",
			font = Configuration:GetFont(2),
			parent = parent,
		}
		
		local saveDescEdit = EditBox:New {
			x = 12,
			right = 96,
			y = 81,
			height = 28,
			hint = "Save Description",
			font = Configuration:GetFont(2),
			parent = parent,
		}
	
		local saveButton = Button:New {
			width = 80,
			right = 12,
			y = 51,
			height = 64,
			caption = i18n("save") or "Save",
			OnClick = {
				function ()
					if saveFilenameEdit.text and string.len(saveFilenameEdit.text) ~= 0 then
						PromptSave(saveFilenameEdit.text, saveDescEdit.text)
					end
				end
			},
			font = Configuration:GetFont(3),
			parent = parent,
		}
	end
	
	local externalFunctions = {}
	
	function externalFunctions.PopulateSaveList()
		PopulateSaveList(saveList)
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CampaignSaveLoadWindow = {}

function CampaignSaveLoadWindow.GetControl(saveMode)
	local controlFuncs
	
	local window = Control:New {
		name = saveMode and "campaignSaveHandler" or "campaignLoadHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					controlFuncs = InitializeControls(obj, saveMode)
					CampaignSaveLoadWindow.PopulateSaveList = controlFuncs.PopulateSaveList	-- hax
				else
					-- update save list
					controlFuncs.PopulateSaveList()
				end
			end
		},
	}
	
	return window
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
	
	Chili = WG.Chili
	Window = Chili.Window
	Panel = Chili.Panel
	StackPanel = Chili.StackPanel
	ScrollPanel = Chili.ScrollPanel
	Label = Chili.Label
	Button = Chili.Button
	
	WG.CampaignSaveLoadWindow = CampaignSaveLoadWindow
	
	local function OnBattleAboutToStart()
		ingame = true
	end
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
end

function widget:Shutdown()
	WG.CampaignSaveLoadWindow = nil
end