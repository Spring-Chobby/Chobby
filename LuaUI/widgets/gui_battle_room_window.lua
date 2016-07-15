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
local window
local lblHaveMap, lblHaveGame

-- Function which is called to fix scroll panel sizes
local ViewResizeUpdate

-- Listeners, needed here so they can be deregistered
local onBattleClosed
local onLeftBattle_counter
local onJoinedBattle
local onSaidBattle
local onSaidBattleEx
local onUpdateUserTeamStatus
local onUpdateUserTeamStatusSelf
local onLeftBattle
local onRemoveAi

-- Globals
local battleLobby
local wrapperControl
local parentTabPanel

local singleplayerWrapper
local multiplayerWrapper

local singleplayerGame = "Chobby $VERSION"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Download management

local emptyTeamIndex = 0

local function UpdateArchiveStatus()
	if not battleLobby:GetMyBattleID() then
		return
	end
	local battle = battleLobby:GetBattle(battleLobby:GetMyBattleID())
	if not battle then
		return
	end
	if VFS.HasArchive(battle.gameName) then
		lblHaveGame:SetCaption(i18n("have_game") .. " [" .. WG.Chobby.Configuration:GetSuccessColor() .. "✔\b]")
	else
		lblHaveGame:SetCaption(i18n("dont_have_game") .. " [" .. WG.Chobby.Configuration:GetErrorColor() .. "✘\b]")
	end
	if VFS.HasArchive(battle.mapName) then
		lblHaveMap:SetCaption(i18n("have_map") .. " [" .. WG.Chobby.Configuration:GetSuccessColor() .. "✔\b]")
	else
		lblHaveMap:SetCaption(i18n("dont_have_map") .. " [" .. WG.Chobby.Configuration:GetErrorColor() .. "✘\b]")
	end
end

local function MaybeDownloadArchive(archiveName, archiveType)
	if not VFS.HasArchive(archiveName) then
		VFS.DownloadArchive(archiveName, archiveType)
	end
end

local function MaybeDownloadGame(battle)
	MaybeDownloadArchive(battle.gameName, "game")
end

local function MaybeDownloadMap(battle)
	MaybeDownloadArchive(battle.mapName, "map")
end

function widget:DownloadFinished()
	UpdateArchiveStatus()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Chili/interface management

local function SetupInfoButtonsPanel(leftInfo, rightInfo, battle, battleID, myUserName)

	local lblMapName = Label:New {
		x = 15,
		bottom = 110,
		height = 20,
		font = WG.Chobby.Configuration:GetFont(2),
		caption = battle.mapName,
		parent = rightInfo,
	}

	local minimap = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 135,
		parent = rightInfo,
	}
	
	local downloader = WG.Chobby.Downloader({
		x = 0,
		right = 0,
		bottom = 55,
		height = 60,
		parent = leftInfo,
	})
	downloader:Hide()

	local btnStartBattle = Button:New {
		x = 0,
		bottom = 0,
		right = 0,
		height = 50,
		caption = "\255\66\138\201" .. i18n("start") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function()
				if battle.isRunning then
					battleLobby:ConnectToBattle()
				else
					battleLobby:StartBattle()
				end
			end
		},
		parent = rightInfo,
	}
	
	local btnPlay
	local btnSpectate = Button:New {
		x = "50%",
		right = 0,
		bottom = 50,
		height = 50,
		caption = "\255\66\138\201" .. i18n("watch") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function(obj)
				battleLobby:SetBattleStatus({isSpectator = true})
				WG.ButtonUtilities.SetButtonDeselected(btnPlay)
				WG.ButtonUtilities.SetButtonSelected(obj)
			end
		},
		parent = rightInfo,
	}
	
	btnPlay = Button:New {
		x = 0,
		right = "50%",
		bottom = 50,
		height = 50,
		caption = "\255\66\138\201" .. i18n("play") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function(obj)
				battleLobby:SetBattleStatus({isSpectator = false})
				WG.ButtonUtilities.SetButtonDeselected(btnSpectate)
				WG.ButtonUtilities.SetButtonSelected(obj)
			end
		},
		parent = rightInfo,
	}
	
	local btnPickMap = Button:New {
		x = 0,
		y = 90,
		height = 45,
		right = 0,
		caption = "\255\66\138\201" .. i18n("pick_map") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function()
				WG.Chobby.MapListWindow(battleLobby)
			end
		},
		parent = leftInfo,
	}

	local lblNumberOfPlayers = Label:New {
		x = 0,
		y = 15,
		width = 200,
		height = 30,
		caption = "",
		parent = leftInfo,
	}
	
	lblHaveGame = Label:New {
		x = 0,
		y = 35,
		caption = "",
		parent = leftInfo,
	}

	lblHaveMap = Label:New {
		x = 0,
		y = 55,
		caption = "",
		parent = leftInfo,
	}
	
	onUpdateUserTeamStatusSelf = function(listener, userName, allyNumber, isSpectator)
		if userName == myUserName then
			if isSpectator then
				WG.ButtonUtilities.SetButtonDeselected(btnPlay)
				WG.ButtonUtilities.SetButtonSelected(btnSpectate)
			else
				WG.ButtonUtilities.SetButtonDeselected(btnSpectate)
				WG.ButtonUtilities.SetButtonSelected(btnPlay)
			end
		end
	end
	battleLobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
	
	onBattleIngameUpdate = function(listener, updatedBattleID, isRunning)
		if battleID == updatedBattleID then
			if isRunning then
				btnStartBattle:SetCaption("\255\66\138\201" .. i18n("rejoin") ..  "\b")
			else
				btnStartBattle:SetCaption("\255\66\138\201" .. i18n("start") ..  "\b")
			end
		end
	end
	battleLobby:AddListener("OnBattleIngameUpdate", onBattleIngameUpdate)
	
	onBattleIngameUpdate(nil, battleID, battle.isRunning)
	
	onUpdateBattleInfo = function(listener, updatedBattleID, spectatorCount, locked, mapHash, mapName)
		if battleID ~= updatedBattleID then
			return
		end
		if mapName then
			lblMapName:SetCaption(mapName)
			-- TODO: Bit lazy here, seeing as we only need to update the map
			UpdateArchiveStatus()
			MaybeDownloadMap(battle)
		end
	end
	battleLobby:AddListener("OnUpdateBattleInfo", onUpdateBattleInfo)
	
	local UpdatePlayers = function(battleID)
		lblNumberOfPlayers:SetCaption(i18n("players") .. ": " .. tostring(#battle.users) .. "/" .. tostring(battle.maxPlayers))
	end
	
	onLeftBattle_counter = function(listener, leftBattleID, userName)
		if battleID ~= leftBattleID then
			return
		end
		if battleLobby:GetMyUserName() == userName then
			window:Dispose()
			if wrapperControl and wrapperControl.visible and wrapperControl.parent then
				wrapperControl:Hide()
			end
		else
			UpdatePlayers(battleID)
		end
	end
	battleLobby:AddListener("OnLeftBattle", onLeftBattle_counter)

	onJoinedBattle = function(listener, joinedBattleId, userName)
		if battleID ~= joinedBattleId then
			return
		end
		UpdatePlayers(battleID)
	end
	battleLobby:AddListener("OnJoinedBattle", onJoinedBattle)
	
	UpdatePlayers(battleID)

	MaybeDownloadGame(battle)
	MaybeDownloadMap(battle)
	UpdateArchiveStatus()
end

local function AddTeamButtons(parent, offX, offY, joinFunc, aiFunc)
	local joinTeamButton = Button:New {
		x = offX,
		y = offY,
		height = 30,
		width = 75,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = i18n("join") .. "\b",
		OnClick = {joinFunc},
		parent = parent,
	}
	local addAiButton = Button:New {
		x = offX + 85,
		y = offY,
		height = 30,
		width = 75,
		font = {size = 20},
		caption = i18n("add_ai") .. "\b",
		OnClick = {aiFunc},
		parent = parent,
	}
end

local function SetupPlayerPanel(playerParent, spectatorParent, battle, battleID)
	
	local SPACING = 22
	local NEW_TEAM_SPACING = 50
		
	local mainScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = NEW_TEAM_SPACING,
		parent = playerParent,
		borderColor = {0,0,0,0},
	}
	
	local IMAGE_BLANK = "luaui/images/blank.png"
	local mainStackPanel = Panel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = mainScrollPanel,
		preserveChildrenOrder = true,
		borderColor = {0,0,0,0},
		backgroundColor = {0.2, 0.2, 0.2, 0.2},
		TileImageBK = IMAGE_BLANK,
	}	
	mainStackPanel._relativeBounds.bottom = nil
	local spectatorScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = spectatorParent,
		borderColor = {0,0,0,0},
	}
		
	local spectatorStackPanel = Panel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = spectatorScrollPanel,
		borderColor = {0,0,0,0},
		backgroundColor = {0.2, 0.2, 0.2, 0.2},
		TileImageBK = IMAGE_BLANK,
	}
	spectatorStackPanel._relativeBounds.bottom = nil
	
	-- ADD TEAM
	local newTeamHolder = Control:New {
		name = "newTeamHolder",
		x = 0,
		right = 0,
		bottom = 0,
		height = NEW_TEAM_SPACING,
		padding = {0, 2, 0, 0},
		parent = playerParent,
	}
	
	local label = Label:New {
		x = 5,
		y = 0,
		width = 120,
		height = NEW_TEAM_SPACING,
		valign = "center",
		font = {size = 20},
		caption = "New Team:",
		parent = newTeamHolder,
	}
	AddTeamButtons(
		newTeamHolder,
		110,
		(NEW_TEAM_SPACING - 30)/2,
		function()
			battleLobby:SetBattleStatus({
				allyNumber = emptyTeamIndex,
				isSpectator = false,
			})
		end, 
		function()
			WG.Chobby.AiListWindow(battleLobby, battle.gameName, emptyTeamIndex)
		end
	)
	
	-- Object handling
	local player = {}
	local team = {}
	
	local function PositionChildren(panel, minHeight)
		local children = panel.children
		
		minHeight = minHeight - 10
		
		local childrenCount = #children
		local bottomBuffer = 0
		
		local totalHeight = 0
		local maxHeight = 0
		for i = 1, #children do
			local child = children[i]
			totalHeight = totalHeight + child.height
			if child.height > maxHeight then
				maxHeight = child.height
			end
		end
		
		if childrenCount * maxHeight + bottomBuffer > minHeight then
			if totalHeight < minHeight then
				totalHeight = minHeight
			end
			panel:SetPos(nil, nil, nil, totalHeight)
			local runningHeight = 0
			for i = 1, #children do
				local child = children[i]
				child:SetPos(nil, runningHeight)
				child:Invalidate()
				runningHeight = runningHeight + child.height
			end
		else
			panel:SetPos(nil, nil, nil, minHeight)
			for i = 1, #children do
				local child = children[i]
				child:SetPos(nil, minHeight * (i - 1)/#children)
				child:Invalidate()
			end
		end
		panel:Invalidate()
	end
	
	local function GetPlayerData(name)
		if not player[name] then
			player[name] = {
				team = false,
				control = WG.UserHandler.GetBattleUser(name, battleLobby.name == "singleplayer"),
			}
		end
		return player[name]
	end
	
	local function GetTeam(teamIndex)
		teamIndex = teamIndex or -1
		if not team[teamIndex] then
			if teamIndex == emptyTeamIndex then
				local checkTeam = teamIndex + 1
				while team[checkTeam] do
					checkTeam = checkTeam + 1
				end
				emptyTeamIndex = checkTeam
			end
		
			local humanName, parentStack, parentScroll
			if teamIndex == -1 then
				humanName = "Spectators"
				parentStack = spectatorStackPanel
				parentScroll = spectatorScrollPanel
			else
				humanName = "Team " .. teamIndex
				parentStack = mainStackPanel
				parentScroll = mainScrollPanel
			end

			local teamHolder = Control:New {
				name = teamIndex,
				x = 0,
				right = 0,
				y = 0,
				height = 50,
				padding = {0, 0, 0, 0},
				parent = parentStack,
			} 
			
			local label = Label:New {
				x = 5,
				y = 0,
				width = 120,
				height = 30,
				valign = "center",
				font = {size = 20},
				caption = humanName,
				parent = teamHolder,
			}
			if teamIndex ~= -1 then
				AddTeamButtons(
					teamHolder,
					100,
					0,
					function()
						battleLobby:SetBattleStatus({
								allyNumber = teamIndex,
								isSpectator = false,
							})
					end, 
					function()
						WG.Chobby.AiListWindow(battleLobby, battle.gameName, teamIndex)
					end
				)
			end
			local teamStack = Control:New {
				x = 0,
				y = 25,
				right = 0,
				bottom = 0,
				padding = {0, 0, 0, 0},
				parent = teamHolder,
				preserveChildrenOrder = true,
			}
			
			if teamIndex == -1 then
				-- Empty spectator team is created. Position children to prevent flicker.
				PositionChildren(parentStack, parentScroll.height)
			end
			
			local teamData = {}
			
			function teamData.AddPlayer(name)
				local playerData = GetPlayerData(name)
				if playerData.team == teamIndex then
					return
				end
				playerData.team = teamIndex
				local playerControl = playerData.control
				if not teamStack:GetChildByName(playerControl.name) then
					teamStack:AddChild(playerControl)
					playerControl:SetPos(nil, (#teamStack.children - 1)*SPACING)
					playerControl:Invalidate()
					
					teamHolder:SetPos(nil, nil, nil, #teamStack.children*SPACING + 35)
					PositionChildren(parentStack, parentScroll.height)
					teamHolder:Invalidate()
				end
			end
			
			function teamData.RemovePlayer(name)
				local playerData = GetPlayerData(name)
				if playerData.team ~= teamIndex then
					return
				end
				playerData.team = false
				local index = 1
				local timeToMove = false
				while index <= #teamStack.children do
					if timeToMove then
						teamStack.children[index]:SetPos(nil, (index - 1)*SPACING)
						teamStack.children[index]:Invalidate()
					elseif teamStack.children[index].name == name then
						teamStack:RemoveChild(teamStack.children[index])
						index = index - 1
						timeToMove = true
					end
					index = index + 1
				end
				teamHolder:SetPos(nil, nil, nil, #teamStack.children*SPACING + 35)
				
				if teamStack:IsEmpty() and teamIndex ~= -1 then
					if teamIndex < emptyTeamIndex then
						emptyTeamIndex = teamIndex
					end
				
					team[teamIndex] = nil
					parentStack:RemoveChild(parentStack:GetChildByName(teamIndex))
					teamHolder:Dispose()
				else
					teamHolder:Invalidate()
				end
				PositionChildren(parentStack, parentScroll.height)
			end
			
			team[teamIndex] = teamData
		end
		return team[teamIndex] 
	end
	
	-- Object modification
	local function AddPlayerToTeam(allyTeamID, name)
		local teamObject = GetTeam(allyTeamID)
		teamObject.AddPlayer(name)
	end
	
	local function RemovePlayerFromTeam(name)
		local playerData = GetPlayerData(name)
		if playerData.team then
			local teamObject = GetTeam(playerData.team)
			teamObject.RemovePlayer(name)
		end
	end
	
	GetTeam(-1) -- Make Spectator heading appear
	
	-- Global function
	function ViewResizeUpdate()
		if mainStackPanel and spectatorStackPanel then
			PositionChildren(mainStackPanel, mainScrollPanel.height)
			PositionChildren(spectatorStackPanel, spectatorScrollPanel.height)
		end
	end
	
	onUpdateUserTeamStatus = function(listener, userName, allyNumber, isSpectator)
		RemovePlayerFromTeam(userName)
		if isSpectator then
			AddPlayerToTeam(-1, userName)
		else
			AddPlayerToTeam(allyNumber, userName)
		end
	end
	battleLobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatus)
	
	onLeftBattle = function(listener, leftBattleID, userName)
		if leftBattleID == battleID then
			RemovePlayerFromTeam(userName)
		end
	end
	battleLobby:AddListener("OnLeftBattle", onLeftBattle)
	
	onRemoveAi = function(listener, botName)
		RemovePlayerFromTeam(botName)
	end
	battleLobby:AddListener("OnRemoveAi", onRemoveAi)
end

local unreadMessages = 0
local function _NotifyBattleRoom(userName, message, sound, time)
	if string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName() then
		unreadMessages = unreadMessages + 1
		WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler().SetActivity("myBattle", unreadMessages)
	end
--[[
	Chotify:Post({
		title = userName .. " in " .. chanName .. ":",
		body = message,
		sound = sound,
		time = time,
	})]]
end

local function InitializeControls(battleID, oldLobby, topPoportion)
	local battle = battleLobby:GetBattle(battleID)
	
	local EXTERNAL_PAD_VERT = 10
	local EXTERNAL_PAD_HOR = 15
	local INTERNAL_PAD = 2
	
	window = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		padding = {0, 0, 0, 0},
		OnDispose = { 
			function()
				emptyTeamIndex = 0
			
				oldLobby:RemoveListener("OnBattleClosed", onBattleClosed)
				oldLobby:RemoveListener("OnLeftBattle", onLeftBattle_counter)
				oldLobby:RemoveListener("OnJoinedBattle", onJoinedBattle)
				oldLobby:RemoveListener("OnSaidBattle", onSaidBattle)
				oldLobby:RemoveListener("OnSaidBattleEx", onSaidBattleEx)
				oldLobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatus)
				oldLobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
				oldLobby:RemoveListener("OnLeftBattle", onLeftBattle)
				oldLobby:RemoveListener("OnRemoveAi", onRemoveAi)
				oldLobby:RemoveListener("OnBattleIngameUpdate", onBattleIngameUpdate)
			end
		},
	}
	
	local subPanel = Control:New {
		x = 0,
		y = 42,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		parent = window,
	}
	
	local playerPanel = Control:New {
		x = 0,
		y = 0,
		right = "50%",
		bottom = (100 - topPoportion) .. "%",
		padding = {EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT, INTERNAL_PAD, INTERNAL_PAD},
		parent = subPanel,
	}
	
	local spectatorPanel = Control:New {
		x = "67%",
		y = topPoportion .. "%",
		right = 0,
		bottom = 0,
		-- Add 7 to line up with chat
		padding = {INTERNAL_PAD, INTERNAL_PAD, EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT + 7},
		parent = subPanel,
	}
	
	SetupPlayerPanel(playerPanel, spectatorPanel, battle, battleID)
	
	local leftInfo = Control:New {
		x = "50%",
		y = 0,
		right = "33%",
		bottom = (100 - topPoportion) .. "%",
		padding = {EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT, 1, INTERNAL_PAD},
		parent = subPanel,
	}
	
	local rightInfo = Control:New {
		x = "67%",
		y = 0,
		right = 0,
		bottom = (100 - topPoportion) .. "%",
		padding = {1, EXTERNAL_PAD_VERT, EXTERNAL_PAD_HOR, INTERNAL_PAD},
		parent = subPanel,
	}
	
	SetupInfoButtonsPanel(leftInfo, rightInfo, battle, battleID, battleLobby:GetMyUserName())
	
	local btnQuitBattle = Button:New {
		right = 10,
		y = 10,
		width = 80,
		height = 45,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = WG.Chobby.Configuration:GetErrorColor() .. i18n("leave") .. "\b",
		OnClick = {
			function()
				battleLobby:LeaveBattle()
			end
		},
		parent = window,
	}
	
	
	local lblBattleTitle = Label:New {
		x = 18,
		y = 18,
		width = 200,
		height = 30,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = i18n("battle") .. ": " .. tostring(battle.title),
		parent = window,
	}

	local line = Line:New {
		x = 0,
		y = 0,
		width = 300,
		parent = subPanel,
	}

	local battleRoomConsole = WG.Chobby.Console()
	battleRoomConsole.listener = function(message)
		battleLobby:SayBattle(message)
	end
	
	local chatPanel = Control:New {
		x = 0,
		y = topPoportion .. "%",
		bottom = 0,
		right = "33%",
		padding = {EXTERNAL_PAD_HOR, INTERNAL_PAD, INTERNAL_PAD, EXTERNAL_PAD_VERT},
		itemPadding = {0, 0, 0, 0},
		itemMargin = {0, 0, 0, 0},
		children = {
			Control:New {
				x = 0, y = 0, right = 0, bottom = 0,
				padding={0,0,0,0}, itemPadding={0,0,0,0}, itemMargin={0,0,0,0},
				children = { battleRoomConsole.panel, },
			},
		},
		parent = subPanel,
	}

	local onSaidBattle = function(listener, userName, message)
		battleRoomConsole:AddMessage(userName .. ": " .. message)
		_NotifyBattleRoom(userName, message, "sounds/beep4.wav", 15)
	end
	battleLobby:AddListener("OnSaidBattle", onSaidBattle)

	local onSaidBattleEx = function(listener, userName, message)
		battleRoomConsole:AddMessage("\255\0\139\139" .. userName .. " " .. message .. "\b")		
		_NotifyBattleRoom(userName, message, "sounds/beep4.wav", 15)
	end
	battleLobby:AddListener("OnSaidBattleEx", onSaidBattleEx)

	onBattleClosed = function(listener, closedBattleID, ... )
		if battleID == closedBattleID then
			window:Dispose()
			if wrapperControl and wrapperControl.visible and wrapperControl.parent then
				wrapperControl:Hide()
			end
		end
	end
	battleLobby:AddListener("OnBattleClosed", onBattleClosed)
	
	WG.Delay(ViewResizeUpdate, 0.1)
	
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local BattleRoomWindow = {}

function BattleRoomWindow.ShowMultiplayerBattleRoom(battleID)
	if window then
		window:Dispose()
	end
	
	if singleplayerWrapper then
		singleplayerWrapper = nil
	end
	
	local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
	parentTabPanel = tabPanel
	
	battleLobby = WG.LibLobby.lobby
				
	multiplayerWrapper = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		padding = {0, 0, 0, 0},
		
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					wrapperControl = obj
					
					local battleWindow = InitializeControls(battleID, battleLobby, 55)
					obj:AddChild(battleWindow)
				end
			end
		},
		OnHide = {
			function(obj)
				tabPanel.RemoveTab("myBattle")
			end
		}
	}

	tabPanel.AddTab("myBattle", "My Battle", multiplayerWrapper, false, 3, true)
	
	battleLobby:SetBattleStatus({
		allyNumber = 0,
		isSpectator = false,
		sync = 1, -- 0 = unknown, 1 = synced, 2 = unsynced
	})
end

function BattleRoomWindow.GetSingleplayerControl()
	
	singleplayerWrapper = Control:New {
		name = "singleplayerWrapper",
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		padding = {0, 0, 0, 0},
		
		OnParent = {
			function(obj)
				if window then
					window:Dispose()
				end
				
				if multiplayerWrapper then
					local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
					tabPanel.RemoveTab("myBattle")
					
					WG.LibLobby.lobby:LeaveBattle()
				end
				
				local singleplayerDefault = WG.Chobby.Configuration:GetGameConfig(singleplayerGame, "skirmishDefault.lua")
				
				local defaultMap = Game.mapName
				if singleplayerDefault and singleplayerDefault.map then
					defaultMap = singleplayerDefault.map
				end
				
				parentTabPanel = nil
				
				battleLobby = WG.LibLobby.lobbySkirmish
				battleLobby:SetBattleState(lobby:GetMyUserName() or "Player", singleplayerGame, defaultMap, "Skirmish Battle")

				wrapperControl = obj
				
				local battleWindow = InitializeControls(1, battleLobby, 70)
				obj:AddChild(battleWindow)

				battleLobby:SetBattleStatus({
					allyNumber = 0,
					isSpectator = false,
					sync = 1, -- 0 = unknown, 1 = synced, 2 = unsynced
				})
				
				if singleplayerDefault and singleplayerDefault.enemyAI then
					battleLobby:AddAi(singleplayerDefault.enemyAI .. " (1)", singleplayerDefault.enemyAI, 1)
				end
			end
		},
	}
	
	return singleplayerWrapper
end

function BattleRoomWindow.SetSingleplayerGame(ToggleShowFunc, battleroomObj, tabData)
	
	local function SetGameFail()
		WG.LibLobby.lobbySkirmish:LeaveBattle()
	end

	local function SetGameSucess(name)
		singleplayerGame = name
		ToggleShowFunc(battleroomObj, tabData)
	end
	
	local config = WG.Chobby.Configuration
	if config.singleplayer_mode == 1 then
		WG.Chobby.GameListWindow(SetGameFail, SetGameSucess)
	elseif config.singleplayer_mode == 2 then
		singleplayerGame = "Zero-K v1.4.7.0"
		ToggleShowFunc(battleroomObj, tabData)
	end
end

function BattleRoomWindow.LeaveBattle()
	if battleLobby then
		battleLobby:LeaveBattle()
		onBattleClosed(_, battleLobby:GetMyBattleID())
		
		local tabPanel = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()
		tabPanel.RemoveTab("myBattle")
	end
end

function widget:ViewResize(vsx, vsy, viewGeometry)
	if ViewResizeUpdate then
		WG.Delay(ViewResizeUpdate, 0.1)
		WG.Delay(ViewResizeUpdate, 0.2)
		WG.Delay(ViewResizeUpdate, 0.4)
		WG.Delay(ViewResizeUpdate, 0.8)
	end
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.BattleRoomWindow = BattleRoomWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
