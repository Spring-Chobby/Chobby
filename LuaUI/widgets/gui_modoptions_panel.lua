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
local modoptionStructure = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Functions

local function ProcessListOption(data, index)
	return Label:New {
		x = 10,
		y = index*30,
		caption = data.name,
	}
end

local function ProcessBoolOption(data, index)
	return Label:New {
		x = 10,
		y = index*30,
		caption = data.name,
	}
end

local function ProcessNumberOption(data, index)
	return Label:New {
		x = 10,
		y = index*30,
		caption = data.name,
	}
end

local function ProcessStringOption(data, index)
	return Label:New {
		x = 10,
		y = index*30,
		caption = data.name,
	}
end

local function PopulateTab(options)	
	-- list = combobox
	-- bool = tickbox
	-- number = sliderbar (with label)
	-- string = editBox
	local children = {}
	for i = 1, #options do
		local data = options[i]
		if data.type == "list" then
			children[#children + 1] = ProcessListOption(data, #children)
		elseif data.type == "bool" then
			children[#children + 1] = ProcessBoolOption(data, #children)
		elseif data.type == "number" then
			children[#children + 1] = ProcessNumberOption(data, #children)
		elseif data.type == "string" then
			children[#children + 1] = ProcessStringOption(data, #children)
		end
	end
	return children
end

local function CreateModoptionWindow()
	local modoptionsSelectionWindow = Window:New {
		caption = "",
		name = "modoptionsSelectionWindow",
		parent = screen0,
		width = 720,
		height = 500,
		resizable = false,
		draggable = false,
		classname = "overlay_window",
	}
	
	local tabs = {}
	
	for key, data in pairs(modoptionStructure) do
		tabs[#tabs + 1] = {
			name = key,
			caption = data.title,
			children = PopulateTab(data.options)
		}
	end
	Spring.Utilities.TableEcho(tabs, "tabstabstabstabstabstabstabstabstabstabstabstabs")

			
	local tabPanel = Chili.DetachableTabPanel:New {
		x = 5, 
		right = 5,
		y = 45, 
		bottom = 85,
		padding = {0, 0, 0, 0},
		minTabWidth = 85,
		tabs = tabs,
		parent = modoptionsSelectionWindow,
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
		padding = {0, 5, 0, 0},
		parent = modoptionsSelectionWindow,
		children = {
			tabPanel.tabBar
		}
	}
	local function CancelFunc()
		modoptionsSelectionWindow:Dispose()
	end
	
	local function AcceptFunc()
	
	end
	
	local buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("apply"),
		font = WG.Chobby.Configuration:GetFont(3),
		parent = modoptionsSelectionWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}
	
	local buttonCancel = Button:New {
		right = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("cancel"),
		font = WG.Chobby.Configuration:GetFont(3),
		parent = modoptionsSelectionWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CancelFunc()
			end
		},
	}
	
	local popupHolder = WG.Chobby.PriorityPopup(modoptionsSelectionWindow, CancelFunc, AcceptFunc)
end

local function InitializeModoptionsDisplay()
	
	local mainScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		horizontalScrollbar = false,
	}
	
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
	modoptionStructure = {}
	if not modoptions then
		return
	end
	
	-- Set modoptionDefaults
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
	
	-- Populate the sections
	for i = 1, #modoptions do
		local data = modoptions[i]
		if data.type ~= "section" and data.section then
			modoptionStructure[data.section] = modoptionStructure[data.section] or {
				title = data.section,
				options = {}
			}
			
			local options = modoptionStructure[data.section].options
			options[#options + 1] = data
		end
	end
end

function ModoptionsPanel.ShowModoptions()
	CreateModoptionWindow()
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
