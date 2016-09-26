--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Settings Window",
		desc      = "Handles settings.",
		author    = "GoogleFrog",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local fullscreen = 0

local battleStartDisplay = 1
local lobbyFullscreen = 1

local FUDGE = 0

local currentMode = false

local ITEM_OFFSET = 38

local COMBO_X = 230
local COMBO_WIDTH = 235
local CHECK_WIDTH = 230
local TEXT_OFFSET = 6

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local configParamTypes = {}
for _, param in pairs(Spring.GetConfigParams()) do
	configParamTypes[param.name] = param.type
end

local function SetSpringsettingsValue(key, value)
	local configType = configParamTypes[key]
	if configType == "int" then
		Spring.SetConfigInt(key, value)
	elseif configType == "bool" or configType == "float" then
		Spring.SetConfigString(key, value)
	elseif configType == nil then
		Spring.Log("Settings", LOG.WARNING, "No such key: " .. tostring(key) .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	else
		Spring.Log("Settings", LOG.WARNING, "Unexpected key type: " .. configType .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	end
end

local function SetLobbyFullscreenMode(mode)
	if mode == currentMode then
		return
	end
	currentMode = mode

	local screenX, screenY = Spring.GetScreenGeometry()
	if mode == 1 then
		Spring.SetConfigInt("Fullscreen", 1) -- Required to remove FUDGE
		Spring.SetConfigInt("XResolutionWindowed", screenX - FUDGE*2, false)
		Spring.SetConfigInt("YResolutionWindowed", screenY - FUDGE*2, false)
		Spring.SetConfigInt("WindowPosX", FUDGE, false)
		Spring.SetConfigInt("WindowPosY", FUDGE, false)
		Spring.SetConfigInt("WindowBorderless", 1)
		Spring.SetConfigInt("Fullscreen", 0)
	elseif mode == 2 then
		local winSizeX, winSizeY, winPosX, winPosY = Spring.GetWindowGeometry()
		winPosY = screenY - winPosY - winSizeY
		if winPosY > 10 then
			-- Window is not stuck at the top of the screen
			Spring.SetConfigInt("WindowPosX", math.min(winPosX, screenX - 50), false)
			Spring.SetConfigInt("WindowPosY", math.min(winPosY, screenY - 50), false)
			Spring.SetConfigInt("XResolutionWindowed",  math.min(winSizeX, screenX), false)
			Spring.SetConfigInt("YResolutionWindowed",  math.min(winSizeY, screenY - 50), false)
		else
			-- Reset window to screen centre
			Spring.SetConfigInt("WindowPosX", screenX/4, false)
			Spring.SetConfigInt("WindowPosY", screenY/8, false)
			Spring.SetConfigInt("XResolutionWindowed", screenX/2, false)
			Spring.SetConfigInt("YResolutionWindowed", screenY*3/4, false)
		end
		Spring.SetConfigInt("WindowBorderless", 0, false)
		Spring.SetConfigInt("Fullscreen", 0)
	elseif mode == 3 then
		Spring.SetConfigInt("XResolution", screenX, false)
		Spring.SetConfigInt("YResolution", screenY, false)
		Spring.SetConfigInt("Fullscreen", 1, false)
		Spring.SetConfigInt("Fullscreen", 1)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Lobby Settings

local function GetLobbyTabControls()
	local freezeSettings = true

	local Configuration = WG.Chobby.Configuration

	local offset = 0
	
	local children = {}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 30,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Display",
	}
	children[#children + 1] = ComboBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.lobby_fullscreen or 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end

				if Spring.GetGameName() == "" then
					SetLobbyFullscreenMode(obj.selected)
				end

				lobbyFullscreen = obj.selected
				Configuration.lobby_fullscreen = obj.selected
			end
		},
	}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Panel mode",
	}
	children[#children + 1] = ComboBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = {"Autodetect", "Always Two", "Always One"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.panel_layout or 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("panel_layout", obj.selected)
			end
		},
	}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Menu Music Volume",
	}
	children[#children + 1] = Trackbar:New {
		x = COMBO_X,
		y = offset,
		width  = COMBO_WIDTH,
		height = 30,
		value  = Configuration.menuMusicVolume or 0.5,
		min    = 0,
		max    = 1,
		step   = 0.02,
		OnChange = {
			function(obj, value)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("menuMusicVolume", value)
			end
		}
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Notification Volume",
	}
	children[#children + 1] = Trackbar:New {
		x = COMBO_X,
		y = offset,
		width  = COMBO_WIDTH,
		height = 30,
		value  = Configuration.menuNotificationVolume or 0.5,
		min    = 0,
		max    = 1,
		step   = 0.02,
		OnChange = {
			function(obj, value)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("menuNotificationVolume", value)
			end
		}
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Chat Font Size",
	}
	children[#children + 1] = Trackbar:New {
		x = COMBO_X,
		y = offset,
		width  = COMBO_WIDTH,
		height = 30,
		value  = Configuration.chatFontSize or 16,
		min    = 12,
		max    = 20,
		step   = 1,
		OnChange = {
			function(obj, value)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("chatFontSize", value)
			end
		}
	}
	
	offset = offset + ITEM_OFFSET
	local autoLogin = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("autoLogin"),
		checked = Configuration.autoLogin or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			freezeSettings = true
			Configuration:SetConfigValue("autoLogin", newState)
			freezeSettings = false
		end},
	}
	children[#children + 1] = autoLogin

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("notifyForAllChat"),
		checked = Configuration.notifyForAllChat or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("notifyForAllChat", newState)
		end},
	}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("only_featured_maps"),
		checked = Configuration.onlyShowFeaturedMaps or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("onlyShowFeaturedMaps", newState)
		end},
	}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("debugMode"),
		checked = Configuration.debugMode or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("debugMode", newState)
		end},
	}

	--offset = offset + ITEM_OFFSET
	--local useSpringRestart = Checkbox:New {
	--	x = 60,
	--	width = CHECK_WIDTH,
	--	y = offset,
	--	height = 40,
	--	parent = window,
	--	boxalign = "right",
	--	boxsize = 20,
	--	caption = "Use Spring.Restart          EXPERIMENTAL",
	--	checked = Configuration.useSpringRestart or false,
	--	font = Configuration:GetFont(2),
	--	OnChange = {function (obj, newState)
	--		Configuration:SetConfigValue("useSpringRestart", newState)
	--	end},
	--}

	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = "Show channel bots",
		checked = Configuration.displayBots or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("displayBots", newState)
		end},
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = "Show wrong engines",
		checked = Configuration.displayBadEngines or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("displayBadEngines", newState)
		end},
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = "Debug for MatchMaker",
		checked = Configuration.showMatchMakerBattles or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("showMatchMakerBattles", newState)
		end},
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Server Address",
	}
	children[#children + 1] = EditBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		text = Configuration.serverAddress,
		font = Configuration:GetFont(2),
		OnFocusUpdate = {
			function (obj)
				if obj.focused then
					return
				end
				
				Configuration.serverAddress = obj.text
				obj:SetText(Configuration.serverAddress)
			end
		}
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Server Port",
	}
	children[#children + 1] = EditBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		text = tostring(Configuration.serverPort),
		font = Configuration:GetFont(2),
		OnFocusUpdate = {
			function (obj)
				if obj.focused then
					return
				end
				
				local newValue = tonumber(obj.text)
				
				if not newValue then
					obj:SetText(tostring(Configuration.serverPort))
					return
				end
				
				Configuration.serverPort = math.floor(0.5 + math.max(0, newValue))
				obj:SetText(tostring(Configuration.serverPort))
			end
		}
	}
	
	offset = offset + ITEM_OFFSET
	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 30,
		valign = "top",
		align = "left",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Singleplayer",
	}
	
	local gameChoices = {"Generic", "Zero-K"}
	for i, archive in pairs(VFS.GetAllArchives()) do
		local info = VFS.GetArchiveInfo(archive)
		if info and info.modtype == 1 and info.name == "Zero-K $VERSION" then
			gameChoices[3] = "Zero-K Dev"
		end
	end
	
	children[#children + 1] = ComboBox:New {
		name = "gameSelection",
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		parent = window,
		items = gameChoices,
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.singleplayer_mode or 2,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("singleplayer_mode", obj.selected)
			end
		},
	}
	
	local function onConfigurationChange(listener, key, value)
		if freezeSettings then
			return
		end
		if key == "autoLogin" then
			autoLogin:SetToggle(value)
		end
	end

	freezeSettings = false
	
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)
	
	return children
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Game Settings

local settingsComboBoxes = {}
local settingsUpdateFunction = {}

local function MakePresetsControl(settingPresets, offset)
	local Configuration = WG.Chobby.Configuration
	
	local presetLabel = Label:New {
		name = "presetLabel",
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Preset:",
	}
    
	local useCustomSettings = true
	local settingsPresetControls = {}

	local function SettingsButton(x, y, caption, settings)
		local button = Button:New {
			name = caption,
			x = 80*x,
			y = ITEM_OFFSET*y,
			width = 75,
			height = 30,
			caption = caption,
			font = Configuration:GetFont(2),
			customSettings = not settings,
			OnClick = {
				function (obj)
					if settings then
						for key, value in pairs(settings) do
							local comboBox = settingsComboBoxes[key]
							if comboBox then
								comboBox:Select(value)
							end
							local updateFunction = settingsUpdateFunction[key]
							if updateFunction then
								updateFunction(value)
							end
						end
					end
					
					ButtonUtilities.SetButtonSelected(obj)
					for i = 1, #settingsPresetControls do
						local control = settingsPresetControls[i]
						if control.name ~= obj.name then
							ButtonUtilities.SetButtonDeselected(control)
						end
					end
				end
			},
		}
    
		settingsPresetControls[#settingsPresetControls + 1] = button
		if settings then
			if Spring.Utilities.TableSubsetEquals(settings, Configuration.settingsMenuValues) then
				useCustomSettings = false
				ButtonUtilities.SetButtonSelected(button)
			end
		elseif useCustomSettings then
			ButtonUtilities.SetButtonSelected(button)
		end
		return button
	end
    
	local x = 0
	local y = 0
	local settingsButtons = {}
	for i = 1, #settingPresets do
		settingsButtons[#settingsButtons + 1] = SettingsButton(x, y, settingPresets[i].name, settingPresets[i].settings)
		x = x + 1
		if x > 2 then
			x = 0
			y = y + 1
		end
	end
	
	local customSettingsButton = SettingsButton(x, y, "Custom")
	settingsButtons[#settingsButtons + 1] = customSettingsButton
	
	local settingsHolder = Control:New {
		name = "settingsHolder",
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = ITEM_OFFSET*(y + 1),
		padding = {0, 0, 0, 0},
		children = settingsButtons
	}
	
	local function EnableCustomSettings()
		ButtonUtilities.SetButtonSelected(customSettingsButton)
		for i = 1, #settingsPresetControls do
			local control = settingsPresetControls[i]
			if not control.customSettings then
				ButtonUtilities.SetButtonDeselected(control)
			end
		end
	end
	
	return presetLabel, settingsHolder, EnableCustomSettings, offset + ITEM_OFFSET*(y + 1)
end

local function ProcessScreenSizeOption(data, offset)
	local Configuration = WG.Chobby.Configuration
	
	local freezeSettings = true
	
	local label = Label:New {
		name = data.name .. "_label",
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 350,
		height = 30,
		valign = "top",
		align = "left",
		caption = data.humanName,
		font = Configuration:GetFont(2),
		tooltip = data.desc,
	}
	local list = ComboBox:New {
		name = data.name .. "_combo",
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.game_fullscreen or 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end

				if Spring.GetGameName() ~= "" then
					SetLobbyFullscreenMode(obj.selected)
				end

				battleStartDisplay = obj.selected
				Configuration.game_fullscreen = obj.selected
			end
		},
	}
	
	freezeSettings = false
	
	return label, list, offset + ITEM_OFFSET
end

local function ProcessSettingsOption(data, offset, defaults, customSettingsSwitch)
	local Configuration = WG.Chobby.Configuration
	
	local label = Label:New {
		name = data.name .. "_label",
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 350,
		height = 30,
		valign = "top",
		align = "left",
		caption = data.humanName,
		font = Configuration:GetFont(2),
		tooltip = data.desc,
	}
	
	local defaultItem = 1
	local defaultName = Configuration.settingsMenuValues[data.name] or defaults[data.name]
	
	local items = {}
	for i = 1, #data.options do
		local itemName = data.options[i].name
		items[i] = itemName
		if itemName == defaultName then
			defaultItem = i
		end
	end
	
	local freezeSettings = true
	
	settingsComboBoxes[data.name] = ComboBox:New {
		name = data.name .. "_combo",
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = items,
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = defaultItem,
		OnSelect = {
			function (obj, num)
				if freezeSettings then
					return freezeSettings
				end
			
				local selectedData = data.options[num]
				Configuration.settingsMenuValues[data.name] = selectedData.name
				
				if customSettingsSwitch then
					customSettingsSwitch()
				end
				
				if data.fileTarget then
					local sourceFile = VFS.LoadFile(selectedData.file)
					local settingsFile = io.open(data.fileTarget, "w")
					settingsFile:write(sourceFile)
					settingsFile:close()
				else
					local applyData = selectedData.apply
					for applyName, value in pairs(applyData) do
						Configuration.game_settings[applyName] = value
						SetSpringsettingsValue(applyName, value)
					end
				end
			end
		}
	}
	
	freezeSettings = false
	
	return label, settingsComboBoxes[data.name], offset + ITEM_OFFSET
end

local function ProcessSettingsNumber(data, offset, defaults, customSettingsSwitch)
	local Configuration = WG.Chobby.Configuration
	
	local label = Label:New {
		name = data.name .. "_label",
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 350,
		height = 30,
		valign = "top",
		align = "left",
		caption = data.humanName,
		font = Configuration:GetFont(2),
		tooltip = data.desc,
	}
	
	local function SetEditboxValue(obj, newValue)
		newValue = tonumber(newValue)
		
		if not newValue then
			obj:SetText(tostring(Configuration.settingsMenuValues[data.name]))
			return
		end
		
		if customSettingsSwitch then
			customSettingsSwitch()
		end
		
		local newValue = math.floor(0.5 + math.max(data.minValue, math.min(data.maxValue, newValue)))
		local springValue = data.springConversion(newValue)
		Configuration.settingsMenuValues[data.name] = newValue
		Configuration.game_settings[data.applyName] = springValue
		SetSpringsettingsValue(data.applyName, springValue)
		
		obj:SetText(tostring(newValue))
	end
	
	local freezeSettings = true
	
	local numberInput = EditBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		text = tostring(Configuration.settingsMenuValues[data.name] or defaults[data.name]),
		font = Configuration:GetFont(2),
		OnFocusUpdate = {
			function (obj)
				if obj.focused or freezeSettings then
					return
				end
				SetEditboxValue(obj, obj.text)
			end
		}
	}
	
	freezeSettings = false
	
	settingsUpdateFunction[data.name] = function (newValue)
		SetEditboxValue(numberInput, newValue)
	end

	return label, numberInput, offset + ITEM_OFFSET
end

local function PopulateTab(settingPresets, settingOptions, settingsDefaults)
	local children = {}
	local offset = ITEM_OFFSET
	local customSettingsSwitch
	local label, list
	
	if settingPresets then
		label, list, customSettingsSwitch, offset = MakePresetsControl(settingPresets, offset)
		children[#children + 1] = label
		children[#children + 1] = list
	end
	
	for i = 1, #settingOptions do
		local data = settingOptions[i]
		if data.displayModeToggle then
			label, list, offset = ProcessScreenSizeOption(data, offset)
		elseif data.isNumberSetting then
			label, list, offset = ProcessSettingsNumber(data, offset, settingsDefaults, customSettingsSwitch)
		else
			label, list, offset = ProcessSettingsOption(data, offset, settingsDefaults, customSettingsSwitch)
		end
		children[#children + 1] = label
		children[#children + 1] = list
	end
	return children
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization


local function InitializeControls(window)
	window.OnParent = nil

	local tabs = {
		{
			name = "Lobby",
			caption = "Lobby",
			font = WG.Chobby.Configuration:GetFont(3),
			children = GetLobbyTabControls()
		}
	}
	
	local settingsFile, settingsDefaults = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/zk/settingsMenu.lua")
	
	for i = 1, #settingsFile do
		local data = settingsFile[i]
		tabs[#tabs + 1] = {
			name = data.name,
			caption = data.name,
			font = WG.Chobby.Configuration:GetFont(3),
			children = PopulateTab(data.presets, data.settings, settingsDefaults)
		}
	end
	
	local tabPanel = Chili.DetachableTabPanel:New {
		x = 5,
		right = 5,
		y = 45,
		bottom = 1,
		padding = {0, 0, 0, 0},
		minTabWidth = 130,
		tabs = tabs,
		parent = window,
		OnTabChange = {
		}
	}

	local tabBarHolder = Control:New {
		name = "tabBarHolder",
		x = 0,
		y = 0,
		width = "100%",
		height = 50,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = window,
		children = {
			tabPanel.tabBar
		}
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local SettingsWindow = {}

function SettingsWindow.GetControl()

	local window = Control:New {
		name = "settingsWindow",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local ignoreFirstCall = true
function widget:ActivateMenu()
	if ignoreFirstCall then
		ignoreFirstCall = false
		return
	end
	if not (WG.Chobby and WG.Chobby.Configuration) then
		return
	end
	SetLobbyFullscreenMode(WG.Chobby.Configuration.lobby_fullscreen)
end

local onBattleAboutToStart

local function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	battleStartDisplay = Configuration.game_fullscreen or 1
	lobbyFullscreen = Configuration.lobby_fullscreen or 1
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	onBattleAboutToStart = function(listener)
		local screenX, screenY = Spring.GetScreenGeometry()

		SetLobbyFullscreenMode(battleStartDisplay)

		-- Settings which rely on io
		local gameSettings = WG.Chobby.Configuration.game_settings

		if battleStartDisplay == 1 then
			gameSettings.XResolutionWindowed = screenX
			gameSettings.YResolutionWindowed = screenY
			gameSettings.WindowPosX = 0
			gameSettings.WindowPosY = 0
			gameSettings.WindowBorderless = 1
		elseif battleStartDisplay == 2 then
			gameSettings.WindowPosX = 0
			gameSettings.WindowPosY = 80
			gameSettings.XResolutionWindowed = screenX
			gameSettings.YResolutionWindowed = screenY - 80
			gameSettings.WindowBorderless = 0
			gameSettings.WindowBorderless = 0
			gameSettings.Fullscreen = 0
		elseif battleStartDisplay == 3 then
			gameSettings.XResolution = screenX
			gameSettings.YResolution = screenY
			gameSettings.Fullscreen = 1
		end


		for key, value in pairs(gameSettings) do
			SetSpringsettingsValue(key, value)
		end
	end
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", onBattleAboutToStart)
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", onBattleAboutToStart)

	WG.SettingsWindow = SettingsWindow
end

function widget:Shutdown()
	SetLobbyFullscreenMode(lobbyFullscreen)

	if WG.LibLobby then
		WG.LibLobby.lobby:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
		WG.LibLobby.localLobby:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------