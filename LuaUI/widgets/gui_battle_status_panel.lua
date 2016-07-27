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

local BATTLE_RUNNING = "luaui/images/runningBattle.png"
local BATTLE_NOT_RUNNING = ""

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
	
	local lblPlayers = Label:New {
		name = "playersCaption",
		x = 70,
		width = 240,
		y = 20,
		height = 20,
		valign = 'top',
		font = Configuration:GetFont(2),
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
		file = (battle.isRunning and BATTLE_RUNNING) or BATTLE_NOT_RUNNING,
		parent = mainControl,
	}
	runningImage:BringToFront()
	
	function externalFunctions.Resize(smallMode)
		if smallMode then
			minimapImage:SetPos(nil, nil, 33, 33)
			runningImage:SetPos(nil, nil, 33, 33)
			
			lblTitle.font.size = Configuration:GetFont(1).size
			lblTitle:SetPos(35, 1, 160)
			
			lblPlayers.font.size = Configuration:GetFont(1).size
			lblPlayers:SetPos(35, 20, 160)
		else
			minimapImage:SetPos(nil, nil, 63, 63)
			runningImage:SetPos(nil, nil, 63, 63)
			
			lblTitle.font.size = Configuration:GetFont(2).size
			lblTitle:SetPos(70, 4, 240)
			
			lblPlayers.font.size = Configuration:GetFont(2).size
			lblPlayers:SetPos(70, 32, 240)
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
		
		runningImage.file = (battle.isRunning and BATTLE_RUNNING) or BATTLE_NOT_RUNNING
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
		runningImage.file = (battle.isRunning and BATTLE_RUNNING) or BATTLE_NOT_RUNNING
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
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local battleInfoHolder

local function InitializeControls(parentControl)
	local statusWindowHandler = WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler()

	local infoHolder = Panel:New {
		x = 5,
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
		x = 320,
		width = 105,
		y = 12,
		height = 20,
		align = "left",
		valign = "center",
		caption = "Battle:",
		parent = parentControl,
		font = WG.Chobby.Configuration:GetFont(3),
	}
	local lblPlayerStatus = Label:New {
		name = "lblPlayerStatus",
		x = 320,
		width = 105,
		y = 38,
		height = 20,
		align = "left",
		valign = "center",
		caption = "Spectator",
		parent = parentControl,
		font = WG.Chobby.Configuration:GetFont(3),
	}
	
	battleInfoHolder = GetBattleInfoHolder(infoHolder, lobby:GetMyBattleID())
	
	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function (obj, xSize, ySize)
		local smallMode = (ySize < 60)
		if smallMode then
			if lblBattle.visible then
				lblBattle:Hide()
			end
			lblPlayerStatus:SetPos(210, 13)
			infoHolder:SetPos(nil, nil, 200)
		else
			if not lblBattle.visible then
				lblBattle:Show()
			end
			lblPlayerStatus:SetPos(320, 38)
			infoHolder:SetPos(nil, nil, 310)
		end
		battleInfoHolder.Resize(smallMode)
	end
	
	local unreadMessages = 0
	
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
	
	onUpdateUserTeamStatus = function(listener, userName, allyNumber, isSpectator)
		if userName == lobby:GetMyUserName() then
			if isSpectator then
				lblPlayerStatus:SetCaption("Spectator")
			else
				lblPlayerStatus:SetCaption("Player")
			end
		end
	end
	lobby:AddListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatus)
	
	local function onJoinBattle(listener, battleID)	
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
		lobby:RemoveListener("OnUpdateUserTeamStatus", onUpdateUserTeamStatusSelf)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
