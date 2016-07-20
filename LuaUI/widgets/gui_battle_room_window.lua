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
local onVoteUpdate
local onVoteEnd

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

local haveMapAndGame = false

local function UpdateArchiveStatus()
	if not battleLobby:GetMyBattleID() then
		return
	end
	local battle = battleLobby:GetBattle(battleLobby:GetMyBattleID())
	if not battle then
		haveMapAndGame = false
		return
	end
	local haveGame = VFS.HasArchive(battle.gameName)
	local haveMap = VFS.HasArchive(battle.mapName)
	
	if haveGame then
		lblHaveGame:SetCaption(i18n("have_game") .. " [" .. WG.Chobby.WG.Chobby.Configuration:GetTick() .. "\b]")
	else
		lblHaveGame:SetCaption(i18n("dont_have_game") .. " [" .. WG.Chobby.Configuration:GetCross() .. "\b]")
	end
	
	if haveMap then
		lblHaveMap:SetCaption(i18n("have_map") .. " [" .. WG.Chobby.WG.Chobby.Configuration:GetTick() .. "\b]")
	else
		lblHaveMap:SetCaption(i18n("dont_have_map") .. " [" .. WG.Chobby.Configuration:GetCross() .. "\b]")
	end
	
	haveMapAndGame = (haveGame and haveMap)
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
	
	if battleLobby then
		battleLobby:SetBattleStatus({
			sync = (haveMapAndGame and 1) or 2, -- 0 = unknown, 1 = synced, 2 = unsynced
		})
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Chili/interface management

local function SetupInfoButtonsPanel(leftInfo, rightInfo, battle, battleID, myUserName)

	local minimapBottomClearance = 135

	local lblMapName = Label:New {
		x = 5,
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
		height = 200,
		parent = rightInfo,
	}
	local minimapImage = Image:New {
		x = 2,
		y = 2,
		right = 2,
		bottom = 2,
		keepAspect = true,
		file = WG.Chobby.Configuration:GetMinimapImage(battle.mapName, battle.gameName),
		parent = minimap,
	}

	local btnStartBattle = Button:New {
		x = 0,
		bottom = 0,
		right = 0,
		height = 50,
		caption = "\255\66\138\201" .. i18n("start") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function()
				if haveMapAndGame then
					if battle.isRunning then
						battleLobby:ConnectToBattle()
					else
						battleLobby:StartBattle()
					end
				else
					Spring.Echo("Do something if map or game is missing")
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
	
	rightInfo.OnResize = {
		function (obj, xSize, ySize)
			if xSize + minimapBottomClearance < ySize then
				minimap._relativeBounds.left = 0
				minimap._relativeBounds.right = 0
				minimap:SetPos(nil, nil, nil, xSize)
				minimap:UpdateClientArea()
				
				lblMapName:SetPos(5, xSize + 5)
			else
				local horPadding = ((xSize + minimapBottomClearance) - ySize)/2
				minimap._relativeBounds.left = horPadding
				minimap._relativeBounds.right = horPadding
				minimap:SetPos(nil, nil, nil, ySize - minimapBottomClearance)
				minimap:UpdateClientArea()
				
				lblMapName:SetPos(5, ySize - minimapBottomClearance + 5)
			end
		end
	}
	
	local leftOffset = 0
	local newTeam = ComboBox:New {
		name = "newTeam",
		x = 0,
		y = leftOffset,
		right = 0,
		height = 40,
		caption = "\255\66\138\201" .. i18n("add_team") ..  "\b",
		font = WG.Chobby.Configuration:GetFont(1),
		ignoreItemCaption = true,
		itemFontSize = WG.Chobby.Configuration:GetFont(1).size,
		itemHeight = 30,
		selected = 0,
		maxDropDownWidth = 120,
		minDropDownHeight = 0,
		items = {"Join", "Add AI"},
		OnSelect = {
			function (obj)
				if obj.selected == 1 then
					battleLobby:SetBattleStatus({
						allyNumber = emptyTeamIndex,
						isSpectator = false,
					})
				elseif obj.selected == 2 then
					WG.Chobby.AiListWindow(battleLobby, battle.gameName, emptyTeamIndex)
				end
			end
		},
		parent = leftInfo
	}
	leftOffset = leftOffset + 45
	
	local btnPickMap = Button:New {
		x = 0,
		y = leftOffset,
		height = 40,
		right = 0,
		caption = "\255\66\138\201" .. i18n("pick_map") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(1),
		OnClick = {
			function()
				WG.Chobby.MapListWindow(battleLobby)
			end
		},
		parent = leftInfo,
	}
	leftOffset = leftOffset + 45

	local lblNumberOfPlayers = Label:New {
		x = 8,
		y = leftOffset,
		width = 200,
		height = 30,
		caption = "",
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 25
	
	lblHaveGame = Label:New {
		x = 8,
		y = leftOffset,
		caption = "",
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 25

	lblHaveMap = Label:New {
		x = 8,
		y = leftOffset,
		caption = "",
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 25
	
	leftOffset = leftOffset + 15	
	local downloader = WG.Chobby.Downloader(
		{
			x = 0,
			bottom = 0,
			right = 0,
			y = leftOffset,
			parent = leftInfo,
		}, 
		8
	)
	downloader:Hide()
	-- Example downloads
	--MaybeDownloadArchive("Titan-v2", "map")
	--MaybeDownloadArchive("tinyskirmishredux1.1", "map")
	
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
			minimapImage.file = WG.Chobby.Configuration:GetMinimapImage(mapName, battle.gameName)
			minimapImage:Invalidate()
			
			-- TODO: Bit lazy here, seeing as we only need to update the map
			UpdateArchiveStatus()
			MaybeDownloadMap(battle)
			
			if not VFS.HasArchive(mapName) then
				battleLobby:SetBattleStatus({
					sync = 2, -- 0 = unknown, 1 = synced, 2 = unsynced
				})
			end
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
		name = "joinTeamButton",
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
		font = WG.Chobby.Configuration:GetFont(3),
		caption = i18n("add_ai") .. "\b",
		OnClick = {aiFunc},
		parent = parent,
	}
end

local function SetupPlayerPanel(playerParent, spectatorParent, battle, battleID)
	
	local SPACING = 22
		
	local mainScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = playerParent,
		horizontalScrollbar = false,
	}
	
	local mainStackPanel = Control:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = mainScrollPanel,
		preserveChildrenOrder = true,
	}	
	mainStackPanel._relativeBounds.bottom = nil
	local spectatorScrollPanel = ScrollPanel:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = spectatorParent,
		horizontalScrollbar = false,
	}
		
	local spectatorStackPanel = Control:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = spectatorScrollPanel,
	}
	spectatorStackPanel._relativeBounds.bottom = nil
	
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
				font = WG.Chobby.Configuration:GetFont(3),
				caption = humanName,
				parent = teamHolder,
			}
			if teamIndex ~= -1 then
				AddTeamButtons(
					teamHolder,
					82,
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
				if name == battleLobby:GetMyUserName() then
					local joinTeam = teamHolder:GetChildByName("joinTeamButton")
					if joinTeam then
						joinTeam:SetVisibility(false)
					end
				end
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
				
				if name == battleLobby:GetMyUserName() then
					local joinTeam = teamHolder:GetChildByName("joinTeamButton")
					if joinTeam then
						joinTeam:SetVisibility(true)
					end
				end
				
				if teamStack:IsEmpty() and teamIndex ~= -1 then
					local teamCount = 0
					for _,_ in pairs(team) do
						teamCount = teamCount + 1
					end
					-- Don't leave us with less than two teams (spectator is a team too)
					if teamCount > 3 then
						if teamIndex < emptyTeamIndex then
							emptyTeamIndex = teamIndex
						end
					
						team[teamIndex] = nil
						parentStack:RemoveChild(parentStack:GetChildByName(teamIndex))
						teamHolder:Dispose()
					else
						teamHolder:Invalidate()
					end
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
		if isSpectator then
			allyNumber = -1
		end
		local playerData = GetPlayerData(userName)
		if playerData.team == allyNumber then
			return
		end
		RemovePlayerFromTeam(userName)
		AddPlayerToTeam(allyNumber, userName)
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

local function SetupVotePanel(votePanel, battle, battleID)
	local height = votePanel.clientHeight
	
	local offset = 0
	
	local activePanel = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		parent = votePanel,
	}
	
	local buttonNo
	local buttonYes = Button:New {
		x = offset,
		y = 0,
		bottom = 0,
		width = height,
		caption = "",
		OnClick = {
			function (obj)
				WG.ButtonUtilities.SetButtonSelected(obj)
				WG.ButtonUtilities.SetButtonDeselected(buttonNo)
				battleLobby:VoteYes()
			end
		},
		padding = {10,10,10,10},
		children = {
			Image:New {
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				autosize = true,
				file = "luaui/images/ready.png",
			}
		},
		parent = activePanel,
	}
	offset = offset + height
	
	buttonNo = Button:New {
		x = offset,
		y = 0,
		bottom = 0,
		width = height,
		caption = "",
		OnClick = {
			function (obj)
				WG.ButtonUtilities.SetButtonSelected(obj)
				WG.ButtonUtilities.SetButtonDeselected(buttonYes)
				battleLobby:VoteNo()
			end
		},
		padding = {10,10,10,10},
		children = {
			Image:New {
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				file = "luaui/images/unready.png",
			}
		},
		parent = activePanel,
	}
	offset = offset + height

	offset = offset + 2
	
	local voteName = Label:New {
		x = offset,
		y = 4,
		width = 50,
		bottom = height * 0.4,
		font = WG.Chobby.Configuration:GetFont(2),
		caption = "",
		parent = activePanel,
	}
	
	local voteProgress = Progressbar:New {
		x = offset,
		y = height * 0.5,
		right = 55,
		bottom = 0,
		value = 0,
		parent = activePanel,
	}
	
	local voteCountLabel = Label:New {
		right = 5,
		y = height * 0.5,
		width = 50,
		bottom = 0,
		align = "left",
		font = WG.Chobby.Configuration:GetFont(2),
		caption = "20/50",
		parent = activePanel,
	}
	
	if activePanel.visible then
		activePanel:Hide()
	end
	
	local voteResultLabel = Label:New {
		x = 5,
		y = 4,
		right = 0,
		bottom = height * 0.4,
		align = "left",
		font = WG.Chobby.Configuration:GetFont(2),
		caption = "",
		parent = votePanel,
	}
	
	if voteResultLabel.visible then
		voteResultLabel:Hide()
	end
	
	local function HideVoteResult()
		if voteResultLabel.visible then
			voteResultLabel:Hide()
		end
	end
	
	onVoteUpdate = function(listener, message, yesVotes, noVotes, votesNeeded)
		voteName:SetCaption(message)
		voteCountLabel:SetCaption(yesVotes .. "/" .. votesNeeded)
		voteProgress:SetValue(100 * yesVotes / votesNeeded)
		if not activePanel.visible then
			activePanel:Show()
		end
		HideVoteResult()
	end
	battleLobby:AddListener("OnVoteUpdate", onVoteUpdate)
	
	onVoteEnd = function(listener, message, success)
		if activePanel.visible then
			activePanel:Hide()
		end
		local text = ((success and WG.Chobby.Configuration:GetSuccessColor()) or WG.Chobby.Configuration:GetErrorColor()) .. message .. ((success and " Passed.") or " Failed.")
		voteResultLabel:SetCaption(text)
		if not voteResultLabel.visible then
			voteResultLabel:Show()
		end
		
		WG.ButtonUtilities.SetButtonDeselected(buttonYes)
		WG.ButtonUtilities.SetButtonDeselected(buttonNo)
		
		WG.Delay(HideVoteResult, 5)
	end
	battleLobby:AddListener("OnVoteEnd", onVoteEnd)
end

local unreadMessages = 0
local function _NotifyBattleRoom(userName, message, sound, notificationTime)
	if string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName() then
		unreadMessages = unreadMessages + 1
		WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler().SetActivity("myBattle", unreadMessages)
	end
--[[
	Chotify:Post({
		title = userName .. " in " .. chanName .. ":",
		body = message,
		sound = sound,
		time = notificationTime,
	})]]
end

local function InitializeControls(battleID, oldLobby, topPoportion)
	local battle = battleLobby:GetBattle(battleID)
	
	local EXTERNAL_PAD_VERT = 10
	local EXTERNAL_PAD_HOR = 15
	local INTERNAL_PAD = 2
	
	local BOTTOM_SPACING = 50
	
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
				oldLobby:RemoveListener("OnVoteUpdate", onVoteUpdate)
				oldLobby:RemoveListener("OnVoteEnd", onVoteEnd)
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
	
	local topPanel = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = (100 - topPoportion) .. "%",
		padding = {0, 0, 0, 0},
		parent = subPanel,
	}
	
	local bottomPanel = Control:New {
		x = 0,
		y = topPoportion .. "%",
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		parent = subPanel,
	}
	
	local playerPanel = Control:New {
		x = 0,
		y = 0,
		right = "52%",
		bottom = BOTTOM_SPACING,
		padding = {EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT, INTERNAL_PAD, 0},
		parent = topPanel,
	}
	
	local spectatorPanel = Control:New {
		x = "67%",
		y = 0,
		right = 0,
		bottom = 0,
		-- Add 7 to line up with chat
		padding = {INTERNAL_PAD, INTERNAL_PAD, EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT + 7},
		parent = bottomPanel,
	}
	
	SetupPlayerPanel(playerPanel, spectatorPanel, battle, battleID)
	
	local votePanel = Control:New {
		x = 0,
		right = "33%",
		bottom = 0,
		height = BOTTOM_SPACING,
		padding = {EXTERNAL_PAD_HOR, INTERNAL_PAD, 1, INTERNAL_PAD},
		parent = topPanel,
	}
	
	SetupVotePanel(votePanel)
	
	local leftInfo = Control:New {
		x = "48%",
		y = 0,
		right = "33%",
		bottom = BOTTOM_SPACING,
		padding = {INTERNAL_PAD, EXTERNAL_PAD_VERT, 1, INTERNAL_PAD},
		parent = topPanel,
	}
	
	local rightInfo = Control:New {
		x = "67%",
		y = 0,
		right = 0,
		bottom = 0,
		padding = {1, EXTERNAL_PAD_VERT, EXTERNAL_PAD_HOR, INTERNAL_PAD},
		parent = topPanel,
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
		y = 0,
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
		parent = bottomPanel,
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
	
	UpdateArchiveStatus()
	
	battleLobby:SetBattleStatus({
		allyNumber = 0,
		isSpectator = false,
		sync = (haveMapAndGame and 1) or 2, -- 0 = unknown, 1 = synced, 2 = unsynced
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

				UpdateArchiveStatus()
				
				battleLobby:SetBattleStatus({
					allyNumber = 0,
					isSpectator = false,
					sync = (haveMapAndGame and 1) or 2, -- 0 = unknown, 1 = synced, 2 = unsynced
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
