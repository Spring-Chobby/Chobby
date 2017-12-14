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

local friendsInGame, friendsInGameSteamID, hostPort

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
function SteamCoopHandler.GetHostPort()
	return hostPort
end

function SteamCoopHandler.NotifyFriendJoined(steamID, userName)
	friendsInGame = friendsInGame or {}
	friendsInGame[#friendsInGame + 1] = userName
	friendsInGameSteamID[#friendsInGameSteamID + 1] = steamID
	WG.Chobby.InformationPopup((userName or "???") .. " joined your coop game.")
end

function SteamCoopHandler.GetCoopFriendList()
	return friendsInGame
end

function SteamCoopHandler.SteamHostGameSuccess(newHostPort)
	WG.Chobby.InformationPopup("Ready to start coop game.")
	hostPort = newHostPort
end

function SteamCoopHandler.SteamHostGameFailed(steamCaused, reason)
	WG.Chobby.InformationPopup("Coop failed " .. (reason or "???") .. ". " .. (steamCaused or "???"))
	hostPort = nil
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
		
		local players = {}
		for i = 1, #friendsInGame do
			players[i] = {
				SteamID = friendsInGameSteamID[i],
				Name = friendsInGame[i],
				ScriptPassword = "12345",
			}
		end
		
		local args = {
			Players = players,
			Map = mapName,
			Game = gameName,
			Engine = Configuration:GetEngineVersion()
		}
		
		WG.WrapperLoopback.SteamHostGameRequest(args)
		friendsInGameSteamID = nil
		friendsInGame = nil
		hostPort = nil
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
