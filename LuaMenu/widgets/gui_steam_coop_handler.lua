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
-- Globals

local localLobby

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local friendsInGame

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

function SteamCoopHandler.InviteGoogleFrogToGame()
	WG.WrapperLoopback.SteamInviteFriendToGame("76561198005614529") 
end

function SteamCoopHandler.NotifyFriendJoined(steamID, userName)
	friendsInGame = friendsInGame or {}
	friendsInGame[#friendsInGame + 1] = userName
	WG.Chobby.InformationPopup((userName or "???") .. " joined your coop game.")
end

function SteamCoopHandler.GetCoopFriendList()
	return friendsInGame
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	localLobby = WG.LibLobby.localLobby
	
	local function OnBattleAboutToStart(gameName, mapName, myName)
		if not friendsInGame then
			return
		end
		
		local args = {
			SteamHostPlayerEntry = {
				SteamID = Configuration.mySteamID,
				Name = userName,
				ScriptPassword = "12345",
			},
			SteamHostPlayerEntry = friendsInGame,
			Map = mapName,
			Game = gameName,
			Engine = Configuration:GetEngineVersion()
		}
		
		WG.WrapperLoopback.SteamHostGameRequest(args)
		friendsInGame = nil
	end
	localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.SteamCoopHandler = SteamCoopHandler
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
