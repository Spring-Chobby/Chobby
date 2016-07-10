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
		Spring.SetConfigInt("WindowPosX", screenX/4, false)
		Spring.SetConfigInt("WindowPosY", screenY/8, false)
		Spring.SetConfigInt("XResolutionWindowed", screenX/2, false)
		Spring.SetConfigInt("YResolutionWindowed", screenY*3/4, false)
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
		font = {size = 30},
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
		font = {size = 20},
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
		font = {size = 20},
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
		font = {size = 20},
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
		font = {size = 20},
		caption = "Singleplayer:",
	}
	ComboBox:New {
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
							name = "custom_caps" .. Configuration.singleplayer_mode, 
							control = WG.BattleRoomWindow.GetSingleplayerControl(),
							entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
						},
					}
					
					mainMenu.ReplaceSubmenu(1, replacementTabs)
				end
				
				-- Set new value
				Configuration.singleplayer_mode = obj.selected
			end
		},
	}
	
	freezeSettings = false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local SettingsWindow = {}

function SettingsWindow.SetConfigValue(key, value)
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
	
	onBattleAboutToStart = function(listener)
		local screenX, screenY = Spring.GetScreenGeometry()
		Spring.Echo("battleStartDisplay", battleStartDisplay)
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
	end
	WG.LibLobby.lobby:AddListener("BattleAboutToStart", onBattleAboutToStart)
	WG.LibLobby.lobbySkirmish:AddListener("BattleAboutToStart", onBattleAboutToStart)
	
	WG.SettingsWindow = SettingsWindow
end

function widget:Shutdown()
	SetLobbyFullscreenMode(lobbyFullscreen)

	if WG.LibLobby then
		WG.LibLobby.lobbySkirmish:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
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
