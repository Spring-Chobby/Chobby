--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Handler ZK",
		desc      = "Tells epic sagas of good versus evil",
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

--------------------------------------------------------------------------------
-- Chili elements
--------------------------------------------------------------------------------
local Chili
local Window
local Panel
local StackPanel
local ScrollPanel
local Label
local Button

local window
local screens = {}	-- main, newGame, save, load, intermission, codex
local currentScreenID = "main"
local lastScreenID = "main"

local startButton
local newGameCampaignScroll
local newGameCampaignButtons = {}
local newGameCampaignDetails = {}	-- panel, stackPanel, titleLabel, authorLabel, descTextBox
local saveScroll, loadScroll, saveDescEdit
local saveLoadControls = {}	-- {id, container, titleLabel, descTextBox, image (someday), isNew}

local CAMPAIGN_SELECTOR_BUTTON_HEIGHT = 96
local SAVEGAME_BUTTON_HEIGHT = 128
local SAVE_DIR = "saves/"
local MAX_SAVES = 999
--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------
local gamedata = {
	chapterTitle = ""
}

local campaignDefs = {}	-- {name, author, image, definition, starting function call}
local campaignDefsByID = {}
local currentCampaignID = nil

local saves = {}
local savesOrdered = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function ResetGamedata()
	gamedata.campaignID = nil
	gamedata.vnStory = nil
	gamedata.mapAvailable = false
	gamedata.nextMissionScript = nil
	gamedata.chapterTitle = ""
	gamedata.unlockedScenes = {}
	gamedata.campaignID = nil
	gamedata.vars = {}
	
	SetControlGreyout(startButton, true)
end

local function LoadCampaignDefs()
	local success, err = pcall(function()
		local subdirs = VFS.SubDirs(CAMPAIGN_DIR)
		for i,subdir in pairs(subdirs) do
			if VFS.FileExists(subdir .. "campaigninfo.lua") then
				local def = VFS.Include(subdir .. "campaigninfo.lua")
				def.dir = subdir
				campaignDefs[#campaignDefs+1] = def
				campaignDefsByID[def.id] = def
			end
		end
		table.sort(campaignDefs, function(a, b) return (a.order or 100) < (b.order or 100) end) 
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading campaign defs: " .. err)
	end
end

local function SetNextMissionScript(script)
	gamedata.nextMissionScript = script
end

local function SetVNStory(story, dir)
	if (not story) or story == "" then
		return
	end
	gamedata.vnStory = story
	WG.VisualNovel.LoadStory(story, dir)
end

local function SetChapterTitle(title)
	gamedata.chapterTitle = title
end

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

local function GetSaves()
	Spring.CreateDir(SAVE_DIR)
	saves = {}
	savesOrdered = {}
	local savefiles = VFS.DirList(SAVE_DIR, "save*.lua")
	for i=1,#savefiles do
		local savefile = savefiles[i]
		local success, err = pcall(function()
			local saveData = VFS.Include(savefile)
			local campaignDef = campaignDefsByID[saveData.campaignID]
			--if (campaignDef) then
				saveData.id = saveData.id or i
				saves[saveData.id] = saveData
				savesOrdered[#savesOrdered + 1] = saveData
			--end
		end)
		if (not success) then
			Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error getting saves: " .. err)
		end
	end
	--table.sort(savesOrdered, SortSavesByDate)
end

local function FindFirstEmptySaveSlot()
	for i=#saves,MAX_SAVES do
		if saves[i] == nil then
			return i
		end
	end
	return MAX_SAVES
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function HideScreens(noHide)
	for windowID, control in pairs(screens) do
		if (windowID ~= noHide) and (control.visible) then
			control:Hide()
		end
	end
end

local function ShowScreen(screenID)
	if not screens[screenID].visible then
		screens[screenID]:Show()
	end
end

local function SwitchToScreen(screenID)
	lastScreenID = currentScreenID
	currentScreenID = screenID
	HideScreens(screenID)
	ShowScreen(screenID)
end

local function EnableStartButton()
	if not currentCampaignID then
		return
	end
	SetControlGreyout(startButton, false)
end

--[[
local function SetSaveLoadButtonStates()
	local canSave, canLoad = false, false
	if currentSaveID then
		if saves[currentSaveID] then
			canLoad = true
		end
		if saveEnabled then
			canSave = true
		end
	end
	SetControlGreyout(saveButton, not canSave)
	SetControlGreyout(loadButton, not canLoad)
end
]]

local function UpdateCampaignDetailsPanel(campaignID)
	local def = campaignDefsByID[campaignID]
	if not def then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "could not find campaign with def " .. campaignID)
		return
	end
	newGameCampaignDetails.titleLabel:SetCaption(def.name)
	newGameCampaignDetails.authorLabel:SetCaption("by " .. def.author)
	-- make sure text box is right width
	newGameCampaignDetails.descTextBox.width = newGameCampaignDetails.stackPanel.width - newGameCampaignDetails.stackPanel.padding[1] - newGameCampaignDetails.stackPanel.padding[3]
	newGameCampaignDetails.descTextBox:SetText(def.description)
	--newGameCampaignDetails.descTextBox:Invalidate()
	EnableStartButton()
end

local function SelectCampaign(campaignID)
	local def = campaignDefsByID[campaignID]
	currentCampaignID = def.id
	for id,button in pairs(newGameCampaignButtons) do
		if id == campaignID then
			button.backgroundColor = {1,1,1,1}
		else
			button.backgroundColor = {0.4,0.4,0.4,1}
		end
		button:Invalidate()
	end
	UpdateCampaignDetailsPanel(campaignID)
end


local function SaveGame(id)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		id = id or FindFirstEmptySaveSlot()
		path = SAVE_DIR .. "save" .. string.format("%03d", id) .. ".lua"
		local saveData = Spring.Utilities.CopyTable(gamedata, true)
		saveData.date = os.date('*t')
		saveData.id = id
		saveData.description = saveDescEdit.text
		saveData.campaignID = currentCampaignID
		table.save(saveData, path)
		--Spring.Log(widget:GetInfo().name, LOG.INFO, "Saved game to " .. path)
		Spring.Echo(widget:GetInfo().name .. ": Saved game to " .. path)
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error saving game: " .. err)
	end
end

local function LoadGame(saveData)
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		currentCampaignID = saveData.campaignID
		gamedata = Spring.Utilities.CopyTable(saveData)
		gamedata.id = nil
		if saveData.description then
			saveDescEdit:SetText(saveData.description)
		end
		SetVNStory(gamedata.vnStory)
		--Spring.Log(widget:GetInfo().name, LOG.INFO, "Save file " .. path .. " loaded")
		SwitchToScreen("intermission")
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading game: " .. err)
	end
end

local function LoadGameByID(id)
	LoadGame(saves[id])
end
-- don't really need this
--[[
local function LoadGameFromFile(path)
	if VFS.FileExists(path) then
		local saveData = VFS.Include(path)
		LoadGame(saveData)
		Spring.Echo(widget:GetInfo().name .. ": Save file " .. path .. " loaded")
	else
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Save file " .. path .. " does not exist")
	end
end
]]

local function DeleteSave(id)
	local success, err = pcall(function()
		local path = SAVE_DIR .. "save" .. string.format("%03d", id) .. ".lua"
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
	if not currentCampaignID then
		return
	end
	local def = campaignDefsByID[currentCampaignID]
			
	ChiliFX:AddFadeEffect({
		obj = screens.newGame, 
		time = 0.15,
		endValue = 0,
		startValue = 1,
		after = function()
			if def.startFunction then
				def.startFunction()
			end
			SwitchToScreen("intermission")
		end
	})
end

local function UnlockScene(id)
	gamedata.unlockedScenes[id] = true
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function AddCampaignSelectorButtons()
	for i=1,#campaignDefs do
		local def = campaignDefs[i]
		newGameCampaignButtons[def.id] = Button:New {
			parent = newGameCampaignScroll,
			width = "100%",
			height = CAMPAIGN_SELECTOR_BUTTON_HEIGHT,
			x = 0,
			y = (CAMPAIGN_SELECTOR_BUTTON_HEIGHT + 4) * (i-1),
			caption = "",
			--padding = {0, 0, 0, 0},
			children = {
				Image:New {
					file = def.dir .. "image.png",
					y = 0,
					right = 16,
					width = CAMPAIGN_SELECTOR_BUTTON_HEIGHT * 160/128,
					height = "100%",
					keepAspect = true,
					padding = {0, 0, 0, 0},
				},
				Label:New {
					caption = def.name,
					--height = "100%",
					valign = "center",
					x = 8,
					y = 8,
					font = { size = 32 },
				}
			},
			backgroundColor = {0.4,0.4,0.4,1},
			OnClick = { function(self)
					SelectCampaign(def.id)
				end
			}
		}
	end
end

local function SaveLoadConfirmationDialogPopup(saveID, saveMode)
	local text = saveMode and i18n("save_overwrite_confirm") or i18n("load_confirm")
	local yesFunc = function()
			if (saveMode) then
				SaveGame(saveID)
				SwitchToScreen("intermission")
			else
				LoadGameByID(saveID)
			end
		end
	WG.Chobby.ConfirmationPopup(yesFunc, text, nil, 315, 200)
end

local function RemoveSaveEntryButtons()
	for i=1,#saveLoadControls do
		saveLoadControls[i].container:Dispose()
	end
	saveLoadControls = {}
end

local function AddSaveEntryButton(saveFile, allowSave, count)
	local id = saveFile and saveFile.id or #savesOrdered + 1
	local controlsEntry = {id = id}
	saveLoadControls[#saveLoadControls + 1] = controlsEntry
	local parent = allowSave and saveScroll or loadScroll
	
	controlsEntry.container = Panel:New {
		parent = parent,
		height = SAVEGAME_BUTTON_HEIGHT,
		width = "100%",
		x = 0,
		y = (SAVEGAME_BUTTON_HEIGHT) * count,
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
				if allowSave then
					if saveFile then
						SaveLoadConfirmationDialogPopup(id, true)
					else
						SaveGame()
						SwitchToScreen("intermission")
					end
				else
					if lastScreenID == "main" then
						LoadGameByID(id)
					else
						SaveLoadConfirmationDialogPopup(id, false)
					end
				end
			end
		}
	}
	controlsEntry.titleLabel = Label:New {
		parent = controlsEntry.button,
		caption = saveFile and i18n("save") .. " " .. saveFile.id or i18n("save_new_game"),
		valign = "center",
		x = 8,
		y = 8,
		font = { size = 20 },
	}
	if saveFile then
		controlsEntry.descTextbox = TextBox:New {
			parent = controlsEntry.button,
			x = 8,
			y = 40,
			right = 8,
			bottom = 8,
			text = (saveFile.description or "no description") .. "\n" .. saveFile.chapterTitle
				.. "\n" .. (campaignDefsByID[saveFile.campaignID] and campaignDefsByID[saveFile.campaignID].name or saveFile.campaignID),
			font = { size = 16 },
		}
		controlsEntry.dateLabel = Label:New {
			parent = controlsEntry.button,
			caption = WriteDate(saveFile.date),
			right = 8,
			y = 8,
			font = { size = 18 },
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
					WG.Chobby.ConfirmationPopup(function(self) DeleteSave(id) end, i18n("delete_confirm"), nil, 315, 200)
				end
			}
		}
	end

end

local function AddSaveEntryButtons(allowSave)
	local startIndex = #savesOrdered
	local count = 0
	if (allowSave and #savesOrdered < 999) then
		-- add new game panel
		AddSaveEntryButton(nil, true, count)
		count = 1
	end
	
	for i=startIndex,1,-1 do
		AddSaveEntryButton(savesOrdered[i], allowSave, count)
		count = count + 1;
	end
end

local function OpenSaveOrLoadMenu(save)
	currentSaveID = nil
	GetSaves()
	RemoveSaveEntryButtons()
	AddSaveEntryButtons(save)
	if (save) then
		SwitchToScreen("save")
	else
		SwitchToScreen("load")
	end
end

local function InitializeMainControls()
	-- main menu
	screens.main = Panel:New {
		parent = window,
		name = 'chobby_campaign_main',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_campaign_mainTitle',
				caption = i18n("campaign_caps"),
				align = "center",
				y = 24,
				x = "30%",
				font = {
					size = 48,
					outlineWidth = 12,
					outlineHeight = 12,
					outline = true,
					outlineColor = {0.54,0.72,1,0.3},
					autoOutlineColor = false,
				}
			},
			StackPanel:New{
				name = 'chobby_campaign_mainStack',
				orientation = "vertical",
				x = 0,
				y = "20%",
				width = "100%",
				height = "80%",
				resizeItems = false,
				children = {
					Button:New {
						name = 'chobby_campaign_mainLoad',
						width = 128,
						height = 48,
						caption = i18n("load_game"),
						OnClick = {function() OpenSaveOrLoadMenu(false) end}
					},
					Button:New {
						name = 'chobby_campaign_mainNew',
						width = 128,
						height = 48,
						caption = i18n("new_game"),
						OnClick = {function() SwitchToScreen("newGame") end}
					},
				}
			}
		}
	}
end

local function InitializeNewGameControls()
	-- New Game screen
	startButton = Button:New {
		name = 'chobby_campaign_newGameStart',
		width = 60,
		height = 36,
		y = 4,
		right = 4,
		caption = i18n("start_verb"),
		OnClick = { function(self)
			StartNewGame()
		end}
	}
	newGameCampaignScroll = ScrollPanel:New {
		name = 'chobby_campaign_newGameScroll',
		orientation = "vertical",
		x = 0,
		y = "15%",
		width = "100%",
		height = "45%",
		children = {}
	}
	newGameCampaignDetails.panel = Panel:New {
		name = 'chobby_campaign_newGameDetails',
		x = 0,
		y = "60%",
		width = "100%",
		height = "40%",
	}
	newGameCampaignDetails.stackPanel = StackPanel:New {
		parent = newGameCampaignDetails.panel,
		orientation = "vertical",
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizeItems = false,
		--autoArrangeV = true,
		centerItems = false,
		itemMargin = {5, 5, 5, 5},
	}
	newGameCampaignDetails.titleLabel = Label:New {
		parent = newGameCampaignDetails.stackPanel,
		caption = "",
		font = { size = 36 },
	}
	newGameCampaignDetails.authorLabel = Label:New {
		parent = newGameCampaignDetails.stackPanel,
		caption = "",
		font = { size = 20 },
	}
	newGameCampaignDetails.descTextBox = TextBox:New {
		parent = newGameCampaignDetails.stackPanel,
		text = "",
		font = { size = 16 },
	}
	
	screens.newGame = Panel:New {
		parent = window,
		name = 'chobby_campaign_newGame',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_campaign_newGameTitle',
				caption = i18n("new_game_caps"),
				x = 4,
				y = 24,
				font = {
					size = 40,
					outlineWidth = 10,
					outlineHeight = 10,
					outline = true,
					outlineColor = {0.54,0.72,1,0.3},
					autoOutlineColor = false,
				}
			},
			startButton,
			Button:New {
				name = 'chobby_campaign_newGameBack',
				width = 60,
				height = 36,
				y = 4,
				right = 4 + 60 + 4,
				caption = "Back",
				OnClick = {function() SwitchToScreen("main") end}
			},
			newGameCampaignScroll,
			newGameCampaignDetails.panel,
		}
	}
end

local function InitializeIntermissionControls()
	--intermission screen
	screens.intermission = Panel:New {
		parent = window,
		name = 'chobby_campaign_intermission',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_campaign_intermissionTitle',
				caption = i18n("intermission_caps"),
				y = 24,
				x = 8,
				font = {
					size = 36,
					outlineWidth = 12,
					outlineHeight = 12,
					outline = true,
					outlineColor = {0.54,0.72,1,0.3},
					autoOutlineColor = false,
				}
			},
			StackPanel:New{
				name = 'chobby_campaign_intermissionStack',
				orientation = "vertical",
				x = 0,
				y = "20%",
				width = "100%",
				height = "80%",
				resizeItems = false,
				--autoArrangeV = true,
				centerItems = false,
				children = {
					-- TODO functions
					Button:New {
						name = 'chobby_campaign_intermissionNext',
						width = 128,
						height = 48,
						caption = i18n("next_episode"),
						OnClick = { function()
							if gamedata.nextMissionScript then
								WG.VisualNovel.Cleanup()
								WG.VisualNovel.StartScript(gamedata.nextMissionScript)
							end
						end}
					},
					Button:New {
						name = 'chobby_campaign_intermissionSave',
						width = 128,
						height = 48,
						caption = i18n("save"),
						OnClick = { function()
							OpenSaveOrLoadMenu(true)
						end}
					},
					Button:New {
						name = 'chobby_campaign_intermissionLoad',
						width = 128,
						height = 48,
						caption = i18n("load"),
						OnClick = { function()
							OpenSaveOrLoadMenu(false)
						end}
					},
					Button:New {
						name = 'chobby_campaign_intermissionQuit',
						width = 128,
						height = 48,
						caption = i18n("quit"),
						OnClick = { function(self)
							ChiliFX:AddFadeEffect({
								obj = screens.intermission, 
								time = 0.15,
								endValue = 0,
								startValue = 1,
								after = function()
									SwitchToScreen("main")
									ResetGamedata()
								end
							})
						end }
					},
				}
			}
		}
	}
end

local function InitializeSaveLoadWindow()
	saveScroll = ScrollPanel:New {
		name = 'chobby_campaign_saveScroll',
		orientation = "vertical",
		x = 0,
		y = 84,
		width = "100%",
		bottom = 8,
		children = {}
	}
	saveDescEdit = Chili.EditBox:New {
		name = 'chobby_campaign_saveDesc',
		x = 0,
		y = 56,
		height = 20,
		width = "50%",
		text = "Save description",
		font = { size = 16 },
	}
	
	screens.save = Panel:New {
		parent = window,
		name = 'chobby_campaign_save',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_campaign_saveTitle',
				caption = i18n("save_caps"),
				x = 4,
				y = 8,
				font = {
					size = 40,
					outlineWidth = 10,
					outlineHeight = 10,
					outline = true,
					outlineColor = {0.54,0.72,1,0.3},
					autoOutlineColor = false,
				}
			},
			Button:New {
				name = 'chobby_campaign_saveBack',
				width = 60,
				height = 36,
				y = 4,
				right = 4,
				caption = "Back",
				OnClick = {function() SwitchToScreen(lastScreenID) end}
			},
			saveDescEdit,
			saveScroll,
		}
	}
	
	loadScroll = ScrollPanel:New {
		name = 'chobby_campaign_loadScroll',
		orientation = "vertical",
		x = 0,
		y = 56,
		width = "100%",
		bottom = 8,
		children = {}
	}
	
	screens.load = Panel:New {
		parent = window,
		name = 'chobby_campaign_load',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		backgroundColor = {0, 0, 0, 0},
		children = {
			Label:New {
				name = 'chobby_campaign_loadTitle',
				caption = i18n("load_caps"),
				x = 4,
				y = 8,
				font = {
					size = 40,
					outlineWidth = 10,
					outlineHeight = 10,
					outline = true,
					outlineColor = {0.54,0.72,1,0.3},
					autoOutlineColor = false,
				}
			},
			Button:New {
				name = 'chobby_campaign_loadBack',
				width = 60,
				height = 36,
				y = 4,
				right = 4,
				caption = "Back",
				OnClick = {function() SwitchToScreen(lastScreenID) end}
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
	window = Window:New {
		name = 'chobby_campaign_window',
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		draggable = false,
		--padding = {0, 0, 0, 0},
	}
	
	InitializeMainControls()
	InitializeNewGameControls()	
	InitializeIntermissionControls()
	InitializeSaveLoadWindow()
	SwitchToScreen("main")
end

--------------------------------------------------------------------------------
-- callins
--------------------------------------------------------------------------------
function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	InitializeControls()
	
	WG.CampaignHandler = {
		GetWindow = function() return window end,
		SetVNStory = SetVNStory,
		SetNextMissionScript = SetNextMissionScript,
		UnlockScene = UnlockScene,
		SetChapterTitle = SetChapterTitle,
	}
	
	ResetGamedata()
	LoadCampaignDefs()
	AddCampaignSelectorButtons()
end

function widget:Shutdown()
	WG.CampaignHandler = nil
end