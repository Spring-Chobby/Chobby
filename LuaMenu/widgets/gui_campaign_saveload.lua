--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Save/Load",
		desc      = "Create and manage campaign saves",
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
local SAVE_DIR = "Saves/campaign"
local SAVE_DIR_LENGTH = string.len(SAVE_DIR) + 2
local AUTOSAVE_DIR = SAVE_DIR .. "/auto"

local Configuration

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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetSaveDescText(saveFile)
	if not saveFile then return "" end
	return (saveFile.description or "no description")
		.. "\n" .. saveFile.chapterTitle
end

local function SaveGame(filename)
	local result = WG.CampaignData.SaveGame(filename)
	if result then
		WG.CampaignSaveWindow.PopulateSaveList()
	end
end

local function LoadGame(filename)
	WG.CampaignData.LoadGameByFilename(filename)
	WG.CampaignSaveWindow.PopulateSaveList()
end

local function DeleteSave(filename)
	WG.CampaignData.DeleteSave(filename)
	WG.CampaignSaveWindow.PopulateSaveList()
end

local function PromptNewSave()
	local newSaveWindow = Window:New {
		x = 700,
		y = 300,
		width = 316,
		height = 240,
		caption = "",
		resizable = false,
		draggable = false,
		parent = WG.Chobby.lobbyInterfaceHolder,
		classname = "main_window",
		OnDispose = {
			function()
				lobby:RemoveListener("OnJoinBattleFailed", onJoinBattleFailed)
				lobby:RemoveListener("OnJoinBattle", onJoinBattle)
			end
		},
	}

	local lblSaveName = Label:New {
		x = 25,
		right = 15,
		y = 15,
		height = 35,
		font = Configuration:GetFont(3),
		caption = i18n("save_name"),
		parent = newSaveWindow,
	}

	local ebSaveName = EditBox:New {
		x = 30,
		right = 30,
		y = 60,
		height = 35,
		text = "",
		hint = i18n("save_name"),
		fontsize = Configuration:GetFont(3).size,
		parent = newSaveWindow,
	}

	local function NewSave()
		if ebSaveName.text and ebSaveName.text ~= "" then
			WG.Chobby.Configuration:SetConfigValue("campaignSaveFile", ebSaveName.text)
			WG.CampaignData.StartNewGame()
			newSaveWindow:Dispose()
			WG.CampaignSaveWindow.PopulateSaveList()
		end
	end

	local function CancelFunc()
		newSaveWindow:Dispose()
	end

	local btnJoin = Button:New {
		x = 5,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("new_game"),
		font = Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function()
				NewSave()
			end
		},
		parent = newSaveWindow,
	}
	local btnClose = Button:New {
		right = 5,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("cancel"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
		parent = newSaveWindow,
	}

	local popupHolder = WG.Chobby.PriorityPopup(newSaveWindow, CancelFunc, NewSave)
	screen0:FocusControl(ebPassword)
end

--------------------------------------------------------------------------------
-- Save/Load UI
--------------------------------------------------------------------------------

-- Makes a button for a save game on the save/load screen
local function AddSaveEntryButton(saveFile, saveList)
	local current = saveFile.name == WG.Chobby.Configuration.campaignSaveFile

	local container = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	if not current then
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
					LoadGame(saveFile.name)
				end
			},
			parent = container,
		}
	end

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
		text = saveFile.name .. (current and " \255\0\255\255\(current)\008" or ""),
		parent = container,
	}
	x = x + 200

	-- save's campaign name
	--local campaignNameStr = WG.CampaignData.GetCampaignTitle(saveFile.campaignID) or saveFile.campaignID
	--local campaignName = TextBox:New {
	--	name = "gameName",
	--	x = x,
	--	y = 12,
	--	right = 0,
	--	height = 20,
	--	valign = 'center',
	--	fontsize = Configuration:GetFont(2).size,
	--	text = campaignNameStr,
	--	parent = container,
	--}
	--x = x + 220

	-- save date
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
	x = x + 140

	-- save details
	--local details = TextBox:New {
	--	name = "saveDetails",
	--	x = x,
	--	y = 12,
	--	right = 0,
	--	height = 20,
	--	valign = 'center',
	--	fontsize = Configuration:GetFont(2).size,
	--	text = GetSaveDescText(saveFile),
	--	parent = container,
	--}
	--x = x + 200

	-- delete button
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

	return container, {saveFile.name, DateToString(saveFile.date)}
end

local function UpdateSaveList(saveList)
	saveList:Clear()
	local saves = WG.CampaignData.GetSaves()
	local items = {}
	for name, save in pairs(saves) do
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

	-------------------------
	-- Generate List
	-------------------------
	local listHolder = Control:New {
		x = 12,
		right = 15,
		y = 80,
		bottom = 15,
		parent = parent,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}

	local headings = {
		{name = "Name", x = 97, width = 200},
		--{name = "Campaign", x = 97 + 200, width = 220},
		{name = "Date", x = 97 + --[[200 +]] 220, width = 140},
	}

	local saveList = WG.Chobby.SortableList(listHolder, headings, 80, 2)
	UpdateSaveList(saveList)

	local saveButton = Button:New {
		width = 180,
		x = 12,
		y = 8,
		height = 64,
		caption = i18n("new_campaign"),
		OnClick = {
			function ()
				PromptNewSave()
			end
		},
		font = Configuration:GetFont(3),
		parent = parent,
	}

	local externalFunctions = {}

	function externalFunctions.PopulateSaveList()
		UpdateSaveList(saveList)
	end

	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CampaignSaveWindow = {}

function CampaignSaveWindow.GetControl()
	local controlFuncs

	local window = Control:New {
		name = "campaignSaveHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					controlFuncs = InitializeControls(obj, saveMode)
					CampaignSaveWindow.PopulateSaveList = controlFuncs.PopulateSaveList	-- hax
				end
			end
		},
	}

	return window
end

--------------------------------------------------------------------------------
-- callins
--------------------------------------------------------------------------------

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.CampaignSaveWindow = CampaignSaveWindow
end

function widget:Shutdown()
	WG.CampaignSaveWindow = nil
end
