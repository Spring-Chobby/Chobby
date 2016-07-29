function widget:GetInfo()
	return {
		name    = 'Modoptions Panel',
		desc    = 'Implements the modoptions panel.',
		author  = 'GoogleFrog',
		date    = '29 July 2016',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

local battleLobby
local modoptionDefaults = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Functions

local function InitializeModoptionsDisplay()
	
	local mainScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		horizontalScrollbar = false,
	}
		
	--local mainStackPanel = Control:New {
	--	x = 0,
	--	right = 0,
	--	y = 0,
	--	bottom = 0,
	--	parent = mainScrollPanel,
	--	preserveChildrenOrder = true,
	--}
	--mainStackPanel._relativeBounds.bottom = nil
	
	local lblText = TextBox:New {
		x = 1,
		right = 1,
		y = 1,
		autoresize = true,
		font = WG.Chobby.Configuration:GetFont(1),
		text = "",
		parent = mainScrollPanel,
	}
	
	local function OnSetModOptions(listener, data)
		local modoptions = battleLobby:GetMyBattleModoptions()
		local text = ""
		local empty = true
		for key, value in pairs(modoptions) do
			if modoptionDefaults[key] == nil or modoptionDefaults[key] ~= value then
				text = text .. "\255\120\120\120" .. tostring(key) .. " = \255\255\255\255" .. tostring(value) .. "\n"
				empty = false
			end
		end
		lblText:SetText(text)
		
		if mainScrollPanel.parent then
			if empty and mainScrollPanel.visible then
				mainScrollPanel:Hide()
			end
			if (not empty) and (not mainScrollPanel.visible) then
				mainScrollPanel:Show()
			end
		end
	end
	battleLobby:AddListener("OnSetModOptions", OnSetModOptions)
	
	local externalFunctions = {}
	
	function externalFunctions.Update()
		OnSetModOptions()
	end
	
	function externalFunctions.GetControl()
		return mainScrollPanel
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface
local modoptionsDisplay

local ModoptionsPanel = {}

function ModoptionsPanel.LoadModotpions(gameName, newBattleLobby)
	battleLobby = newBattleLobby

	modoptions = WG.Chobby.Configuration:GetGameConfig(gameName, "ModOptions.lua")
	modoptionDefaults = {}
	if modoptions then
		for i = 1, #modoptions do
			local data = modoptions[i]
			if data.key and data.def ~= nil then
				if type(data.def) == "boolean" then
					modoptionDefaults[data.key] = tostring((data.def and 1) or 0)
				else
					modoptionDefaults[data.key] = tostring(data.def)
				end
			end
		end
	end
end

function ModoptionsPanel.ShowModoptions(gameName)
end

function ModoptionsPanel.GetModoptionsControl()
	if not modoptionsDisplay then
		modoptionsDisplay = InitializeModoptionsDisplay()
	else
		modoptionsDisplay.Update()
	end
	return modoptionsDisplay.GetControl()
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.ModoptionsPanel = ModoptionsPanel
end
