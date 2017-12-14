--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Community Window",
		desc      = "Handles community news and links.",
		author    = "GoogleFrog",
		date      = "14 December 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	Label:New {
		x = 15,
		y = 11,
		width = 180,
		height = 30,
		parent = window,
		font = WG.Chobby.Configuration:GetFont(3),
		caption = "Community",
	}
	
	-------------------------
	-- Download List
	-------------------------
	
	local mainHolder = Control:New {
		x = 12,
		right = 15,
		y = 52,
		bottom = 15,
		parent = window,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local CommunityWindow = {}

function CommunityWindow.GetControl()

	local window = Control:New {
		name = "communityHandler",
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

local function DelayedInitialize()
	
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.Delay(DelayedInitialize, 1)

	WG.CommunityWindow = CommunityWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
