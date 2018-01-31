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

local friendsInGame, friendsInGameSteamID

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions: Wrapper

local SteamCoopHandler = {}
function SteamCoopHandler.SteamFriendJoinedMe(steamID, userName)
	friendsInGame = friendsInGame or {}
	friendsInGameSteamID = friendsInGameSteamID or {}
	friendsInGame[#friendsInGame + 1] = userName
	friendsInGameSteamID[#friendsInGameSteamID + 1] = steamID
	WG.Chobby.InformationPopup((userName or "???") .. " joined your coop game.")
end

function SteamCoopHandler.SteamHostGameSuccess(hostPort)
	localLobby:StartBattle("skirmish", friendsInGame, true, hostPort)
end

function SteamCoopHandler.SteamHostGameFailed(steamCaused, reason)
	WG.Chobby.InformationPopup("Coop failed " .. (reason or "???") .. ". " .. (steamCaused or "???"))
end

function SteamCoopHandler.SteamConnectSpring(hostIP, hostPort, clientPort, myName, scriptPassword, map, game, engine)
	localLobby:ConnectToBattle(false, hostIP, hostPort, clientPort, scriptPassword, myName, game, map, engine, "coop")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions: Widget <-> Widget

function SteamCoopHandler.AttemptGameStart()
	if not friendsInGame then
		Spring.Echo("no friends")
		battleLobby:StartBattle("skirmish")
		return
	end
	
	WG.Chobby.InformationPopup("Starting game.")
	
	local players = {}
	local alreadyIn = {}
	for i = 1, #friendsInGame do
		if not alreadyIn[friendsInGameSteamID[i]] then
			players[#players + 1] = {
				SteamID = friendsInGameSteamID[i],
				Name = friendsInGame[i],
				ScriptPassword = "12345",
			}
			alreadyIn[friendsInGameSteamID[i]] = true
		end
	end
	
	local args = {
		Players = players,
		Map = mapName,
		Game = gameName,
		Engine = Spring.Utilities.GetEngineVersion()
	}
	
	WG.WrapperLoopback.SteamHostGameRequest(args)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	localLobby = WG.LibLobby.localLobby
	
	local function OnBattleAboutToStart(_,gameType, gameName, mapName)
		
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
