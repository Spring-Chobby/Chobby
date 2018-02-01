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

local friendsInGame, saneFriendsInGame, friendsInGameSteamID
local alreadyIn = {}

local attemptGameType, attemptScriptTable, startReplayFile
local inCoop = false
local friendsReplaceAI = false
local doDelayedConnection = true

local coopPanel, coopHostPanel, replacablePopup

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function LeaveCoopFunc()
	inCoop = false
end

local function LeaveHostCoopFunc()
	friendsInGame = nil
	saneFriendsInGame = nil
	friendsInGameSteamID = nil
	alreadyIn = {}
end

local function ResetHostData()
	attemptScriptTable = nil
	startReplayFile = nil
end

local function MakeExclusivePopup(text, buttonText, ClickFunc)
	if replacablePopup then
		replacablePopup:Close()
	end
	replacablePopup = WG.Chobby.InformationPopup(text, nil, nil, nil, buttonText, nil, ClickFunc)
end

local function CloseExclusivePopup()
	if replacablePopup then
		replacablePopup:Close()
		replacablePopup = nil
	end
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
		saneFriendsInGame = saneFriendsInGame or {}
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
	CloseExclusivePopup()
	local myName = WG.Chobby.Configuration:GetPlayerName()
	if startReplayFile then
		WG.Chobby.localLobby:StartReplay(startReplayFile, myName, hostPort)
	elseif attemptScriptTable then
		WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, attemptScriptTable, saneFriendsInGame, hostPort)
	else
		WG.LibLobby.localLobby:StartBattle(attemptGameType or "skirmish", myName, saneFriendsInGame, friendsReplaceAI, hostPort)
	end
	ResetHostData()
end

function SteamCoopHandler.SteamHostGameFailed(steamCaused, reason)
	MakeExclusivePopup("Coop connection failed. " .. (reason or "???") .. ". " .. (steamCaused or "???"))
	ResetHostData()
end

function SteamCoopHandler.SteamConnectSpring(hostIP, hostPort, clientPort, myName, scriptPassword, map, game, engine)
	if not inCoop then
		-- Do not get forced into a coop game if you have left the coop party.
		return
	end
	doDelayedConnection = true
	local function Start()
		if doDelayedConnection then
			doDelayedConnection = false
			WG.LibLobby.localLobby:ConnectToBattle(false, hostIP, hostPort, clientPort, scriptPassword, myName, game, map, engine, "coop")
		end
	end
	local function StartAndClose()
		CloseExclusivePopup()
		Start()
	end
	MakeExclusivePopup("Starting coop game.", "Force", Start)
	if (WG.Chobby.Configuration.coopConnectDelay or 0) > 0 then
		WG.Delay(StartAndClose, WG.Chobby.Configuration.coopConnectDelay)
	else
		StartAndClose()
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
	
	local Configuration = WG.Chobby.Configuration
	
	if not friendsInGame then
		if startReplayFile then
			local myName = Configuration:GetPlayerName()
			WG.Chobby.localLobby:StartReplay(startReplayFile, myName)
		elseif scriptTable then
			WG.LibLobby.localLobby:StartGameFromLuaScript(gameType, scriptTable)
		else
			WG.LibLobby.localLobby:StartBattle(gameType, Configuration:GetPlayerName())
		end
		return
	end
	
	local usedNames = {
		[myName] = true,
	}
	
	MakeExclusivePopup("Starting game.")
	
	local appendName = ""
	if startReplayFile then
		appendName = "(spec)"
	end
	
	local players = {}
	for i = 1, #friendsInGame do
		saneFriendsInGame[i] = Configuration:SanitizeName(friendsInGame[i], usedNames) .. appendName
		players[#players + 1] = {
			SteamID = friendsInGameSteamID[i],
			Name = saneFriendsInGame[i],
			ScriptPassword = "12345",
		}
	end
	
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
