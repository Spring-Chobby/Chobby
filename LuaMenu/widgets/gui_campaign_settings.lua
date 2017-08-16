--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Settings",
		desc      = "UI for managing campaign settings",
		author    = "GoogleFrog",
		date      = "21 April 2017",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local Configuration

local ITEM_OFFSET = 38

local COMBO_X = 230
local COMBO_WIDTH = 235
local CHECK_WIDTH = 230
local TEXT_OFFSET = 6

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(parent)
	Configuration = WG.Chobby.Configuration

	local offset = 5
	local freezeSettings = true
	
	Label:New {
		x = 20,
		y = offset + TEXT_OFFSET,
		width = 90,
		height = 30,
		valign = "top",
		align = "left",
		font = Configuration:GetFont(2),
		caption = "Difficulty",
		parent = parent,
	}
	local comboDifficulty = ComboBox:New {
		x = COMBO_X,
		y = offset,
		width = COMBO_WIDTH,
		height = 30,
		items = {"Normal", "Hard", "Brutal", "Insane"},
		font = Configuration:GetFont(2),
		itemFontSize = Configuration:GetFont(2).size,
		selected = WG.CampaignData.GetDifficultySetting(),
		OnSelect = {
			function (obj)
				if freezeSettings then
					return
				end
				WG.CampaignData.SetDifficultySetting(obj.selected)
			end
		},
		parent = parent,
	}
	offset = offset + ITEM_OFFSET
	
	local function UpdateSettings()
		freezeSettings = true
		comboDifficulty:Select(WG.CampaignData.GetDifficultySetting())
		freezeSettings = false
	end
	WG.CampaignData.AddListener("CampaignSettingsUpdate", UpdateSettings)
	WG.CampaignData.AddListener("CampaignLoaded", UpdateSettings)
	
	freezeSettings = false
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CampaignSettingsWindow = {}

function CampaignSettingsWindow.GetControl()
	local window = Control:New {
		name = "campaignSettingsHandler",
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
-- callins
--------------------------------------------------------------------------------

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.CampaignSettingsWindow = CampaignSettingsWindow
end

