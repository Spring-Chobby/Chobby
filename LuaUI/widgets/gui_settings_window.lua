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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function SetLobbyFullscreenMode(mode)
	local screenX, screenY = Spring.GetScreenGeometry()
	if mode == 1 then
		Spring.SetConfigInt("XResolutionWindowed", screenX, false)
		Spring.SetConfigInt("YResolutionWindowed", screenY, false)
		Spring.SetConfigInt("WindowPosX", 0, false)
		Spring.SetConfigInt("WindowPosY", 0, false)
		Spring.SetConfigInt("WindowBorderless", 1, false)
		Spring.SendCommands("fullscreen 0")
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
		Spring.SetConfigInt("Fullscreen", 0, false)
		Spring.SendCommands("fullscreen 0") 
	elseif mode == 3 then
		Spring.SetConfigInt("XResolution", screenX, false)
		Spring.SetConfigInt("YResolution", screenY, false)
		Spring.SetConfigInt("Fullscreen", 1, false)
		Spring.SendCommands("fullscreen 1")
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization


local function InitializeControls(window)
	window.OnParent = nil
	
	local freezeSettings = true
	
	local Configuration = WG.Chobby.Configuration
	
	local offset = 20
	
	Label:New {
		x = 40,
		y = offset,
		width = 180,
		height = 30,
		parent = window,
		font = Configuration:GetFont(4),
		caption = "Lobby",
	}
	offset = offset + 20
	
	offset = offset + 10
	Label:New {
		x = 40,
		y = offset,
		width = 90,
		height = 40,
		valign = "center",
		align = "right",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Display:",
	}
	ComboBox:New {
		x = 140,
		y = offset,
		width = 180,
		height = 45,
		parent = window,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.lobby_fullscreen or 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
			
				SetLobbyFullscreenMode(obj.selected)
				
				lobbyFullscreen = obj.selected
				Configuration.lobby_fullscreen = obj.selected
			end
		},
	}
	offset = offset + 40
	
	offset = offset + 10
	Label:New {
		x = 40,
		y = offset,
		width = 90,
		height = 40,
		valign = "center",
		align = "right",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Panels:",
	}
	ComboBox:New {
		x = 140,
		y = offset,
		width = 180,
		height = 45,
		parent = window,
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
	offset = offset + 40
	
	local autoLogin = Checkbox:New {
		x = 60,
		width = 200,
		y = offset,
		height = 40,
		parent = window,
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
	offset = offset + 30
	
	local notifyAllChat = Checkbox:New {
		x = 60,
		width = 200,
		y = offset,
		height = 40,
		parent = window,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("notifyForAllChat"),
		checked = Configuration.notifyForAllChat or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("notifyForAllChat", newState)
		end},
	}
	offset = offset + 30
	
	local mapWhitelist = Checkbox:New {
		x = 60,
		width = 200,
		y = offset,
		height = 40,
		parent = window,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("only_featured_maps"),
		checked = Configuration.onlyShowFeaturedMaps or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("onlyShowFeaturedMaps", newState)
		end},
	}
	offset = offset + 30
	
	local debugMode = Checkbox:New {
		x = 60,
		width = 200,
		y = offset,
		height = 40,
		parent = window,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("debugMode"),
		checked = Configuration.debugMode or false,
		font = Configuration:GetFont(2),
		OnChange = {function (obj, newState)
			Configuration:SetConfigValue("debugMode", newState)
		end},
	}
	offset = offset + 30
	
	------------------------------------------------------------------
	-- Ingame
	------------------------------------------------------------------
	
	offset = offset + 60
	Label:New {
		x = 40,
		y = offset,
		width = 180,
		height = 30,
		parent = window,
		font = Configuration:GetFont(4),
		caption = "Game",
	}
	offset = offset + 20
	
	offset = offset + 10
	Label:New {
		x = 40,
		y = offset,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Display:",
	}
	ComboBox:New {
		x = 140,
		y = offset,
		width = 180,
		height = 45,
		parent = window,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = Configuration.game_fullscreen or battleStartDisplay,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				battleStartDisplay = obj.selected
				Configuration.game_fullscreen = obj.selected
			end
		},
	}
	offset = offset + 40
	
	offset = offset + 10
	Label:New {
		x = 40,
		y = offset,
		width = 90,
		height = 40,
		valign = "center",
		align = "right",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Singleplayer:",
	}
	ComboBox:New {
		name = "gameSelection",
		x = 140,
		y = offset,
		width = 180,
		height = 45,
		parent = window,
		items = {"Generic", "Zero-K"},
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
	offset = offset + 40
	
	offset = offset + 10
	Label:New {
		x = 40,
		y = offset,
		width = 90,
		height = 40,
		valign = "center",
		align = "right",
		parent = window,
		font = Configuration:GetFont(2),
		caption = "Settings:",
	}
	
	local useCustomSettings = true
	local settingsPresetControls = {}
	
	local function SettingsButton(x, y, caption, settings)
		local button = Button:New {
			name = caption,
			x = 90*x,
			y = 55*y, 
			width = 80, 
			height = 45,
			caption = caption,
			font = Configuration:GetFont(2),
			OnClick = {
				function (obj)
					if settings then
						Configuration.game_settings = VFS.Include("luaui/configs/springsettings/" .. settings)
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
			if Spring.Utilities.TableEqual(VFS.Include("luaui/configs/springsettings/" .. settings), Configuration.game_settings) then
				useCustomSettings = false
				ButtonUtilities.SetButtonSelected(button)
			end
		elseif useCustomSettings then
			ButtonUtilities.SetButtonSelected(button)
		end
		return button
	end
	
	local settingsHolder = Control:New {
		x = 135,
		y = offset,
		width = 540,
		height = 120,
		parent = window,
		padding = {0, 0, 0, 0},
		children = {
			SettingsButton(0, 0, "Minimal", "springsettings0.lua"),
			SettingsButton(1, 0, "Low",     "springsettings1.lua"),
			SettingsButton(2, 0, "Medium",  "springsettings2.lua"),
			SettingsButton(0, 1, "High",    "springsettings3.lua"),
			SettingsButton(1, 1, "Ultra",   "springsettings4.lua"),
		}
	}
	
	local customSettingsButton = SettingsButton(2, 1,  "Custom")
	settingsHolder:AddChild(customSettingsButton)
	
	freezeSettings = false
	
	local function onConfigurationChange(listener, key, value)
		if freezeSettings then
			return
		end
		if key == "autoLogin" then
			autoLogin:SetToggle(value)
		end
	end
	
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local SettingsWindow = {}

function SettingsWindow.GetControl()
	
	local window = Control:New {
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

local onBattleAboutToStart

local function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	battleStartDisplay = Configuration.game_fullscreen or 1
	lobbyFullscreen = Configuration.lobby_fullscreen or 1
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.Delay(DelayedInitialize, 1)
	
	onBattleAboutToStart = function(listener)
		local screenX, screenY = Spring.GetScreenGeometry()
		
		-- Stopgap solution, has side effects
		if battleStartDisplay == 1 then
			Spring.SetConfigInt("XResolutionWindowed", screenX, false)
			Spring.SetConfigInt("YResolutionWindowed", screenY, false)
			Spring.SetConfigInt("WindowPosX", 0, false)
			Spring.SetConfigInt("WindowPosY", 0, false)
			Spring.SetConfigInt("WindowBorderless", 1, false)
		elseif battleStartDisplay == 2 then
			Spring.SetConfigInt("WindowPosX", 0, false)
			Spring.SetConfigInt("WindowPosY", 80, false)
			Spring.SetConfigInt("XResolutionWindowed", screenX, false)
			Spring.SetConfigInt("YResolutionWindowed", screenY - 80, false)
			Spring.SetConfigInt("WindowBorderless", 0, false)
			Spring.SetConfigInt("WindowBorderless", 0, false)
			Spring.SetConfigInt("Fullscreen", 0, false)
		elseif battleStartDisplay == 3 then
			Spring.SetConfigInt("XResolution", screenX, false)
			Spring.SetConfigInt("YResolution", screenY, false)
			Spring.SetConfigInt("Fullscreen", 1, false)
		end
		
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
		
		--local settingsFile, errorMessage = io.open('springsettings.cfg', 'w+')
		--if settingsFile then
		--	for key, value in pairs(gameSettings) do
		--		settingsFile:write(key .. " = " .. value .. "\n")
		--	end
		--end

		local configParamTypes = {}
		for _, param in pairs(Spring.GetConfigParams()) do
			configParamTypes[param.name] = param.type
		end
		for key, value in pairs(gameSettings) do
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
	end
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", onBattleAboutToStart)
	WG.LibLobby.lobbySkirmish:AddListener("OnBattleAboutToStart", onBattleAboutToStart)
	
	WG.SettingsWindow = SettingsWindow
end

function widget:Shutdown()
	SetLobbyFullscreenMode(lobbyFullscreen)

	if WG.LibLobby then
		WG.LibLobby.lobby:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
		WG.LibLobby.lobbySkirmish:RemoveListener("OnBattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------