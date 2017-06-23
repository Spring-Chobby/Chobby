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

local function ToggleFullscreenOff()
	Spring.SetConfigInt("Fullscreen", 1, false)
	Spring.SetConfigInt("Fullscreen", 0, false)

	if WG.Chobby.Configuration.agressivelySetBorderlessWindowed then
		local screenX, screenY = Spring.GetScreenGeometry()
		Spring.SetConfigInt("XResolutionWindowed", screenX - FUDGE*2, false)
		Spring.SetConfigInt("YResolutionWindowed", screenY - FUDGE*2, false)
		Spring.SetConfigInt("WindowPosX", FUDGE, false)
		Spring.SetConfigInt("WindowPosY", FUDGE, false)
	end
end

local function ToggleFullscreenOn()
	Spring.SetConfigInt("Fullscreen", 0, false)
	Spring.SetConfigInt("Fullscreen", 1, false)
end

local function SetLobbyFullscreenMode(mode)
	if mode == currentMode then
		return
	end

	local Configuration = WG.Chobby.Configuration

	-- Remember window settings
	if currentMode == 2 then
		local x = Spring.GetConfigInt("WindowPosX")
		local y = Spring.GetConfigInt("WindowPosY")
		local width = Spring.GetConfigInt("XResolutionWindowed")
		local height = Spring.GetConfigInt("YResolutionWindowed")

		if x then
			Configuration:SetConfigValue("window_WindowPosX", x)
		end
		if y then
			Configuration:SetConfigValue("window_WindowPosY", y)
		end
		if width then
			Configuration:SetConfigValue("window_XResolutionWindowed", width)
		end
		if height then
			Configuration:SetConfigValue("window_YResolutionWindowed", height)
		end
	end

	currentMode = mode

	if Configuration.doNotSetAnySpringSettings then
		return
	end

	Spring.Echo("SetLobbyFullscreenMode", mode)

	local screenX, screenY = Spring.GetScreenGeometry()
	Spring.Echo("screenX, screenY", screenX, screenY)
	if mode == 1 then
		-- Required to remove FUDGE
		Spring.SetConfigInt("Fullscreen", 1)

		Spring.SetConfigInt("XResolutionWindowed", screenX - FUDGE*2, false)
		Spring.SetConfigInt("YResolutionWindowed", screenY - FUDGE*2, false)
		Spring.SetConfigInt("WindowPosX", FUDGE, false)
		Spring.SetConfigInt("WindowPosY", FUDGE, false)
		Spring.SetConfigInt("WindowBorderless", 1, false)
		Spring.SetConfigInt("Fullscreen", 0, false)

		WG.Delay(ToggleFullscreenOff, 0.1)
		if Configuration.agressivelySetBorderlessWindowed then
			WG.Delay(ToggleFullscreenOff, 0.5)
		end
	elseif mode == 2 then
		local winSizeX, winSizeY, winPosX, winPosY = Spring.GetWindowGeometry()
		winPosX = Configuration.window_WindowPosX or winPosX
		winSizeX = Configuration.window_XResolutionWindowed or winSizeX
		winSizeY = Configuration.window_YResolutionWindowed or winSizeY

		if Configuration.window_WindowPosY then
			winPosY = Configuration.window_WindowPosY
		else
			winPosY = screenY - winPosY - winSizeY
		end

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
		--WG.Delay(ToggleFullscreenOn, 0.1)
	end
end

local function SaveLobbyDisplayMode()
	local Configuration = WG.Chobby.Configuration

	-- Remember window settings
	if (currentMode == 2 or not currentMode) and lobbyFullscreen == 2 then
		local x = Spring.GetConfigInt("WindowPosX")
		local y = Spring.GetConfigInt("WindowPosY")
		local width = Spring.GetConfigInt("XResolutionWindowed")
		local height = Spring.GetConfigInt("YResolutionWindowed")

		if x then
			Configuration:SetConfigValue("window_WindowPosX", x)
		end
		if y then
			Configuration:SetConfigValue("window_WindowPosY", y)
		end
		if width then
			Configuration:SetConfigValue("window_XResolutionWindowed", width)
		end
		if height then
			Configuration:SetConfigValue("window_YResolutionWindowed", height)
		end
	end

	SetLobbyFullscreenMode(lobbyFullscreen)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Lobby Settings

local function AddCheckboxSetting(offset, caption, key, default)
	local Configuration = WG.Chobby.Configuration

	local checked = Configuration[key]
	if checked == nil then
		checked = default
	end

	local control = Checkbox:New {
		x = 20,
		width = CHECK_WIDTH,
		y = offset,
		height = 30,
		boxalign = "right",
		boxsize = 20,
		caption = caption,
		checked = checked,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue(key, newState)
		end},
	}

	return control, offset + ITEM_OFFSET
end

local function GetLobbyTabControls()
	local freezeSettings = true

	local Configuration = WG.Chobby.Configuration

	local offset = 5

	local children = {}

	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 30,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Lobby Display Mode",
	}
	children[#children + 1] = ComboBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = {"Borderless Window", "Windowed", "Fullscreen"},
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
		caption = "Split Panel Mode",
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
		caption = "Background Brightness",
	}
	children[#children + 1] = Trackbar:New {
		x = COMBO_X,
		y = offset,
		width  = COMBO_WIDTH,
		height = 30,
		value  = Configuration.menuBackgroundBrightness or 1,
		min    = 0,
		max    = 1,
		step   = 0.02,
		OnChange = {
			function(obj, value)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("menuBackgroundBrightness", value)
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
		caption = "Game Overlay Opacity",
	}
	children[#children + 1] = Trackbar:New {
		x = COMBO_X,
		y = offset,
		width  = COMBO_WIDTH,
		height = 30,
		value  = Configuration.gameOverlayOpacity or 0.5,
		min    = 0,
		max    = 1,
		step   = 0.02,
		OnChange = {
			function(obj, value)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("gameOverlayOpacity", value)
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

	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("planetwars_notifications"), "planetwarsNotifications", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("simplifiedSkirmishSetup"), "simplifiedSkirmishSetup", true)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("notifyForAllChat"), "notifyForAllChat", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("only_featured_maps"), "onlyShowFeaturedMaps", true)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("login_with_steam"), "wantAuthenticateWithSteam", true)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("animate_lobby"), "animate_lobby", true)

	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Delete Path Cache",
	}
	children[#children + 1] = Button:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		caption = "Apply",
		tooltip = "Deletes path cache. May solve desync.",
		font = Configuration:GetFont(2),
		OnClick = {
			function (obj)
				if WG.CacheHandler then
					WG.CacheHandler.DeletePathCache()
				end
			end
		}
	}
	offset = offset + ITEM_OFFSET

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

local function GetVoidTabControls()
	local freezeSettings = true

	local Configuration = WG.Chobby.Configuration

	local offset = 5

	local children = {}

	children[#children + 1] = TextBox:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		right = 10,
		height = 40,
		valign = "top",
		align = "left",
		fontsize = Configuration:GetFont(3).size,
		text = "Warning: These settings are experimental and not officially supported, proceed at your own risk.",
	}
	offset = offset + 65

	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("debugMode"), "debugMode", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Debug server messages", "activeDebugConsole", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Show channel bots", "displayBots", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Show wrong engines", "displayBadEngines", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Debug for MatchMaker", "showMatchMakerBattles", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Hide interface", "hideInterface", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Neuter Settings", "doNotSetAnySpringSettings", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Agressive Set Borderless", "agressivelySetBorderlessWindowed", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Use wrong engine", "useWrongEngine", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, "Show old AI versions", "showOldAiVersions", false)
	children[#children + 1], offset = AddCheckboxSetting(offset, i18n("drawFullSpeed"), "drawAtFullSpeed", false)

	children[#children + 1] = Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 40,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Clear Channel History",
	}
	children[#children + 1] = Button:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		caption = "Apply",
		tooltip = "Clears chat history displayed in the lobby, does not affect the chat history files saved to your computer.",
		font = Configuration:GetFont(2),
		OnClick = {
			function (obj)
				WG.Chobby.interfaceRoot.GetChatWindow():ClearHistory()
				WG.BattleRoomWindow.ClearChatHistory()
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

	local singleplayerSelectedName = Configuration.gameConfigName
	local singleplayerSelected = 1
	for i = 1, #Configuration.gameConfigOptions do
		if Configuration.gameConfigOptions[i] == singleplayerSelectedName then
			singleplayerSelected = i
			break
		end
	end

	children[#children + 1] = ComboBox:New {
		name = "gameSelection",
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		parent = window,
		items = Configuration.gameConfigHumanNames,
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = singleplayerSelected,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				Configuration:SetConfigValue("gameConfigName", Configuration.gameConfigOptions[obj.selected])
			end
		},
	}
	offset = offset + ITEM_OFFSET

	freezeSettings = false

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
		items = {"Borderless Window", "Windowed", "Fullscreen"},
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
	local defaultName = Configuration.settingsMenuValues[data.name] or ((data.defaultFunction and data.defaultFunction()) or defaults[data.name])

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
				if customSettingsSwitch then
					customSettingsSwitch()
				end
				Configuration:SetSettingsConfigOption(data.name, data.options[num].name)
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
		obj:SetText(tostring(newValue))
		
		Configuration:SetSettingsConfigOption(data.name, newValue)
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

local function PopulateTab(settingPresets, settingOptions, settingsDefault)
	local children = {}
	local offset = 5
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
			label, list, offset = ProcessSettingsNumber(data, offset, settingsDefault, customSettingsSwitch)
		else
			label, list, offset = ProcessSettingsOption(data, offset, settingsDefault, customSettingsSwitch)
		end
		children[#children + 1] = label
		children[#children + 1] = list
	end

	return children
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function MakeTab(name, children)
	local contentsPanel = ScrollPanel:New {
		x = 5,
		right = 5,
		y = 10,
		bottom = 8,
		horizontalScrollbar = false,
		children = children
	}

	return {
		name = name,
		caption = name,
		font = WG.Chobby.Configuration:GetFont(3),
		children = {contentsPanel}
	}
end

local function InitializeControls(window)
	window.OnParent = nil

	local tabs = {
		MakeTab("Lobby", GetLobbyTabControls())
	}

	local settingsFile = WG.Chobby.Configuration.gameConfig.settingsConfig
	local settingsDefault = WG.Chobby.Configuration.gameConfig.settingsDefault

	for i = 1, #settingsFile do
		local data = settingsFile[i]
		tabs[#tabs + 1] = MakeTab(data.name, PopulateTab(data.presets, data.settings, settingsDefault))
	end

	tabs[#tabs + 1] = MakeTab("Developer", GetVoidTabControls())

	local tabPanel = Chili.DetachableTabPanel:New {
		x = 5,
		right = 5,
		y = 45,
		bottom = 1,
		padding = {0, 0, 0, 0},
		minTabWidth = 120,
		tabs = tabs,
		parent = window,
		OnTabChange = {
		}
	}

	local tabBarHolder = Control:New {
		name = "tabBarHolder",
		x = 0,
		y = 0,
		right = 0,
		height = 55,
		resizable = false,
		draggable = false,
		padding = {14, 8, 14, 0},
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

function SettingsWindow.WriteGameSpringsettings(fileName)
	local settingsFile, errorMessage = io.open(fileName, 'w+')
	if not settingsFile then
		return
	end
	local fixedSettingsOverride = WG.Chobby.Configuration.fixedSettingsOverride
	
	local function WriteToFile(key, value)
		value = (fixedSettingsOverride and fixedSettingsOverride[key]) or value
		settingsFile:write(key .. " = " .. value .. "\n")
	end
	
	local gameSettings = WG.Chobby.Configuration.game_settings
	for key, value in pairs(gameSettings) do
		WriteToFile(key, value)
	end
	
	local screenX, screenY = Spring.GetScreenGeometry()
	if battleStartDisplay == 1 then
		WriteToFile("XResolutionWindowed", screenX)
		WriteToFile("YResolutionWindowed", screenY)
		WriteToFile("WindowPosX", 0)
		WriteToFile("WindowPosY", 0)
		WriteToFile("WindowBorderless", 1)
	elseif battleStartDisplay == 2 then
		WriteToFile("WindowPosX", 0)
		WriteToFile("WindowPosY", 80)
		WriteToFile("XResolutionWindowed", screenX)
		WriteToFile("YResolutionWindowed", screenY - 80)
		WriteToFile("WindowBorderless", 0)
		WriteToFile("Fullscreen", 0)
	elseif battleStartDisplay == 3 then
		WriteToFile("XResolution", screenX)
		WriteToFile("YResolution", screenY)
		WriteToFile("WindowBorderless", 0)
		WriteToFile("Fullscreen", 1)
	end
end

function SettingsWindow.GetSettingsString()
	local settingsString = nil
	
	local function WriteSetting(key, value)
		if settingsString then
			settingsString = settingsString .. "\n" .. key .. " = " .. value
		else
			settingsString = key .. " = " .. value
		end
	end
	
	local gameSettings = WG.Chobby.Configuration.game_settings
	for key, value in pairs(gameSettings) do
		WriteSetting(key, value)
	end
	
	local screenX, screenY = Spring.GetScreenGeometry()
	if battleStartDisplay == 1 then
		WriteSetting("XResolutionWindowed", screenX)
		WriteSetting("YResolutionWindowed", screenY)
		WriteSetting("WindowPosX", 0)
		WriteSetting("WindowPosY", 0)
		WriteSetting("WindowBorderless", 1)
	elseif battleStartDisplay == 2 then
		WriteSetting("WindowPosX", 0)
		WriteSetting("WindowPosY", 80)
		WriteSetting("XResolutionWindowed", screenX)
		WriteSetting("YResolutionWindowed", screenY - 80)
		WriteSetting("WindowBorderless", 0)
		WriteSetting("Fullscreen", 0)
	elseif battleStartDisplay == 3 then
		WriteSetting("XResolution", screenX)
		WriteSetting("YResolution", screenY)
		WriteSetting("WindowBorderless", 0)
		WriteSetting("Fullscreen", 1)
	end
	
	return settingsString
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local firstCall = true
function widget:ActivateMenu()
	if firstCall then
		local gameSettings = WG.Chobby.Configuration.game_settings
		for key, value in pairs(gameSettings) do
			WG.Chobby.Configuration:SetSpringsettingsValue(key, value)
		end

		firstCall = false
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
		local Configuration = WG.Chobby.Configuration

		-- Settings which rely on io
		local gameSettings = Configuration.game_settings

		if battleStartDisplay == 1 then
			Configuration:SetSpringsettingsValue("XResolutionWindowed", screenX)
			Configuration:SetSpringsettingsValue("YResolutionWindowed", screenY)
			Configuration:SetSpringsettingsValue("WindowPosX", 0)
			Configuration:SetSpringsettingsValue("WindowPosY", 0)
			Configuration:SetSpringsettingsValue("WindowBorderless", 1)
		elseif battleStartDisplay == 2 then
			Configuration:SetSpringsettingsValue("WindowPosX", 0)
			Configuration:SetSpringsettingsValue("WindowPosY", 80)
			Configuration:SetSpringsettingsValue("XResolutionWindowed", screenX)
			Configuration:SetSpringsettingsValue("YResolutionWindowed", screenY - 80)
			Configuration:SetSpringsettingsValue("WindowBorderless", 0)
			Configuration:SetSpringsettingsValue("WindowBorderless", 0)
			Configuration:SetSpringsettingsValue("Fullscreen", 0)
		elseif battleStartDisplay == 3 then
			Configuration:SetSpringsettingsValue("XResolution", screenX)
			Configuration:SetSpringsettingsValue("YResolution", screenY)
			Configuration:SetSpringsettingsValue("Fullscreen", 1)
		end

		for key, value in pairs(gameSettings) do
			Configuration:SetSpringsettingsValue(key, value)
		end
		
		local compatProfile = Configuration.forcedCompatibilityProfile
		Spring.Utilities.TableEcho(compatProfile, "compatProfile")
		if compatProfile then
			for key, value in pairs(compatProfile) do
				Configuration:SetSpringsettingsValue(key, value, true)
			end
		end
	end
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", onBattleAboutToStart)
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", onBattleAboutToStart)

	WG.SettingsWindow = SettingsWindow
end

function widget:Shutdown()
	SaveLobbyDisplayMode()

	if WG.LibLobby then
		WG.LibLobby.lobby:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
		WG.LibLobby.localLobby:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
