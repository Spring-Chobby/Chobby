--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Battle status panel",
		desc      = "Displays battles status.",
		author    = "gajop",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local IMG_BATTLE_RUNNING     = "luaui/images/runningBattle.png"
local IMG_BATTLE_NOT_RUNNING = ""
local IMG_STATUS_SPECTATOR   = "luaui/images/spectating.png"
local IMG_STATUS_PLAYER      = "luaui/images/playing.png"

------------------------------------------------------------------
------------------------------------------------------------------
-- Info Handlers

local function GetBattleInfoHolder(parent, battleID)
	local externalFunctions = {}
	
	local battle = lobby:GetBattle(battleID)
	if not battle then
		return nil
	end
	
	local Configuration = WG.Chobby.Configuration
	
	local mainControl = Control:New {
		x = 0,
		y = offset,
		right = 0,
		height = 120,
		padding = {0, 0, 0, 0},
		parent = parent,
	}
	
	local lblTitle = Label:New {
		name = "title",
		x = 70,
		y = 1,
		width = 245,
		height = 20,
		valign = 'top',
		font = Configuration:GetFont(2),
		parent = mainControl,
	}
	local text = StringUtilities.GetTruncatedStringWithDotDot(battle.title, lblTitle.font, lblTitle.width)
	lblTitle:SetCaption(text)

	local lblPlayerStatus = Label:New {
		name = "lblPlayerStatus",
		x = 90,
		width = 240,
		y = 28,
		height = 20,
		valign = 'top',
		caption = "Spectator",
		parent = mainControl,
		font = WG.Chobby.Configuration:GetFont(2),
	}
	local imPlayerStatus = Image:New {
		name = "imPlayerStatus",
		x = 68,
		width = 20,
		y = 25,
		height = 20,
		file = IMG_STATUS_SPECTATOR,
		parent = mainControl,
	}
	
	local lblPlayers = Label:New {
		name = "playersCaption",
		x = 70,
		width = 240,
		y = 50,
		height = 20,
		valign = 'top',
		font = Configuration:GetFont(1),
		caption = "Players: " .. (#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers,
		parent = mainControl,
	}
	
	local minimapImage = Image:New {
		name = "minimapImage",
		x = 1,
		y = 1,
		width = 33,
		height = 33,
		keepAspect = true,
		file = Configuration:GetMinimapImage(battle.mapName, battle.gameName),
		parent = mainControl,
	}
	local runningImage = Image:New {
		name = "runningImage",
		x = 1,
		y = 1,
		width = 38,
		height = 38,
		keepAspect = false,
		file = (battle.isRunning and IMG_BATTLE_RUNNING) or IMG_BATTLE_NOT_RUNNING,
		parent = mainControl,
	}
	runningImage:BringToFront()
	imPlayerStatus:BringToFront()
	
	function externalFunctions.Resize(smallMode)
		if smallMode then
			minimapImage:SetPos(nil, nil, 33, 33)
			runningImage:SetPos(nil, nil, 33, 33)
			
			lblTitle.font.size = Configuration:GetFont(1).size
			lblTitle:SetPos(35, 1, 160)
		else
			minimapImage:SetPos(nil, nil, 63, 63)
			runningImage:SetPos(nil, nil, 63, 63)
			
			lblTitle.font.size = Configuration:GetFont(2).size
			lblTitle:SetPos(70, 4, 240)
		end
		local text = StringUtilities.GetTruncatedStringWithDotDot(battle.title, lblTitle.font, lblTitle.width)
		lblTitle:SetCaption(text)
	end
	
	function externalFunctions.Update(newBattleID)
		battleID = newBattleID
		battle = lobby:GetBattle(battleID)
		if not battle then
			return
		end
		
		if not mainControl.visible then
			mainControl:Show()
		end
		
		local text = StringUtilities.GetTruncatedStringWithDotDot(battle.title, lblTitle.font, lblTitle.width)
		lblTitle:SetCaption(text)
		
		minimapImage.file = Configuration:GetMinimapImage(battle.mapName, battle.gameName)
		minimapImage:Invalidate()
		
		runningImage.file = (battle.isRunning and IMG_BATTLE_RUNNING) or IMG_BATTLE_NOT_RUNNING
		runningImage:Invalidate()
	end
	
	local function OnUpdateBattleInfo(listeners, updatedBattleID)
		if updatedBattleID ~= battleID then
			return
		end
		minimapImage.file = Configuration:GetMinimapImage(battle.mapName, battle.gameName)
		minimapImage:Invalidate()
		
		lblPlayers:SetCaption("Players: " .. (#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers)
	end
	lobby:AddListener("OnUpdateBattleInfo", OnUpdateBattleInfo)
	
	local function OnBattleIngameUpdate(listeners, updatedBattleID)
		if updatedBattleID ~= battleID then
			return
		end
		runningImage.file = (battle.isRunning and IMG_BATTLE_RUNNING) or IMG_BATTLE_NOT_RUNNING
		runningImage:Invalidate()
	end
	lobby:AddListener("OnBattleIngameUpdate", OnBattleIngameUpdate)
	
	local function PlayersUpdate(listeners, battleID)
		if updatedBattleID ~= battleID then
			return
		end
		lblPlayers:SetCaption("Players: " .. (#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers)
	end
	lobby:AddListener("OnLeftBattle", PlayersUpdate)
	lobby:AddListener("OnJoinedBattle", PlayersUpdate)
	
	local function OnUpdateUserTeamStatus(listeners)
		lblPlayers:SetCaption("Players: " .. (#battle.users - battle.spectatorCount) .. "/" .. battle.maxPlayers)
	end
	lobby:AddListener("OnUpdateUserTeamStatus", OnUpdateUserTeamStatus)

	onUpdateUserTeamStatus = function(listener, userName, allyNumber, isSpectator)
		if userName == lobby:GetMyUserName() then
			if isSpectator then
				lblPlayerStatus:SetCaption("Spectator")
				imPlayerStatus.file = IMG_STATUS_SPECTATOR
				imPlayerStatus:Invalidate()
			else
				lblPlayerStatus:SetCaption("Player")
				imPlayerStatus.file = IMG_STATUS_PLAYER
				imPlayerStatus:Invalidate()
			end
		end
	end
	lobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatus)
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local battleInfoHolder

local function InitializeControls(parentControl)
	local statusWindowHandler = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()

	local infoHolder = Panel:New {
		x = 90,
		width = 310,
		y = 5,
		bottom = 5,
		parent = parentControl,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	local lblBattle = Label:New {
		name = "lblBattle",
		x = 15,
		width = 85,
		y = 22,
		height = 20,
		align = "left",
		valign = "center",
		caption = "Battle",
		parent = parentControl,
		font = WG.Chobby.Configuration:GetFont(3),
	}
	
	battleInfoHolder = GetBattleInfoHolder(infoHolder, lobby:GetMyBattleID())
	
	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function (obj, xSize, ySize)
		local smallMode = (ySize < 60)
		if smallMode then
			infoHolder:SetPos(nil, nil, 200)
		else
			infoHolder:SetPos(nil, nil, 310)
		end
		battleInfoHolder.Resize(smallMode)
	end
	
	local unreadMessages = 0
	
	parentControl.tooltip = "battle_tooltip_" .. (lobby:GetMyBattleID() or 0)
	
	parentControl.OnClick = parentControl.OnClick or {}
	parentControl.OnClick[#parentControl.OnClick + 1] = function (obj)
		if unreadMessages > 0 then
			unreadMessages = 0
			statusWindowHandler.SetActivity("myBattle", unreadMessages)
		end
	end
	
	local function OnSaidBattle(listeners, userName)
		local userInfo = lobby:GetUser(userName) or {}
		if userInfo.isBot then
			return
		end
		if statusWindowHandler.IsTabSelected("myBattle") then
			if unreadMessages > 0 then
				unreadMessages = 0
				statusWindowHandler.SetActivity("myBattle", unreadMessages)
			end
			return
		end
		unreadMessages = unreadMessages + 1
		statusWindowHandler.SetActivity("myBattle", unreadMessages)
	end
	lobby:AddListener("OnSaidBattle", OnSaidBattle)
	lobby:AddListener("OnSaidBattleEx", OnSaidBattle)
	
	local function onJoinBattle(listener, battleID)	
		parentControl.tooltip = "battle_tooltip_" .. battleID
		battleInfoHolder.Update(battleID)
	end
	lobby:AddListener("OnJoinBattle", onJoinBattle)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local BattleStatusPanel = {}

function BattleStatusPanel.GetControl()
	local button = Button:New {
		x = 0,
		y = 0,
		width = 340,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return button
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.BattleStatusPanel = BattleStatusPanel
end

function widget:Shutdown()
	if lobby then
		lobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatus)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
