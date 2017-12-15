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
-- Vars 

local globalSizeMode = 2

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Controls

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

local function LeaveIntentionallyBlank(scroll, caption)
	Label:New {
		x = 12,
		y = 10,
		width = 120,
		height = 20,
		align = "left",
		valign = "tp",
		font = WG.Chobby.Configuration:GetFont(1),
		caption = caption,
		parent = scroll
	}
end

local function AddLinkButton(scroll, name, link, x, right, y, bottom)
	local button = Button:New {
		x = x,
		y = y,
		right = right,
		bottom = bottom,
		caption = name,
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl(link)
			end
		},
		OnResize = {
			function(obj, xSize, ySize)
				if globalSizeMode == 2 then
					ButtonUtilities.SetFontSizeScale(obj, 4)
				else
					ButtonUtilities.SetFontSizeScale(obj, 3)
				end
			end
		},
		parent = scroll,
	}
	ButtonUtilities.SetFontSizeScale(button, 3)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

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
	
	LeaveIntentionallyBlank(midCenter, "Forum activity")
	LeaveIntentionallyBlank(rightCenter, "Ladder")
	LeaveIntentionallyBlank(leftLower, "Profile")
	LeaveIntentionallyBlank(rightLower, "(reserved)")
	
	AddLinkButton(leftCenter, "Discord", "https://discord.gg/aab63Vt", 0, 0, 0, "75%")
	AddLinkButton(leftCenter, "Forums",  "http://zero-k.info/Forum",   0, 0, "25%", "50%")
	AddLinkButton(leftCenter, "Manual",  "http://zero-k.info/mediawiki/index.php?title=Manual", 0, 0, "50%", "25%")
	AddLinkButton(leftCenter, "Replays", "http://zero-k.info/Battles", 0, 0, "75%", 0)
	
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
		OnResize = {
			function(obj, xSize, ySize)
				if ySize < 680 then
					globalSizeMode = 1
				else
					globalSizeMode = 2
				end
			end
		}
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
