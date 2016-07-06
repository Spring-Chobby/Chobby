--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Settings Window",
		desc      = "Handles settings.",
		author    = "GoogleFrog",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local fullscreen = 0

local battleStartDisplay = 1

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local SettingsWindow = {}

function SettingsWindow.GetControl()
	
	local window = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
	}
	
	local ingameOffset = 250
	
	local freezeSettings = true
	
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
		selected = 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				local screenX, screenY = Spring.GetScreenGeometry()
			
				if obj.selected == 1 then
					Spring.SetConfigInt("XResolutionWindowed", screenX, false)
					Spring.SetConfigInt("YResolutionWindowed", screenY, false)
					Spring.SetConfigInt("WindowPosX", 0, false)
					Spring.SetConfigInt("WindowPosY", 0, false)
					Spring.SetConfigInt("WindowBorderless", 1, false)
					Spring.SendCommands("fullscreen 0")
				elseif obj.selected == 2 then
					Spring.SetConfigInt("WindowPosX", screenX/4, false)
					Spring.SetConfigInt("WindowPosY", screenY/8, false)
					Spring.SetConfigInt("XResolutionWindowed", screenX/2, false)
					Spring.SetConfigInt("YResolutionWindowed", screenY*3/4, false)
					Spring.SetConfigInt("WindowBorderless", 0, false)
					Spring.SetConfigInt("Fullscreen", 0, false)
					Spring.SendCommands("fullscreen 0") 
				elseif obj.selected == 3 then
					Spring.SetConfigInt("XResolution", screenX, false)
					Spring.SetConfigInt("YResolution", screenY, false)
					Spring.SetConfigInt("Fullscreen", 1, false)
					Spring.SendCommands("fullscreen 1")
				end
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
		selected = 1,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				local screenX, screenY = Spring.GetScreenGeometry()
				Spring.Echo("screenX, screenY", screenX, screenY)
			
				if obj.selected == 1 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(true)
				elseif obj.selected == 2 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(false, true)
				elseif obj.selected == 3 then
					WG.Chobby.interfaceRoot.SetPanelDisplayMode(false, false)
				end
			end
		},
	}
	
	Label:New {
		x = 40,
		y = 170,
		width = 90,
		height = 45,
		valign = "center",
		align = "right",
		parent = window,
		font = {size = 20},
		caption = "Auto Login:",
	}
	ComboBox:New {
		x = 130,
		y = 170,
		width = 180,
		height = 45,
		parent = window,
		items = {"Always", "On Multiplayer", "Never"},
		selected = 1,
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
		selected = battleStartDisplay,
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				
				battleStartDisplay = obj.selected
			end
		},
	}
	
	freezeSettings = false
	
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local onBattleAboutToStart

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	onBattleAboutToStart = function(listener)
		local screenX, screenY = Spring.GetScreenGeometry()
		
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
	lobby:AddListener("BattleAboutToStart", onBattleAboutToStart)
	WG.LibLobby.lobbySkirmish:AddListener("BattleAboutToStart", onBattleAboutToStart)
	
	WG.SettingsWindow = SettingsWindow
end

function widget:Shutdown()
	lobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
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
