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
local alreadyIn = {}

local attemptGameType, attemptScriptTable, startReplayFile
local inCoop = false
local friendsReplaceAI = false

local coopPanel, coopHostPanel, closePopup

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function LeaveCoopFunc()
	inCoop = false
end

local function LeaveHostCoopFunc()
	friendsInGame = nil
	friendsInGameSteamID = nil
	alreadyIn = {}
end

local function ResetHostData()
	attemptScriptTable = nil
	startReplayFile = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Top Notification

local function InitializeCoopStatusHandler(name, text, leaveFunc, statusAndInvitesPanel)
	local panelHolder = Panel:New {
		name = name,
		x = 8,
		y = 0,
		right = 0,
		bottom = 0,
		classname = "overlay_panel",
		width = pos and pos.width,
		height = pos and pos.height,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		parent = parent
	}
	
	local rightBound = "50%"
	local bottomBound = 12
	local bigMode = true

	local statusText = TextBox:New {
		x = 22,
		y = 18,
		right = rightBound,
		bottom = bottomBound,
		fontsize = WG.Chobby.Configuration:GetFont(3).size,
		text = text,
		parent = panelHolder,
	}
	
	local button = Button:New {
		name = "leaveCoop",
		x = "70%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = i18n("leave"),
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				leaveFunc()
				statusAndInvitesPanel.RemoveControl(name)
			end
		},
		parent = panelHolder,
	}
	
	local function Resize(obj, xSize, ySize)
		statusText._relativeBounds.right = rightBound
		statusText._relativeBounds.bottom = bottomBound
		statusText:UpdateClientArea()
		if ySize < 60 then
			statusText:SetPos(xSize/4 - 52, 2)
			statusText.font.size = WG.Chobby.Configuration:GetFont(2).size
			statusText:Invalidate()
			bigMode = false
		else
			statusText:SetPos(xSize/4 - 62, 18)
			statusText.font.size = WG.Chobby.Configuration:GetFont(3).size
			statusText:Invalidate()
			bigMode = true
		end
	end
	
	panelHolder.OnResize = {Resize}
	
	local externalFunctions = {}
	
	function externalFunctions.GetHolder()
		return panelHolder
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions: Wrapper

local SteamCoopHandler = {}
function SteamCoopHandler.SteamFriendJoinedMe(steamID, userName)
	if not alreadyIn[steamID] then
		friendsInGame = friendsInGame or {}
		friendsInGameSteamID = friendsInGameSteamID or {}
		
		friendsInGame[#friendsInGame + 1] = userName
		friendsInGameSteamID[#friendsInGameSteamID + 1] = steamID
		alreadyIn[steamID] = true
	end
	
	WG.Chobby.InformationPopup((userName or "???") .. " has joined your P2P party. Play a coop game by starting any game via the Singleplayer menu.")
	
	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()
	coopHostPanel = coopHostPanel or InitializeCoopStatusHandler("coopHostPanel", "Hosting Coop\nParty", LeaveHostCoopFunc, statusAndInvitesPanel)
	statusAndInvitesPanel.RemoveControl("coopPanel")
	statusAndInvitesPanel.AddControl(coopHostPanel.GetHolder(), 4.5)
end

function SteamCoopHandler.SteamJoinFriend(joinFriendID)
	inCoop = true
	local statusAndInvitesPanel = WG.Chobby.interfaceRoot.GetStatusAndInvitesPanel()
	coopPanel = coopPanel or InitializeCoopStatusHandler("coopPanel", "In Coop Party\nWaiting on Host", LeaveCoopFunc, statusAndInvitesPanel)
	statusAndInvitesPanel.RemoveControl("coopHostPanel")
	statusAndInvitesPanel.AddControl(coopPanel.GetHolder(), 4.5)
end

function SteamCoopHandler.SteamHostGameSuccess(hostPort)
	if closePopup then
		closePopup:Close()
	end
	if startReplayFile then
		WG.Chobby.localLobby:StartReplay(startReplayFile, hostPort)
	elseif attemptScriptTable then
		WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, attemptScriptTable, friendsInGame, hostPort)
	else
		local myName = WG.Chobby.Configuration:GetPlayerName()
		WG.LibLobby.localLobby:StartBattle(attemptGameType or "skirmish", myName, friendsInGame, friendsReplaceAI, hostPort)
	end
	ResetHostData()
end

function SteamCoopHandler.SteamHostGameFailed(steamCaused, reason)
	if closePopup then
		closePopup:Close()
	end
	WG.Chobby.InformationPopup("Coop connection failed. " .. (reason or "???") .. ". " .. (steamCaused or "???"))
	ResetHostData()
end

function SteamCoopHandler.SteamConnectSpring(hostIP, hostPort, clientPort, myName, scriptPassword, map, game, engine)
	if not inCoop then
		-- Do not get forced into a coop game if you cancel.
		return
	end
	local function Start()
		WG.LibLobby.localLobby:ConnectToBattle(false, hostIP, hostPort, clientPort, scriptPassword, myName, game, map, engine, "coop")
	end
	if (WG.Chobby.Configuration.coopConnectDelay or 0) > 0 then
		WG.Delay(Start, WG.Chobby.Configuration.coopConnectDelay)
	else
		Start()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions: Widget <-> Widget

function SteamCoopHandler.AttemptGameStart(gameType, scriptTable, newFriendsReplaceAI, newReplayFile)
	attemptGameType = gameType
	attemptScriptTable = scriptTable
	friendsReplaceAI = newFriendsReplaceAI
	startReplayFile = newReplayFile
	
	if not friendsInGame then
		if startReplayFile then
			WG.Chobby.localLobby:StartReplay(startReplayFile)
		elseif scriptTable then
			WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, scriptTable)
		else
			WG.LibLobby.localLobby:StartBattle(gameType, WG.Chobby.Configuration:GetPlayerName())
		end
		return
	end
	
	local players = {}
	for i = 1, #friendsInGame do
		players[#players + 1] = {
			SteamID = friendsInGameSteamID[i],
			Name = friendsInGame[i],
			ScriptPassword = "12345",
		}
	end
	
	closePopup = WG.Chobby.InformationPopup("Starting game.")
	
	local args = {
		Players = players,
		--Map = mapName,
		--Game = gameName,
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
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
