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

local function GetUserCountryImage(userName)
	local userInfo = lobby:GetUser(userName) or {}
	if userInfo.country then
		local fileName = "luaui/images/flags/" .. string.lower(userInfo.country) .. ".png"
		if VFS.FileExists(fileName) then
			return fileName
		end
	end
	return "luaui/images/flags/unknown.png"
end

local function GetUserRankImageName(userName)
	local userInfo = lobby:GetUser(userName) or {}
	if userInfo.isBot or userInfo.aiLib then
		return "luaui/images/ranks/robot.png"
	elseif userInfo.isAdmin then
		return "luaui/images/ranks/moderator.png"
	elseif userInfo.level then
		local rankBracket = math.min(8, math.floor(userInfo.level/10)) + 1
		return "luaui/images/ranks/" .. rankBracket .. ".png"
	end
end

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
			--userList[userName].status:SetCaption(activity)
		end
	end
end

local function GetUserControls(userName, reinitialize)
	local userControls = reinitialize or {}
	
	if reinitialize then
		userControls.mainControl:ClearChildren()
	else
		userControls.mainControl = Button:New {
			name = userName,
			x = 0,
			y = 0,
			right = 0,
			height = 23,
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
	end
	
	userControls.status = Label:New {
		name = "status",
		x = 2,
		y = 0,
		right = 0,
		bottom = 4,
		valign = "bottom",
		align = "left",
		parent = userControls.mainControl,
		font = WG.Chobby.Configuration:GetFont(1),
		caption = "", --GetUserActivity(userName),
	}
	
	userControls.country = Image:New {
		name = "country",
		x = 1,
		y = 3,
		width = 21,
		height = 19,
		parent = userControls.mainControl,
		keepAspect = true,
		file = GetUserCountryImage(userName),
	}
	userControls.level = Image:New {
		name = "level",
		x = 26,
		y = 3,
		width = 19,
		height = 19,
		parent = userControls.mainControl,
		keepAspect = true,
		file = GetUserRankImageName(userName),
	}
	userControls.name = TextBox:New {
		name = "name",
		x = 50,
		y = 6,
		right = 0,
		bottom = 2,
		align = "left",
		parent = userControls.mainControl,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = userName,
	}
	
	userControls.needReinitialization = lobby.status ~= "connected"
	
	return userControls
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local userHandler = {}

function userHandler.GetBattleUser(userName, isSingleplayer)
	if battleUsers[userName] then
		if battleUsers[userName].needReinitialization then
			battleUsers[userName] = GetUserControls(userName, battleUsers[userName])
		end
		return battleUsers[userName].mainControl
	end
	
	battleUsers[userName] = GetUserControls(userName)
	return battleUsers[userName].mainControl
end

function userHandler.GetChannelUser(userName)		
	if channelUsers[userName] then
		if channelUsers[userName].needReinitialization then
			channelUsers[userName] = GetUserControls(userName, channelUsers[userName])
		end
		return channelUsers[userName].mainControl
	end
	
	channelUsers[userName] = GetUserControls(userName)
	return channelUsers[userName].mainControl
end

function userHandler.GetTeamUser(userName)		
	if teamUsers[userName] then
		if teamUsers[userName].needReinitialization then
			teamUsers[userName] = GetUserControls(userName, teamUsers[userName])
		end
		return teamUsers[userName].mainControl
	end
	
	teamUsers[userName] = GetUserControls(userName)
	return teamUsers[userName].mainControl
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Connection

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