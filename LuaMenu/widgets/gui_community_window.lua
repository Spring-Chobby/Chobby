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

local function GetScroll(window, x, right, y, bottom, verticalScrollbar)
	local holder = Control:New {
		x = x,
		y = y,
		right = right,
		bottom = bottom,
		padding = {2, 2, 2, 2},
		parent = window
	}
	return ScrollPanel:New {
		x = 2,
		right = 2,
		y = 2,
		bottom = 2,
		horizontalScrollbar = false,
		verticalScrollbar = verticalScrollbar,
		padding = {4, 4, 4, 4},
		--borderColor = {0,0,0,0},
		--OnResize = {
		--	function()
		--	end
		--},
		parent = holder
	}
end

local function LeaveIntentionallyBlank(scroll)
	Label:New {
		x = 0,
		y = 12,
		width = 120,
		height = 20,
		align = "left",
		valign = "center",
		font = WG.Chobby.Configuration:GetFont(0),
		caption = "(intentionally blank)",
		parent = scroll
	}
end

local function InitializeControls(window)
	-- Save space
	--Label:New {
	--	x = 15,
	--	y = 11,
	--	width = 180,
	--	height = 30,
	--	parent = window,
	--	font = WG.Chobby.Configuration:GetFont(3),
	--	caption = "Community",
	--}
	
	local newsHolder  = GetScroll(window, 0, 0, 0, "62%", true)
	local leftCenter  = GetScroll(window, 0, "66.6%", "38%", "31%", false)
	local midCenter   = GetScroll(window, "33.4%", "33.4%", "38%", "31%", false)
	local rightCenter = GetScroll(window, "66.6%", 0, "38%", "31%", false)
	local leftLower   = GetScroll(window, 0, "33.4%", "69%", 0, false)
	local rightLower  = GetScroll(window, "66.6%", 0, "69%", 0, false)
	
	LeaveIntentionallyBlank(midCenter)
	LeaveIntentionallyBlank(rightCenter)
	LeaveIntentionallyBlank(leftLower)
	LeaveIntentionallyBlank(rightLower)
	
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
