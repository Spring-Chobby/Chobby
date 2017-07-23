--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Commander Loadout",
		desc      = "Displays commanders and modules.",
		author    = "GoogleFrog",
		date      = "9 July 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local TOP_HEIGHT = 200

local function UpdateAllUnlocks()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Intitialize

local function InitializeControls(parentControl)
	local Configuration = WG.Chobby.Configuration
	
	Label:New {
		x = 20,
		right = 5,
		y = 17,
		height = 20,
		font = Configuration:GetFont(3),
		caption = i18n("configure_commander"),
		parent = parentControl
	}
	
	local btnClose = Button:New {
		right = 11,
		y = 7,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				parentControl:Hide()
			end
		},
		parent = parentControl
	}
	
	local informationPanel = ScrollPanel:New {
		x = 12,
		right = 12,
		y = 57,
		height = TOP_HEIGHT,
		horizontalScrollbar = false,
		padding = {4, 4, 4, 4},
		borderColor = {0,0,0,0},
		OnResize = {
			function(self, xSize, ySize)
				if ResizeFunction then
					ResizeFunction(xSize)
				end
			end
		},
		parent = parentControl,
	}
	local loadoutPanel = ScrollPanel:New {
		x = 12,
		right = "51%",
		y = 57 + TOP_HEIGHT + 4,
		bottom = 16,
		horizontalScrollbar = false,
		padding = {4, 4, 4, 4},
		OnResize = {
			function(self, xSize, ySize)
				if ResizeFunction then
					ResizeFunction(xSize)
				end
			end
		},
		parent = parentControl,
	}
	
	local modulesPanel = ScrollPanel:New {
		x = "51%",
		right = 12,
		y = 57 + TOP_HEIGHT + 4,
		bottom = 16,
		horizontalScrollbar = false,
		padding = {4, 4, 4, 4},
		OnResize = {
			function(self, xSize, ySize)
				if ResizeFunction then
					ResizeFunction(xSize)
				end
			end
		},
		parent = parentControl,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CommanderHandler = {}

function CommanderHandler.GetControl()

	local window = Control:New {
		name = "commanderHandler",
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
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

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignData.AddListener("CampaignLoaded", UpdateAllUnlocks)
	WG.CampaignData.AddListener("RewardGained", UpdateAllUnlocks)
	
	WG.CommanderHandler = CommanderHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------