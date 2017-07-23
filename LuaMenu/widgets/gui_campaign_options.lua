--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Options Window",
		desc      = "Stuff",
		author    = "GoogleFrog, KingRaptor",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

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

local function RefreshControls(window)
	WG.CampaignSaveWindow.PopulateSaveList()
end

local function InitializeControls(window)
	window.OnParent = nil
	
	local btnClose = Button:New {
		right = 11,
		y = 7,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				window:Hide()
			end
		},
		parent = window
	}
	
	local tabs = {
		MakeTab("Save/Load", {WG.CampaignSaveWindow.GetControl()}),
		MakeTab("Settings", {WG.CampaignSettingsWindow.GetControl()}),
	}
	
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
		right = 90,
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

local CampaignOptionsWindow = {}

function CampaignOptionsWindow.GetControl()

	local window = Control:New {
		name = "campaignOptionsWindow",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		OnParentPost = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				else
					RefreshControls(obj)
				end
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.CampaignOptionsWindow = CampaignOptionsWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------