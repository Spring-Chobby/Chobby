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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables

local friendsInGame, friendsInGameSteamID

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities


--local IterableMap = VFS.Include("LuaRules/Gadgets/Include/IterableMap.lua")

local attemptGameType, attemptScriptTable

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
	if attemptScriptTable then
		WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, attemptScriptTable, friendsInGame, hostPort)
	else
		local myName = WG.Chobby.Configuration:GetPlayerName()
		WG.LibLobby.localLobby:StartBattle(attemptGameType or "skirmish", myName, friendsInGame, true, hostPort)
	end
end

function SteamCoopHandler.SteamHostGameFailed(steamCaused, reason)
	WG.Chobby.InformationPopup("Coop failed " .. (reason or "???") .. ". " .. (steamCaused or "???"))
end

function SteamCoopHandler.SteamConnectSpring(hostIP, hostPort, clientPort, myName, scriptPassword, map, game, engine)
	WG.Chobby.InformationPopup("Starting game in 20s...")
	local function Start()
		WG.LibLobby.localLobby:ConnectToBattle(false, hostIP, hostPort, clientPort, scriptPassword, myName, game, map, engine, "coop")
	end
	WG.Delay(Start, 20)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions: Widget <-> Widget

function SteamCoopHandler.AttemptGameStart(gameType, scriptTable)
	attemptGameType = gameType
	attemptScriptTable = scriptTable
	if not friendsInGame then
		if scriptTable then
			WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, scriptTable)
		else
			WG.LibLobby.localLobby:StartBattle(gameType, WG.Chobby.Configuration:GetPlayerName())
		end
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

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.SteamCoopHandler = SteamCoopHandler
	WG.Delay(DelayedInitialize, 1)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
