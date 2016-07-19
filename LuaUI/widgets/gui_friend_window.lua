--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Friend Window",
		desc      = "Handles friends.",
		author    = "GoogleFrog",
		date      = "19 July 2016",
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


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	Label:New {
		x = 40,
		y = 40,
		width = 180,
		height = 30,
		parent = window,
		font = WG.Chobby.Configuration:GetFont(4),
		caption = "Friends",
	}
	
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local FriendWindow = {}

function FriendWindow.GetControl()
	
	local window = Control:New {
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
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.Delay(DelayedInitialize, 1)
	
	WG.FriendWindow = FriendWindow
end

function widget:Shutdown()
	if WG.LibLobby then
		-- RemoveListener
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
