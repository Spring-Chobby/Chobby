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

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local function AddListeners()

end

local function RemoveListeners()

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function GetUserControl(userName)

	local button = Button:New {
		name = userName,
		x = 0,
		y = 0,
		width = 150,
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
	
	local name = Label:New {
		name = userName,
		x = 30,
		y = 0,
		right = 0,
		bottom = 4,
		valign = "center",
		align = "left",
		parent = button,
		font = {size = 17, shadow = false},
		caption = userName,
	}
	
	return button
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local userHandler = {}

function userHandler.GetBattleUser(userName)		
	if battleUsers[userName] then
		return battleUsers[userName]
	end
	
	battleUsers[userName] = Label:New { 
		name = userName,
		x = 5,
		y = 0,
		width = 200,
		height = 30,
		font = {size = 15},
		caption = userName,
	}
	
	return battleUsers[userName]
end

function userHandler.GetChannelUser(userName)		
	if channelUsers[userName] then
		return channelUsers[userName]
	end
	
	channelUsers[userName] = GetUserControl(userName)
	return channelUsers[userName]
end

function userHandler.GetTeamUser(userName)		
	if teamUsers[userName] then
		return teamUsers[userName]
	end
	
	teamUsers[userName] = Button:New {
		name = userName,
		x = 0,
		width = 100,
		y = 0,
		height = 30,
		caption = userName,
	}
	return teamUsers[userName]
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

function widget:Shutdown()
	if WG.LibLobby then
		RemoveListeners()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------