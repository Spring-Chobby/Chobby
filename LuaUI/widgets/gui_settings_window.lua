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

local externalSettings = {}
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
	
	local ingameOffset = 250
	
	local freezeSettings = true
	
	local Configuration = WG.Chobby.Configuration
	
	Label:New {
		x = 40,
		y = 40,
		width = 180,
		height = 30,
		parent = window,
		font = WG.Chobby.Configuration:GetFont(4),
		caption = "Lobby",
	}
	Label:New {
		x = 40,
		y = 70,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font = WG.Chobby.Configuration:GetFont(3),
		caption = "Display:",
	}
	ComboBox:New {
		x = 130,
		y = 70,
		width = 180,
		height = 45,
		parent = window,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
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
	
	Label:New {
		x = 40,
		y = 120,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = "Panels:",
	}
	ComboBox:New {
		x = 130,
		y = 120,
		width = 180,
		height = 45,
		parent = window,
		items = {"Autodetect", "Always Two", "Always One"},
		selected = Configuration.panel_layout or 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				if obj.selected == 1 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(true)
				elseif obj.selected == 2 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(false, true)
				elseif obj.selected == 3 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(false, false)
				end
				
				Configuration.panel_layout = obj.selected
			end
		},
	}
	
	local autologin = Checkbox:New {
		x = 60,
		width = 200,
		y = 170,
		height = 40,
		parent = window,
		boxalign = "right",
		boxsize = 20,
		caption = i18n("autologin"),
		checked = Configuration.autoLogin or false,
		font = { size = 20},
		OnClick = {function (obj)
			Configuration.autoLogin = obj.checked
		end},
	}
	
	externalSettings.autologin = {
		SetValue = function(value) 
			Spring.Echo("SetValue")
			autologin:SetToggle(value)
		end
	}
	
	Label:New {
		x = 40,
		y = 40 + ingameOffset,
		width = 180,
		height = 30,
		parent = window,
		font = {size = 30},
		caption = "Game",
	}
	Label:New {
		x = 40,
		y = 70 + ingameOffset,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = "Display:",
	}
	ComboBox:New {
		x = 130,
		y = 70 + ingameOffset,
		width = 180,
		height = 45,
		parent = window,
		items = {"Fullscreen Window", "Windowed", "Fullscreen"},
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
	
	Label:New {
		x = 40,
		y = 120 + ingameOffset,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = "Singleplayer:",
	}
	ComboBox:New {
		name = "gameSelection",
		x = 130,
		y = 120 + ingameOffset,
		width = 180,
		height = 45,
		parent = window,
		items = {"Generic", "Zero-K"},
		selected = Configuration.singleplayer_mode or 2,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				-- Leave singleplayer submenu
				if Configuration.singleplayer_mode ~= obj.selected then
					local mainMenu = WG.Chobby.interfaceRoot.GetMainWindowHandler()
					if mainMenu.GetCurrentSubmenu() == 1 then
						mainMenu.SetBackAtMainMenu()
					end
					
					local replacementTabs = {
						{
							name = "custom" .. Configuration.singleplayer_mode, 
							control = WG.BattleRoomWindow.GetSingleplayerControl(),
							entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
						},
					}
					
					mainMenu.ReplaceSubmenu(1, replacementTabs)
				end
				
				-- Set new value
				Configuration:SetSingleplayerMode(obj.selected)
			end
		},
	}
	
	Label:New {
		x = 40,
		y = 170 + ingameOffset,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = "Settings:",
	}
	
	local function SettingsButton(pos, caption, settings)
		return Button:New {
			x = 80*pos,
			y = 0, 
			width = 80, 
			bottom = 0,
			caption = caption,
			font =  WG.Chobby.Configuration:GetFont(2),
			OnClick = {
				function ()
					WG.Chobby.Configuration.game_settings = VFS.Include("luaui/configs/springsettings/" .. settings)
				end
			},
		}
	end
	
	Control:New {
		x = 130,
		y = 170 + ingameOffset,
		width = 540,
		height = 45,
		parent = window,
		children = {
			SettingsButton(0,   "Minimal", "springsettings0.lua"),
			SettingsButton(1,  "Low",     "springsettings1.lua"),
			SettingsButton(2, "Medium",  "springsettings2.lua"),
			SettingsButton(3, "High",    "springsettings3.lua"),
			SettingsButton(4, "Ultra",   "springsettings4.lua"),
			
		}
	}
	
	freezeSettings = false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local SettingsWindow = {}

function SettingsWindow.SetConfigValue(key, value)
	Spring.Echo("externalSettings", key, value)
	if externalSettings[key] then
		externalSettings[key].SetValue(value)
	end
end

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
	
	externalSettings.autologin = {
		SetValue = function(value)
			 WG.Chobby.Configuration.autoLogin = value
		end
	}
	
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

function widget:GetConfigData()
	--local spacingByName = {}
	--for unitDefID, spacing in pairs(buildSpacing) do
	--	local name = UnitDefs[unitDefID] and UnitDefs[unitDefID].name
	--	if name then
	--		spacingByName[name] = spacing
	--	end
	--end
	return {} -- { buildSpacing = spacingByName }
end

function widget:SetConfigData(data)
    --local spacingByName = data.buildSpacing or {}
	--for name, spacing in pairs(spacingByName) do
	--	local unitDefID = UnitDefNames[name] and UnitDefNames[name].id
	--	if unitDefID then
	--		buildSpacing[unitDefID] = spacing
	--	end
	--end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
