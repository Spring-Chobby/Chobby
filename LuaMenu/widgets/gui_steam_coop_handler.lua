--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Steam Coop Handler",
		desc      = "Handles direct steam cooperative game connections.",
		author    = "GoogleFrog",
		date      = "25 February 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local friendsInGame = {}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local SteamCoopHandler = {}

function SteamCoopHandler.InviteLichoToGame()
	WG.WrapperLoopback.SteamInviteFriendToGame("76561197962341674") 
end

function SteamCoopHandler.NotifyFriendJoined(steamID, userName)
	friendsInGame[#friendsInGame + 1] = userName
	WG.Chobby.InformationPopup((userName or "???") .. " joined your coop game.")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function DelayedInitialize()
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
