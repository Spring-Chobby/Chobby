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
	
	ComboBox:New {
		x = 20,
		y = 20,
		width = 180,
		height = 55,
		items = {"Windowed Fullscreen", "Windowed", "Fullscreen"},
		selected = 1,
		OnSelect = {
			function (self)
				if self.selected == 1 then
					Spring.SetConfigInt("Fullscreen", 0, false)
					Spring.SetConfigInt("WindowBorderless", 1, false)
					Spring.SetConfigInt("WindowPosX", 0, false)
					Spring.SetConfigInt("WindowPosY", 0, false)
				elseif self.selected == 2 then
					Spring.SetConfigInt("Fullscreen", 0, false)
					Spring.SetConfigInt("WindowBorderless", 0, false)
				elseif self.selected == 3 then
					Spring.SetConfigInt("Fullscreen", 1, false)
					Spring.SetConfigInt("WindowBorderless", 0, false)
				end
			end
		},
		parent = window,
	}
	
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
