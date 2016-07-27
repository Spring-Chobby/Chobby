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
		x = 38,
		y = 1,
		right = 0,
		height = 20,
		valign = 'top',
		font = Configuration:GetFont(1),
		caption = battle.title:sub(1, 60),
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
			lblTitle:SetPos(35, 1)
		else
			minimapImage:SetPos(nil, nil, 63, 63)
			runningImage:SetPos(nil, nil, 63, 63)
			
			lblTitle.font.size = Configuration:GetFont(2).size
			lblTitle:SetPos(70, 4)
		end
	end
	
	function externalFunctions.Update(battleID)
		battle = lobby:GetBattle(battleID)
		if not battle then
			return
		end
		
		if not mainControl.visible then
			mainControl:Show()
		end
		
		lblTitle:SetCaption(battle.title:sub(1, 60))
		
		minimapImage.file = Configuration:GetMinimapImage(battle.mapName, battle.gameName)
		minimapImage:Invalidate()
		
		runningImage.file = (battle.isRunning and BATTLE_RUNNING) or BATTLE_NOT_RUNNING
		runningImage:Invalidate()
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local battleInfoHolder

local function InitializeControls(parentControl)
	local font = WG.Chobby.Configuration:GetFont(3)
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
	local lblPlayerStatus = Label:New {
		x = 240,
		width = 105,
		y = 15,
		height = 20,
		align = "left",
		valign = "center",
		caption = "Spectator",
		parent = parentControl,
		font = font,
	}
	
	battleInfoHolder = GetBattleInfoHolder(infoHolder, lobby:GetMyBattleID())
	
	parentControl.OnResize = parentControl.OnResize or {}
	parentControl.OnResize[#parentControl.OnResize + 1] = function (obj, xSize, ySize)
		local smallMode = (ySize < 60)
		if smallMode then
			lblPlayerStatus:SetPos(210, 13)
			infoHolder:SetPos(nil, nil, 200)
		else
			lblPlayerStatus:SetPos(320, 25)
			infoHolder:SetPos(nil, nil, 310)
		end
		battleInfoHolder.Resize(smallMode)
	end

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

--	if string.find(message, lobby:GetMyUserName()) and userName ~= lobby:GetMyUserName() then
--		unreadMessages = unreadMessages + 1
--		WG.Chobby.interfaceRoot.GetBattleStatusWindowHandler().SetActivity("myBattle", unreadMessages)
--	end
----[[
--	Chotify:Post({
--		title = userName .. " in " .. chanName .. ":",
--		body = message,
--		sound = sound,
--		time = notificationTime,
--	})]]

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
