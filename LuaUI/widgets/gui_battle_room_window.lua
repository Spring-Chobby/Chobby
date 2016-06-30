--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Battle Room Window",
		desc      = "Battle Room Window handler.",
		author    = "GoogleFrog",
		date      = "30 June 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local variables

-- Chili controls
local lblBattleTitle
local lblNumberOfPlayers
local line
local btnQuitBattle
local lblHaveGame
local lblHaveMap
local btnStartBattle
local window
local chatPanel

-- Specialized UI objects
local battleRoomConsole
local userListPanel

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Helper functions

local function UpdatePlayers(battleID)
	local battle = lobby:GetBattle(battleID)
	lblNumberOfPlayers:SetCaption(i18n("players") .. ": " .. tostring(#battle.users) .. "/" .. tostring(battle.maxPlayers))
end

local function GenerateScriptTxt(battleID)
	local battle = lobby:GetBattle(battleID)
	local scriptTxt = 
[[
[GAME]
{
	HostIP=__IP__;
	HostPort=__PORT__;
	IsHost=0;
	MyPlayerName=__MY_PLAYER_NAME__;
	MyPasswd=__MY_PASSWD__;
}
]]

	scriptTxt = scriptTxt:gsub("__IP__", battle.ip)
						:gsub("__PORT__", battle.port)
						:gsub("__MY_PLAYER_NAME__", lobby:GetMyUserName())
						:gsub("__MY_PASSWD__", lobby:GetScriptPassword())
	return scriptTxt
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Chili/interface management

local function InitializeControls(battleID)
	local battle = lobby:GetBattle(battleID)

	lblBattleTitle = Label:New {
		x = 15,
		y = 5,
		width = 200,
		height = 30,
		font = { size = 20 },
		caption = i18n("battle") .. ": " .. tostring(battle.title),
	}

	lblNumberOfPlayers = Label:New {
		x = 15,
		y = 35,
		width = 200,
		height = 30,
		caption = "",
	}

	line = Line:New {
		x = 0,
		y = 55,
		width = 300,
	}

	btnQuitBattle = Button:New {
		right = 10,
		y = 0,
		width = 60,
		height = 35,
		caption = WG.Chobby.Configuration:GetErrorColor() .. i18n("quit") .. "\b",
		OnClick = {
			function()
				lobby:LeaveBattle()
			end
		},
	}

	lblHaveGame = Label:New {
		right = 10,
		y = 45,
		width = 60,
		height = 35,
		caption = i18n("dont_have_game") .. " [" .. WG.Chobby.Configuration:GetErrorColor() .. "?\b]",
	}
	if VFS.HasArchive(battle.gameName) then
		lblHaveGame.caption = i18n("have_game") .. " [" .. WG.Chobby.Configuration:GetSuccessColor() .. "?\b]"
	end

	lblHaveMap = Label:New {
		right = 10,
		y = 85,
		width = 60,
		height = 35,
		caption = i18n("dont_have_map") .. " [" .. WG.Chobby.Configuration:GetErrorColor() .. "?\b]",
	}
	if VFS.HasArchive(battle.mapName) then
		lblHaveMap.caption = i18n("have_map") .. " [" .. WG.Chobby.Configuration:GetSuccessColor() .. "?\b]"
	end

	btnStartBattle = Button:New {
		x = 10,
		y = 80,
		width = 110,
		height = 55,
		caption = "\255\66\138\201" .. i18n("start") ..  "\b",
		font = { size = 22 },
		OnClick = {
			function()
				lobby:SayBattle("!start")
			end
		},
	}

	btnSpectate = Button:New {
		x = 160,
		y = 80,
		width = 110,
		height = 55,
		caption = "\255\66\138\201" .. i18n("spectate") ..  "\b",
		font = { size = 22 },
		OnClick = {
			function()
				lobby:SetBattleStatus({IsSpectator = not lobby:GetMyIsSpectator()})
			end
		},
	}
	
	battleRoomConsole = WG.Chobby.Console()
	battleRoomConsole.listener = function(message)
		lobby:SayBattle(message)
	end
	userListPanel = WG.Chobby.UserListPanel(battleID)
	local chatPanel = Control:New {
		x = 5,
		y = 140,
		bottom = 5,
		right = 5,
		padding = {0, 0, 0, 0},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {
			Control:New {
				x = 0, y = 0, right = 145, bottom = 0,
				padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
				children = { battleRoomConsole.panel, },
			},
			Control:New {
				width = 144, y = 0, right = 0, bottom = 0,
				padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
				children = { userListPanel.panel, },
			},
		}
	}

	local onSaidBattle = function(listener, userName, message)
		battleRoomConsole:AddMessage(userName .. ": " .. message)
	end
	lobby:AddListener("OnSaidBattle", onSaidBattle)

	local onSaidBattleEx = function(listener, userName, message)
		battleRoomConsole:AddMessage("\255\0\139\139" .. userName .. " " .. message .. "\b")		
	end
	lobby:AddListener("OnSaidBattleEx", onSaidBattleEx)

	local onBattleClosed = function(listener, closedBattleID, ... )
		if battleID == closedBattleID then
			window:Dispose()
		end
	end
	lobby:AddListener("OnBattleClosed", onBattleClosed)

	local onLeftBattle = function(listener, leftBattleID, userName)
		if battleID ~= leftBattleID then
			return
		end
		if lobby:GetMyUserName() == userName then
			window:Dispose()
		else
			UpdatePlayers(battleID)
		end
	end
	lobby:AddListener("OnLeftBattle", onLeftBattle)

	local onJoinedBattle = function(listener, joinedBattleId, userName)
		if battleID ~= joinedBattleId then
			return
		end
		UpdatePlayers(battleID)
	end
	lobby:AddListener("OnJoinedBattle", onJoinedBattle)

	-- TODO: implement this as a part of the lobby protocol
	local onClientStatus = function(listener, userName, status)
		-- game started
		if userName == battle.founder and math.bit_and(1, status) then
			Spring.Echo("Game starts!")
			local battle = lobby:GetBattle(battleID)
			local springURL = "spring://" .. lobby:GetMyUserName() .. ":" .. lobby:GetScriptPassword() .. "@" .. battle.ip .. ":" .. battle.port
			Spring.Echo(springURL)
			Spring.Start(springURL, "")
			--local scriptFileName = "scriptFile.txt"
			--local scriptFile = io.open(scriptFileName, "w")
			--local scriptTxt = GenerateScriptTxt(battleID)
			--Spring.Echo(scriptTxt)
			--scriptFile:write(scriptTxt)
			--scriptFile:close()
			--Spring.Restart(scriptFileName, "")
			--Spring.Restart("", scriptTxt)
		end
	end
	lobby:AddListener("OnClientStatus", onClientStatus)

	UpdatePlayers(battleID)
	window = Window:New {
		x = 600,
		width = 600,
		y = 550,
		height = 450,
		parent = screen0,
		resizable = false,
		padding = {0, 20, 0, 0},
		children = {
			lblBattleTitle,
			lblNumberOfPlayers,
			btnQuitBattle,
			lblHaveGame,
			lblHaveMap,
			btnStartBattle,
			btnSpectate,
			line,
			chatPanel,
		},
		OnDispose = { 
			function()
				lobby:RemoveListener("OnBattleClosed", onBattleClosed)
				lobby:RemoveListener("OnLeftBattle", onLeftBattle)
				lobby:RemoveListener("OnJoinedBattle", onJoinedBattle)
				lobby:RemoveListener("OnSaidBattle", onSaidBattle)
				lobby:RemoveListener("OnSaidBattleEx", onSaidBattleEx)
				lobby:RemoveListener("OnClientStatus", onClientStatus)
			end
		},
	}

	lobby:SetBattleStatus({
		AllyNumber = 0, 
		TeamNumber = 0,
		IsSpectator = false,  
		Sync = 1, -- 0 = unknown, 1 = synced, 2 = unsynced
	})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local BattleRoomWindow = {}

function BattleRoomWindow.ShowBattleRoom(battleID)
	InitializeControls(battleID)
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.BattleRoomWindow = BattleRoomWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------