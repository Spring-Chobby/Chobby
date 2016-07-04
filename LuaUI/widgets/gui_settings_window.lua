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
	
	local freezeSettings = true
	
	ComboBox:New {
		x = 20,
		y = 20,
		width = 180,
		height = 55,
		items = {"Windowed Fullscreen", "Windowed", "Fullscreen"},
		selected = 1,
		OnSelect = {
			function (self)
				if freezeSettings then
					return
				end
				
				local screenX, screenY = Spring.GetScreenGeometry()
				Spring.Echo("screenX, screenY", screenX, screenY)
			
				if self.selected == 1 then
					--Spring.SetConfigInt("Fullscreen", 0, false)
					Spring.SetConfigInt("XResolution", screenX, false)
					Spring.SetConfigInt("YResolution", screenY, false)
					Spring.SetConfigInt("XResolutionWindowed", screenX, false)
					Spring.SetConfigInt("YResolutionWindowed", screenY, false)
					Spring.SetConfigInt("WindowPosX", 0, false)
					Spring.SetConfigInt("WindowPosY", 0, false)
					Spring.SetConfigInt("XResolution", screenX, false)
					Spring.SetConfigInt("YResolution", screenY, false)
					Spring.SendCommands("fullscreen 0") 
					Spring.SetConfigInt("WindowBorderless", 1, false)
					Spring.SetConfigInt("WindowBorderless", 1, false)
					Spring.SetConfigInt("XResolution", screenX, false)
					Spring.SetConfigInt("YResolution", screenY, false)
				elseif self.selected == 2 then
					Spring.SetConfigInt("WindowPosX", screenX/4, false)
					Spring.SetConfigInt("WindowPosY", screenY/8, false)
					Spring.SetConfigInt("XResolutionWindowed", screenX/2, false)
					Spring.SetConfigInt("YResolutionWindowed", screenY*3/4, false)
					Spring.SetConfigInt("WindowBorderless", 0, false)
					Spring.SetConfigInt("WindowBorderless", 0, false)
					Spring.SetConfigInt("Fullscreen", 0, false)
					Spring.SendCommands("fullscreen 0") 
					Spring.SetConfigInt("WindowPosX", screenX/4, false)
					Spring.SetConfigInt("WindowPosY", screenY/8, false)
					Spring.SetConfigInt("XResolutionWindowed", screenX/2, false)
					Spring.SetConfigInt("YResolutionWindowed", screenY*3/4, false)
				elseif self.selected == 3 then
					Spring.SetConfigInt("XResolution", screenX, false)
					Spring.SetConfigInt("YResolution", screenY, false)
					Spring.SetConfigInt("Fullscreen", 1, false)
					Spring.SendCommands("fullscreen 1") 
					Spring.SetConfigInt("WindowBorderless", 0, false)
				end
			end
		},
		parent = window,
	}
	
	freezeSettings = false
	
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.SettingsWindow = SettingsWindow
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
