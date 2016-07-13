--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Users Handler",
		desc      = "Handles user visualisation and interaction.",
		author    = "GoogleFrog",
		date      = "11 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

local battleUsers = {}
local channelUsers = {}
local teamUsers = {}

local userListList = {
	battleUsers,
	channelUsers,
	teamUsers
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function GetUserActivity(userName)
	local userInfo = lobby:GetUser(userName) or {}
	if userInfo.isInGame then
		return "Ingame"
	elseif userInfo.isAway then
		if userInfo.battleID then
			return "BatAFK"
		else
			return "AFK"
		end
	elseif userInfo.battleID then
		return "Battle"
	end
	return "Lobby"
end

local function UpdateUserActivity(listener, userName)
	local activity = GetUserActivity(userName)
	for i = 1, #userListList do
		local userList = userListList[i]
		if userList[userName] then
			userList[userName].status:SetCaption(activity)
		end
	end
end

local function GetUserControls(userName)
	local userControls = {}
	
	userControls.mainControl = Button:New {
		name = userName,
		x = 0,
		y = 0,
		right = 0,
		height = 25,
		caption = "",
		backgroundColor = {0, 0, 0, 0},
		borderColor = {0, 0, 0, 0},
		padding = {0, 0, 0, 0},
		OnClick = {
			function()
				WG.Chobby.interfaceRoot.GetChatWindow():GetPrivateChatConsole(userName)
			end
		},
		parent = screen0
	}
	
	userControls.name = Label:New {
		name = "name",
		x = 50,
		y = 0,
		right = 0,
		bottom = 4,
		valign = "center",
		align = "left",
		parent = userControls.mainControl,
		font = WG.Chobby.Configuration:GetFont(2),
		caption = userName,
	}
	
	userControls.status = Label:New {
		name = "status",
		x = 2,
		y = 0,
		right = 0,
		bottom = 4,
		valign = "center",
		align = "left",
		parent = userControls.mainControl,
		font = WG.Chobby.Configuration:GetFont(1),
		caption = GetUserActivity(userName),
	}
	
	return userControls
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local userHandler = {}

function userHandler.GetBattleUser(userName)		
	if battleUsers[userName] then
		return battleUsers[userName].mainControl
	end
	
	battleUsers[userName] = GetUserControls(userName)
	return battleUsers[userName].mainControl
end

function userHandler.GetChannelUser(userName)		
	if channelUsers[userName] then
		return channelUsers[userName].mainControl
	end
	
	channelUsers[userName] = GetUserControls(userName)
	return channelUsers[userName].mainControl
end

function userHandler.GetTeamUser(userName)		
	if teamUsers[userName] then
		return teamUsers[userName].mainControl
	end
	
	teamUsers[userName] = GetUserControls(userName)
	return teamUsers[userName].mainControl
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local function AddListeners()
	lobby:AddListener("OnUpdateUserStatus", UpdateUserActivity)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	AddListeners()
	
	WG.UserHandler = userHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------