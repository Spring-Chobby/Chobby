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
local mainWindow

-- Globals
local battleLobby
local wrapperControl
local mainWindowFunctions

local singleplayerWrapper
local multiplayerWrapper

local singleplayerGame = "Chobby $VERSION"

local IMG_READY    = LUA_DIRNAME .. "images/ready.png"
local IMG_UNREADY  = LUA_DIRNAME .. "images/unready.png"


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Download management

local emptyTeamIndex = 0

local haveMapAndGame = false

local function UpdateArchiveStatus(updateSync)
	if not battleLobby or not battleLobby:GetMyBattleID() then
		return
	end
	local battle = battleLobby:GetBattle(battleLobby:GetMyBattleID())
	if not battle then
		haveMapAndGame = false
		return
	end
	local haveGame = VFS.HasArchive(battle.gameName)
	local haveMap = VFS.HasArchive(battle.mapName)

	if mainWindowFunctions and mainWindowFunctions.GetInfoHandler() then
		local infoHandler = mainWindowFunctions.GetInfoHandler()
		infoHandler.SetHaveGame(haveGame)
		infoHandler.SetHaveMap(haveMap)
	end
	
	haveMapAndGame = (haveGame and haveMap)
	
	if updateSync and battleLobby then
		battleLobby:SetBattleStatus({
			sync = (haveMapAndGame and 1) or 2, -- 0 = unknown, 1 = synced, 2 = unsynced
		})
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
	UpdateArchiveStatus(true)
end

local OpenNewTeam

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
		caption = battle.mapName:gsub("_", " "),
		parent = rightInfo,
	}

	local minimapPanel = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		height = 200,
		padding = {1,1,1,1},
		parent = rightInfo,
	}
	local btnMinimap = Button:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		parent = minimapPanel,
		padding = {5,5,5,5},
		OnClick = {
			function()
				WG.Chobby.MapListWindow(battleLobby, battle.gameName, battle.mapName)
			end
		},
	}
	local imMinimap = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = WG.Chobby.Configuration:GetMinimapImage(battle.mapName),
		parent = btnMinimap,
	}

	local function RejoinBattleFunc()
		battleLobby:RejoinBattle(battleID)
	end
	
	local btnStartBattle = Button:New {
		x = 0,
		bottom = 0,
		right = 0,
		height = 48,
		caption = i18n("start"),
		classname = "action_button",
		font = WG.Chobby.Configuration:GetFont(4),
		OnClick = {
			function()
				if haveMapAndGame then
					if battle.isRunning then
						if Spring.GetGameName() == "" then
							RejoinBattleFunc()
						else
							 WG.Chobby.ConfirmationPopup(RejoinBattleFunc, "Are you sure you want to leave your current game to rejoin this one?", nil, 315, 200)
						end
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
		bottom = 52,
		height = 48,
		caption = "\255\66\138\201" .. i18n("spectator") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function(obj)
				battleLobby:SetBattleStatus({isSpectator = true})
				ButtonUtilities.SetButtonDeselected(btnPlay)
				ButtonUtilities.SetCaption(btnPlay, i18n("play"))
				ButtonUtilities.SetButtonSelected(obj)
				ButtonUtilities.SetCaption(obj, i18n("spectating"))
			end
		},
		parent = rightInfo,
	}

	btnPlay = Button:New {
		x = 0,
		right = "50%",
		bottom = 52,
		height = 48,
		caption = "\255\66\138\201" .. i18n("player") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(3),
		OnClick = {
			function(obj)
				battleLobby:SetBattleStatus({isSpectator = false})
				ButtonUtilities.SetButtonDeselected(btnSpectate)
				ButtonUtilities.SetCaption(btnSpectate, i18n("spectate"))
				ButtonUtilities.SetButtonSelected(obj)
				ButtonUtilities.SetCaption(obj, i18n("playing"))
			end
		},
		parent = rightInfo,
	}

	rightInfo.OnResize = {
		function (obj, xSize, ySize)
			if xSize + minimapBottomClearance < ySize then
				minimapPanel._relativeBounds.left = 0
				minimapPanel._relativeBounds.right = 0
				minimapPanel:SetPos(nil, nil, nil, xSize)
				minimapPanel:UpdateClientArea()

				lblMapName:SetPos(5, xSize + 5)
			else
				local horPadding = ((xSize + minimapBottomClearance) - ySize)/2
				minimapPanel._relativeBounds.left = horPadding
				minimapPanel._relativeBounds.right = horPadding
				minimapPanel:SetPos(nil, nil, nil, ySize - minimapBottomClearance)
				minimapPanel:UpdateClientArea()

				lblMapName:SetPos(5, ySize - minimapBottomClearance + 5)
			end
		end
	}

	local leftOffset = 0
	local btnNewTeam = Button:New {
		name = "btnNewTeam",
		x = 5,
		y = leftOffset,
		height = 35,
		right = 5,
		caption = "\255\66\138\201" .. i18n("add_team") ..  "\b",
		font = WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				if OpenNewTeam then
					OpenNewTeam()
				end
			end
		},
		-- Combo box settings
		--ignoreItemCaption = true,
		--itemFontSize = WG.Chobby.Configuration:GetFont(1).size,
		--itemHeight = 30,
		--selected = 0,
		--maxDropDownWidth = 120,
		--minDropDownHeight = 0,
		--items = {"Join", "Add AI"},
		--OnSelect = {
		--	function (obj)
		--		if obj.selected == 1 then
		--			battleLobby:SetBattleStatus({
		--				allyNumber = emptyTeamIndex,
		--				isSpectator = false,
		--			})
		--		elseif obj.selected == 2 then
		--			WG.PopupPreloader.ShowAiListWindow(battleLobby, battle.gameName, emptyTeamIndex)
		--		end
		--	end
		--},
		parent = leftInfo
	}
	leftOffset = leftOffset + 38

	local btnPickMap = Button:New {
		x = 5,
		y = leftOffset,
		height = 35,
		right = 5,
		caption = "\255\66\138\201" .. i18n("pick_map") ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				WG.Chobby.MapListWindow(battleLobby, battle.gameName, battle.mapName)
			end
		},
		parent = leftInfo,
	}
	leftOffset = leftOffset + 38

	WG.ModoptionsPanel.LoadModotpions(battle.gameName, battleLobby)
	local btnModoptions = Button:New {
		x = 5,
		y = leftOffset,
		height = 35,
		right = 5,
		caption = "\255\66\138\201" .. "Adv Options" ..  "\b",
		font =  WG.Chobby.Configuration:GetFont(2),
		OnClick = {
			function()
				WG.ModoptionsPanel.ShowModoptions()
			end
		},
		parent = leftInfo,
	}
	leftOffset = leftOffset + 40

	local lblGame = Label:New {
		x = 8,
		y = leftOffset,
		caption = battle.gameName,
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 26
	
	local imHaveGame = Image:New {
		x = 8,
		y = leftOffset,
		width = 15,
		height = 15,
		file = IMG_READY,
		parent = leftInfo,
	}
	local lblHaveGame = Label:New {
		x = 28,
		y = leftOffset,
		caption = "",
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 25

	local imHaveMap = Image:New {
		x = 8,
		y = leftOffset,
		width = 15,
		height = 15,
		file = IMG_READY,
		parent = leftInfo,
	}
	local lblHaveMap = Label:New {
		x = 28,
		y = leftOffset,
		caption = "",
		font = WG.Chobby.Configuration:GetFont(1),
		parent = leftInfo,
	}
	leftOffset = leftOffset + 25
	
	local modoptionsHolder = Control:New {
		x = 0,
		y = leftOffset,
		right = 0,
		height = 120,
		padding = {2, 0, 2, 0},
		autosize = false,
		resizable = false,
		children = {
			WG.ModoptionsPanel.GetModoptionsControl()
		},
		parent = leftInfo,
	}
	if modoptionsHolder.children[1].visible then
		modoptionsHolder.children[1]:Hide()
	end
	
	local modoptionTopPosition = leftOffset
	local modoptionBottomPosition = leftOffset + 120
	local downloadVisibility = true
	local function OnDownloaderVisibility(newVisible)
		if newVisible ~= nil then
			downloadVisibility = newVisible
		end
		local newY = downloadVisibility and modoptionBottomPosition or modoptionTopPosition
		local newHeight = math.max(10, leftInfo.clientArea[4] - newY)
		modoptionsHolder:SetPos(nil, newY, nil, newHeight)
	end
	OnDownloaderVisibility(false)
	leftInfo.OnResize = leftInfo.OnResize or {}
	leftInfo.OnResize[#leftInfo.OnResize + 1] = function ()
		OnDownloaderVisibility()
	end
	
	local downloaderPos = {
		x = 0,
		height = 120,
		right = 0,
		y = leftOffset,
		parent = leftInfo,
	}
	
	local downloader = WG.Chobby.Downloader(downloaderPos, 8, nil, nil, nil, OnDownloaderVisibility)
	leftOffset = leftOffset + 120
	
	-- Example downloads
	--MaybeDownloadArchive("Titan-v2", "map")
	--MaybeDownloadArchive("tinyskirmishredux1.1", "map")

	local externalFunctions = {}
	
	function externalFunctions.SetHaveGame(newHaveGame)
		if newHaveGame then
			imHaveGame.file = IMG_READY
			lblHaveGame:SetCaption(i18n("have_game"))
		else
			imHaveGame.file = IMG_UNREADY
			lblHaveGame:SetCaption(i18n("dont_have_game"))
		end
		imHaveGame:Invalidate()
	end
	
	function externalFunctions.SetHaveMap(newHaveMap)
		if newHaveMap then
			imHaveMap.file = IMG_READY
			lblHaveMap:SetCaption(i18n("have_map"))
		else
			imHaveMap.file = IMG_UNREADY
			lblHaveMap:SetCaption(i18n("dont_have_map"))
		end
		imHaveMap:Invalidate()
	end
	
	-- Lobby interface
	function externalFunctions.UpdateUserTeamStatus(userName, allyNumber, isSpectator)
		if userName == myUserName then
			if isSpectator then
				ButtonUtilities.SetButtonDeselected(btnPlay)
				ButtonUtilities.SetCaption(btnPlay, i18n("play"))
				ButtonUtilities.SetButtonSelected(btnSpectate)
				ButtonUtilities.SetCaption(btnSpectate, i18n("spectating"))
			else
				ButtonUtilities.SetButtonDeselected(btnSpectate)
				ButtonUtilities.SetCaption(btnSpectate, i18n("spectate"))
				ButtonUtilities.SetButtonSelected(btnPlay)
				ButtonUtilities.SetCaption(btnPlay, i18n("playing"))
			end
		end
	end

	function externalFunctions.BattleIngameUpdate(updatedBattleID, isRunning)
		if battleID == updatedBattleID then
			if isRunning then
				btnStartBattle:SetCaption(i18n("rejoin"))
			else
				btnStartBattle:SetCaption(i18n("start"))
			end
		end
	end

	externalFunctions.BattleIngameUpdate(battleID, battle.isRunning)

	function externalFunctions.UpdateBattleInfo(updatedBattleID, spectatorCount, locked, mapHash, mapName, engineVersion, runningSince, gameName, battleMode)
		if battleID ~= updatedBattleID then
			return
		end
		if mapName then
			lblMapName:SetCaption(mapName:gsub("_", " "))
			imMinimap.file = WG.Chobby.Configuration:GetMinimapImage(mapName)
			imMinimap:Invalidate()

			-- TODO: Bit lazy here, seeing as we only need to update the map
			UpdateArchiveStatus(true)
			MaybeDownloadMap(battle)
		end
		
		if gameName then
			lblGame:SetCaption(gameName)
			UpdateArchiveStatus(true)
			MaybeDownloadGame(battle)
		end
		
		if (mapName and not VFS.HasArchive(mapName)) or (gameName and not VFS.HasArchive(gameName)) then
			battleLobby:SetBattleStatus({
				sync = 2, -- 0 = unknown, 1 = synced, 2 = unsynced
			})
		end
	end

	function externalFunctions.LeftBattle(leftBattleID, userName)
		if battleID ~= leftBattleID then
			return
		end
		if battleLobby:GetMyUserName() == userName then
			mainWindow:Dispose()
			mainWindow = nil
			if wrapperControl and wrapperControl.visible and wrapperControl.parent then
				wrapperControl:Hide()
			end
		end
	end

	function externalFunctions.JoinedBattle(joinedBattleId, userName)
		if battleID ~= joinedBattleId then
			return
		end
	end

	MaybeDownloadGame(battle)
	MaybeDownloadMap(battle)
	UpdateArchiveStatus(true)
	
	return externalFunctions
end

local function AddTeamButtons(parent, offX, joinFunc, aiFunc, unjoinable, disallowBots)
	if not disallowBots then
		local addAiButton = Button:New {
			name = "addAiButton",
			x = offX,
			y = 5,
			height = 22,
			width = 72,
			font = WG.Chobby.Configuration:GetFont(2),
			caption = i18n("add_ai") .. "\b",
			OnClick = {aiFunc},
			classname = "option_button",
			parent = parent,
		}
		offX = offX + 82
	end
	if not unjoinable then
		local joinTeamButton = Button:New {
			name = "joinTeamButton",
			x = offX,
			y = 5,
			height = 22,
			width = 72,
			font = WG.Chobby.Configuration:GetFont(2),
			caption = i18n("join") .. "\b",
			OnClick = {joinFunc},
			classname = "option_button",
			parent = parent,
		}
	end
end

local function SetupPlayerPanel(playerParent, spectatorParent, battle, battleID)

	local SPACING = 22
	local disallowCustomTeams = battle.disallowCustomTeams
	local disallowBots = battle.disallowBots

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
			panel:SetPos(nil, nil, nil, totalHeight + 15)
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
				child:SetPos(nil, math.floor(minHeight * (i - 1)/#children))
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
				if disallowCustomTeams then
					if teamIndex == 0 then
						humanName = "Players"
					else
						humanName = "Bots"
					end
				else
					humanName = "Team " .. (teamIndex + 1)
				end
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
				local seperator = Line:New {
					x = 0,
					y = 25,
					right = 0,
					height = 2,
					parent = teamHolder
				}
			
				AddTeamButtons(
					teamHolder,
					90,
					function()
						battleLobby:SetBattleStatus({
								allyNumber = teamIndex,
								isSpectator = false,
							})
					end,
					function (obj, x, y, button)
						local quickAddAi
						if button == 3 and WG.Chobby.Configuration.lastAddedAiName then
							quickAddAi = WG.Chobby.Configuration.lastAddedAiName
						end
						WG.PopupPreloader.ShowAiListWindow(battleLobby, battle.gameName, teamIndex, quickAddAi)
					end,
					disallowCustomTeams and teamIndex ~= 0,
					(disallowBots or disallowCustomTeams) and teamIndex ~= 1
				)
			end
			local teamStack = Control:New {
				x = 0,
				y = 31,
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
			
			function teamData.UpdateBattleMode()
				local addAiButton = teamHolder:GetChildByName("addAiButton")
				if addAiButton then
					teamHolder:RemoveChild(addAiButton)
					addAiButton:Dispose()
				end
				local joinTeamButton = teamHolder:GetChildByName("joinTeamButton")
				if joinTeamButton then
					teamHolder:RemoveChild(joinTeamButton)
					joinTeamButton:Dispose()
				end
				
				if teamIndex ~= -1 then
					AddTeamButtons(
						teamHolder,
						90,
						function()
							battleLobby:SetBattleStatus({
									allyNumber = teamIndex,
									isSpectator = false,
								})
						end,
						function()
							WG.PopupPreloader.ShowAiListWindow(battleLobby, battle.gameName, teamIndex)
						end,
						disallowCustomTeams and teamIndex ~= 0,
						(disallowBots or disallowCustomTeams) and teamIndex ~= 1
					)
				
					if disallowCustomTeams then
						if teamIndex == 0 then
							humanName = "Players"
						elseif teamIndex == 1 then
							humanName = "Bots"
						else
							humanName = "Invalid"
						end
					else
						humanName = "Team " .. (teamIndex + 1)
					end
				end
				label:SetCaption(humanName)
			end

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
			
			function teamData.RemoveTeam()
				if teamIndex < emptyTeamIndex then
					emptyTeamIndex = teamIndex
				end

				team[teamIndex] = nil
				parentStack:RemoveChild(parentStack:GetChildByName(teamIndex))
				teamHolder:Dispose()
			end

			function teamData.CheckRemoval()
				if teamStack:IsEmpty() and teamIndex ~= -1 then
					local removeHolder = false
					
					if disallowCustomTeams then
						if teamIndex > 1 then
							teamData.RemoveTeam()
							return true
						elseif disallowBots and teamIndex > 0 then
							teamData.RemoveTeam()
							return true
						end
					else
						if teamIndex > 1 then
							local maxTeam = 0
							for teamID,_ in pairs(team) do
								maxTeam = math.max(teamID, maxTeam)
							end
							if teamIndex == maxTeam then
								teamData.RemoveTeam()
								return true
							end
						end
					end
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

				
				if not teamData.CheckRemoval() then
					teamHolder:Invalidate()
					PositionChildren(parentStack, parentScroll.height)
				end
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
	GetTeam(0) -- Always show two teams in custom battles
	if not (disallowCustomTeams and disallowBots) then
		GetTeam(1)
	end

	OpenNewTeam = function ()
		GetTeam(emptyTeamIndex)
		PositionChildren(mainStackPanel, mainScrollPanel.height)
	end

	mainScrollPanel.OnResize = {
		function (obj)
			PositionChildren(mainStackPanel, mainScrollPanel.height)
		end
	}
	spectatorScrollPanel.OnResize = {
		function ()
			PositionChildren(spectatorStackPanel, spectatorScrollPanel.height)
		end
	}

	local externalFunctions = {}
	
	function externalFunctions.UpdateBattleMode(newDisallowCustomTeams, newDisallowBots)
		disallowCustomTeams = newDisallowCustomTeams
		disallowBots = newDisallowBots
		
		if not (disallowCustomTeams and disallowBots) then
			GetTeam(1)
		end
		for teamIndex, teamData in pairs(team) do
			if not teamData.CheckRemoval() then
				teamData.UpdateBattleMode()
			end
		end
	end
	
	function externalFunctions.UpdateUserTeamStatus(userName, allyNumber, isSpectator)
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

	function externalFunctions.LeftBattle(leftBattleID, userName)
		if leftBattleID == battleID then
			RemovePlayerFromTeam(userName)
		end
	end

	function externalFunctions.RemoveAi(botName)
		RemovePlayerFromTeam(botName)
	end
	
	return externalFunctions
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
				ButtonUtilities.SetButtonSelected(obj)
				ButtonUtilities.SetButtonDeselected(buttonNo)
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
				file = IMG_READY,
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
				ButtonUtilities.SetButtonSelected(obj)
				ButtonUtilities.SetButtonDeselected(buttonYes)
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
				file = IMG_UNREADY,
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
	
	local externalFunctions = {}

	function externalFunctions.VoteUpdate(message, yesVotes, noVotes, votesNeeded)
		voteName:SetCaption(message)
		voteCountLabel:SetCaption(yesVotes .. "/" .. votesNeeded)
		voteProgress:SetValue(100 * yesVotes / votesNeeded)
		if not activePanel.visible then
			activePanel:Show()
		end
		HideVoteResult()
	end

	function externalFunctions.VoteEnd(message, success)
		if activePanel.visible then
			activePanel:Hide()
		end
		local text = ((success and WG.Chobby.Configuration:GetSuccessColor()) or WG.Chobby.Configuration:GetErrorColor()) .. message .. ((success and " Passed.") or " Failed.")
		voteResultLabel:SetCaption(text)
		if not voteResultLabel.visible then
			voteResultLabel:Show()
		end

		ButtonUtilities.SetButtonDeselected(buttonYes)
		ButtonUtilities.SetButtonDeselected(buttonNo)

		WG.Delay(HideVoteResult, 5)
	end
	
	return externalFunctions
end

local function InitializeControls(battleID, oldLobby, topPoportion)
	local battle = battleLobby:GetBattle(battleID)

	if not battle then
		Spring.Echo("Attempted to join missing battle", battleID, topPoportion)
		return false
	end
	
	if not WG.Chobby.Configuration.showMatchMakerBattles and battle.isMatchMaker then
		return
	end
	
	local EXTERNAL_PAD_VERT = 10
	local EXTERNAL_PAD_HOR = 15
	local INTERNAL_PAD = 2

	local BOTTOM_SPACING = 50

	mainWindow = Control:New {
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		resizable = false,
		padding = {0, 0, 0, 0},
	}
	
	local subPanel = Control:New {
		x = 0,
		y = 42,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		parent = mainWindow,
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
		padding = {EXTERNAL_PAD_HOR, EXTERNAL_PAD_VERT, INTERNAL_PAD, INTERNAL_PAD},
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

	local playerHandler = SetupPlayerPanel(playerPanel, spectatorPanel, battle, battleID)

	local votePanel = Control:New {
		x = 0,
		right = "33%",
		bottom = 0,
		height = BOTTOM_SPACING,
		padding = {EXTERNAL_PAD_HOR, INTERNAL_PAD, 1, INTERNAL_PAD},
		parent = topPanel,
	}

	local votePanel = SetupVotePanel(votePanel)
	
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

	local infoHandler = SetupInfoButtonsPanel(leftInfo, rightInfo, battle, battleID, battleLobby:GetMyUserName())

	local btnQuitBattle = Button:New {
		right = 7,
		y = 5,
		width = 80,
		height = 45,
		font =  WG.Chobby.Configuration:GetFont(3),
		caption = i18n("leave"),
		classname = "negative_button",
		OnClick = {
			function()
				battleLobby:LeaveBattle()
			end
		},
		parent = mainWindow,
	}

	local battleTitle = tostring(battle.title)
	if battle.battleMode then
		battleTitle = i18n(WG.Chobby.Configuration.battleTypeToName[battle.battleMode]) .. ": " .. battleTitle
	end

	local lblBattleTitle = Label:New {
		x = 18,
		y = 16,
		right = 100,
		height = 30,
		font = WG.Chobby.Configuration:GetFont(3),
		caption = "",
		parent = mainWindow,
		OnResize = {
			function (obj, xSize, ySize)
				obj:SetCaption(StringUtilities.GetTruncatedStringWithDotDot(battleTitle, obj.font, obj.width))
			end
		}
	}

	local function MessageListener(message)
		if message:starts("/me ") then
			battleLobby:SayBattleEx(message:sub(5))
		else
			battleLobby:SayBattle(message)
		end
	end
	local battleRoomConsole = WG.Chobby.Console("Battleroom Chat", MessageListener, true, nil, true)

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

	local CHAT_MENTION = "\255\255\0\0"
	local CHAT_ME = WG.Chobby.Configuration.meColor
	
	-- External Functions
	local externalFunctions = {}
	
	function externalFunctions.ClearChatHistory()
		battleRoomConsole:ClearHistory()
	end
	
	function externalFunctions.OnBattleClosed(listener, closedBattleID)
		if battleID == closedBattleID then
			mainWindow:Dispose()
			mainWindow = nil
			if wrapperControl and wrapperControl.visible and wrapperControl.parent then
				wrapperControl:Hide()
			end
		end
	end
	
	function externalFunctions.GetInfoHandler()
		return infoHandler
	end
	
	-- Lobby interface
	local function OnUpdateUserTeamStatus(listener, userName, allyNumber, isSpectator)
		infoHandler.UpdateUserTeamStatus(userName, allyNumber, isSpectator)
		playerHandler.UpdateUserTeamStatus(userName, allyNumber, isSpectator)
	end

	local function OnBattleIngameUpdate(listener, updatedBattleID, isRunning)
		infoHandler.BattleIngameUpdate(updatedBattleID, isRunning)
	end

	local function OnUpdateBattleInfo(listener, updatedBattleID, spectatorCount, locked, mapHash, mapName, 
			engineVersion, runningSince, gameName, battleMode, disallowCustomTeams, disallowBots, isMatchMaker, newPlayerList, maxPlayers, title)
		if (battleMode or title) and battleID == updatedBattleID then
			battleTitle = i18n(WG.Chobby.Configuration.battleTypeToName[battle.battleMode]) .. ": " .. tostring(battle.title)
			lblBattleTitle:SetCaption(battleTitle)
			
			if battleMode then
				playerHandler.UpdateBattleMode(disallowCustomTeams, disallowBots)
			end
		end
		
		infoHandler.UpdateBattleInfo(updatedBattleID, spectatorCount, locked, mapHash, mapName, engineVersion, runningSince, gameName, battleMode)
	end
	
	local function OnLeftBattle(listener, leftBattleID, userName)
		infoHandler.LeftBattle(leftBattleID, userName)
		playerHandler.LeftBattle(leftBattleID, userName)
	end

	local function OnJoinedBattle(listener, joinedBattleId, userName)
		infoHandler.JoinedBattle(joinedBattleId, userName)
	end
	
	local function OnRemoveAi(listener, botName)
		playerHandler.RemoveAi(botName)
	end
	
	local function OnVoteUpdate(listener, message, yesVotes, noVotes, votesNeeded)
		votePanel.VoteUpdate(message, yesVotes, noVotes, votesNeeded)
	end
	
	local function OnVoteEnd(listener, message, success)
		votePanel.VoteEnd(message, success)
	end
	
	local function OnSaidBattle(listener, userName, message)
		local myUserName = battleLobby:GetMyUserName()
		local iAmMentioned = myUserName and userName ~= myUserName and string.find(message, myUserName)
		local chatColour = (iAmMentioned and CHAT_MENTION) or nil
		battleRoomConsole:AddMessage(message, userName, false, chatColour, false)
	end

	local function OnSaidBattleEx(listener, userName, message)
		local myUserName = battleLobby:GetMyUserName()
		local iAmMentioned = myUserName and userName ~= myUserName and string.find(message, myUserName)
		local chatColour = (iAmMentioned and CHAT_MENTION) or CHAT_ME
		battleRoomConsole:AddMessage(message, userName, false, chatColour, true)
	end

	battleLobby:AddListener("OnUpdateUserTeamStatus", OnUpdateUserTeamStatus)
	battleLobby:AddListener("OnBattleIngameUpdate", OnBattleIngameUpdate)
	battleLobby:AddListener("OnUpdateBattleInfo", OnUpdateBattleInfo)
	battleLobby:AddListener("OnLeftBattle", OnLeftBattle)
	battleLobby:AddListener("OnJoinedBattle", OnJoinedBattle)
	battleLobby:AddListener("OnRemoveAi", OnRemoveAi)
	battleLobby:AddListener("OnVoteUpdate", OnVoteUpdate)
	battleLobby:AddListener("OnVoteEnd", OnVoteEnd)
	battleLobby:AddListener("OnSaidBattle", OnSaidBattle)
	battleLobby:AddListener("OnSaidBattleEx", OnSaidBattleEx)
	battleLobby:AddListener("OnBattleClosed", externalFunctions.OnBattleClosed)

	local function OnDisposeFunction()
		emptyTeamIndex = 0
		
		oldLobby:RemoveListener("OnUpdateUserTeamStatus", OnUpdateUserTeamStatus)
		oldLobby:RemoveListener("OnBattleIngameUpdate", OnBattleIngameUpdate)
		oldLobby:RemoveListener("OnUpdateBattleInfo", OnUpdateBattleInfo)
		oldLobby:RemoveListener("OnLeftBattle", OnLeftBattle)
		oldLobby:RemoveListener("OnJoinedBattle", OnJoinedBattle)
		oldLobby:RemoveListener("OnRemoveAi", OnRemoveAi)
		oldLobby:RemoveListener("OnVoteUpdate", OnVoteUpdate)
		oldLobby:RemoveListener("OnVoteEnd", OnVoteEnd)
		oldLobby:RemoveListener("OnSaidBattle", OnSaidBattle)
		oldLobby:RemoveListener("OnSaidBattleEx", OnSaidBattleEx)
		oldLobby:RemoveListener("OnBattleClosed", externalFunctions.OnBattleClosed)
	end
	
	mainWindow.OnDispose = mainWindow.OnDispose or {}
	mainWindow.OnDispose[#mainWindow.OnDispose + 1] = OnDisposeFunction
	
	return mainWindow, externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local BattleRoomWindow = {}

function BattleRoomWindow.ShowMultiplayerBattleRoom(battleID)
	
	if mainWindow then
		mainWindow:Dispose()
		mainWindow = nil
	end

	if multiplayerWrapper then
		WG.BattleStatusPanel.RemoveBattleTab()
		multiplayerWrapper:Dispose()
		multiplayerWrapper = nil
	end
	
	if singleplayerWrapper then
		singleplayerWrapper = nil
	end

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

					local battleWindow, functions = InitializeControls(battleID, battleLobby, 55)
					mainWindowFunctions = functions
					if battleWindow then
						obj:AddChild(battleWindow)
					end
				end
			end
		},
		OnHide = {
			function(obj)
				WG.BattleStatusPanel.RemoveBattleTab()
			end
		}
	}

	WG.BattleStatusPanel.AddBattleTab(multiplayerWrapper)

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

				if multiplayerWrapper then
					WG.BattleStatusPanel.RemoveBattleTab()
					
					if mainWindow then
						mainWindow:Dispose()
						mainWindow = nil
					end
					WG.LibLobby.lobby:LeaveBattle()
					multiplayerWrapper = nil
				elseif mainWindow then
					return
				end

				local singleplayerDefault = WG.Chobby.Configuration.gameConfig.skirmishDefault

				local defaultMap = Game.mapName or "Red Comet"
				if singleplayerDefault and singleplayerDefault.map then
					defaultMap = singleplayerDefault.map
				end

				battleLobby = WG.LibLobby.localLobby
				battleLobby:SetBattleState(lobby:GetMyUserName() or "Player", singleplayerGame, defaultMap, "Skirmish Battle")

				wrapperControl = obj

				local battleWindow, functions = InitializeControls(1, battleLobby, 70)
				mainWindowFunctions = functions
				if not battleWindow then
					return
				end
				
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
		WG.LibLobby.localLobby:LeaveBattle()
	end

	local function SetGameSucess(name)
		singleplayerGame = name
		ToggleShowFunc(battleroomObj, tabData)
	end

	local config = WG.Chobby.Configuration
	local skirmishGame = config.gameConfig.defaultGameArchiveName
	if skirmishGame then
		singleplayerGame = skirmishGame
		ToggleShowFunc(battleroomObj, tabData)
	else
		WG.Chobby.GameListWindow(SetGameFail, SetGameSucess)
	end
end

function BattleRoomWindow.LeaveBattle(onlyMultiplayer, onlySingleplayer)
	if not battleLobby then
		return
	end

	if onlyMultiplayer and battleLobby.name == "singleplayer" then
		return
	end
	
	if onlySingleplayer and battleLobby.name == "singleplayer" then
		if mainWindow then
			mainWindow:Dispose()
			mainWindow = nil
		end
		return
	end
	
	battleLobby:LeaveBattle()
	if mainWindowFunctions then
		mainWindowFunctions.OnBattleClosed(_, battleLobby:GetMyBattleID())
	end
	
	WG.BattleStatusPanel.RemoveBattleTab()
end

function BattleRoomWindow.ClearChatHistory()
	if mainWindowFunctions and mainWindowFunctions.ClearChatHistory then
		mainWindowFunctions.ClearChatHistory()
	end
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.BattleRoomWindow = BattleRoomWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
