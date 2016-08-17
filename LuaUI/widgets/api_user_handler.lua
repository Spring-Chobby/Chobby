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
local tooltipUsers = {}
local singleplayerUsers = {}
local channelUsers = {}
local teamUsers = {}
local statusUsers = {}
local friendUsers = {}
local notificationUsers = {}

local userListList = {
	battleUsers,
	tooltipUsers,
	singleplayerUsers,
	channelUsers,
	teamUsers,
	statusUsers,
	friendUsers,
	notificationUsers,
}

local IMAGE_AFK = "luaui/images/away.png"
local IMAGE_BATTLE = "luaui/images/battle.png"
local IMAGE_INGAME = "luaui/images/ingame.png"
local IMAGE_FLAG_UNKNOWN = "luaui/images/flags/unknown.png"
local IMAGE_AUTOHOST = "luaui/images/ranks/robot.png"
local IMAGE_MODERATOR = "luaui/images/ranks/moderator.png"
local IMAGE_PLAYER = "luaui/images/ranks/player.png"
local IMAGE_READY = "luaui/images/ready.png"
local IMAGE_UNREADY = "luaui/images/unready.png"

local USER_SP_TOOLTIP_PREFIX = "user_single_"
local USER_MP_TOOLTIP_PREFIX = "user_battle_"
local USER_CH_TOOLTIP_PREFIX = "user_chat_s_"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Globally Applicable Utilities

local function CountryShortnameToFlag(shortname)
	local fileName = "luaui/images/flags/" .. string.lower(shortname) .. ".png"
	if VFS.FileExists(fileName) then
		return fileName
	end
end

local function UserLevelToImage(level, isBot, isAdmin, rank)
	if isBot then
		return IMAGE_AUTOHOST
	elseif isAdmin then
		return IMAGE_MODERATOR
	elseif level or rank then
		local rankBracket = rank
		if not rankBracket then
			if level < 60 then
				rankBracket = math.min(12, math.floor(level/5) + 1)
			else
				rankBracket = math.min(21, math.floor(level/10) + 7)
			end
		end
		return "luaui/images/ranks/" .. rankBracket .. ".png"
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities that reference controls

local function GetUserCountryImage(userName, userControl)
	local userInfo = userControl.lobby:GetUser(userName) or {}
	local userBattleInfo = userControl.lobby:GetUserBattleStatus(userName) or {}
	if userInfo.country then
		return CountryShortnameToFlag(userInfo.country)
	end
	if not userBattleInfo.aiLib then
		return IMAGE_FLAG_UNKNOWN
	end
end

local function GetUserSyncStatus(userName, userControl)
	local userBattleInfo = userControl.lobby:GetUserBattleStatus(userName) or {}
	if userBattleInfo.aiLib then
		return
	end
	if userBattleInfo.sync == 1 then
		return IMAGE_READY
	else
		return IMAGE_UNREADY
	end
end

local function GetUserComboBoxOptions(userName, isInBattle, userControl)
	local userInfo = userControl.lobby:GetUser(userName) or {}
	local userBattleInfo = userControl.lobby:GetUserBattleStatus(userName) or {}
	local myUserName = userControl.lobby:GetMyUserName()
	local comboOptions = {}
	if (not userBattleInfo.aiLib) and userName ~= myUserName then
		comboOptions[#comboOptions + 1] = "Message"
		
		if (not isInBattle) and userInfo.battleID then
			local battle = lobby:GetBattle(userInfo.battleID)
			if battle and WG.Chobby.Configuration:IsValidEngineVersion(battle.engineVersion) then
				comboOptions[#comboOptions + 1] = "Join Battle"
			end
		end
		
		if userInfo.isFriend then
			comboOptions[#comboOptions + 1] = "Unfriend"
		else
			comboOptions[#comboOptions + 1] = "Friend"
		end
		comboOptions[#comboOptions + 1] = "Report"
		comboOptions[#comboOptions + 1] = "Ignore"
	end
	
	if (userBattleInfo.aiLib and userBattleInfo.owner == myUserName) or userControl.lobby:GetMyIsAdmin() then
		comboOptions[#comboOptions + 1] = "Kick"
	end
	
	if #comboOptions == 0 then
		comboOptions[1] = Label:New {
			x = 0,
			y = 0,
			width = 100,
			height = 30,
			font = WG.Chobby.Configuration:GetFont(1),
			caption = "No Actions",
		}
	end
	
	return comboOptions
end

local function GetUserRankImageName(userName, userControl)
	local userInfo = userControl.lobby:GetUser(userName) or {}
	local userBattleInfo = userControl.lobby:GetUserBattleStatus(userName) or {}
	
	if userControl.isSingleplayer and not userBattleInfo.aiLib then
		return IMAGE_PLAYER
	end
	return UserLevelToImage(userInfo.level, userInfo.isBot or userBattleInfo.aiLib, userInfo.isAdmin, userInfo.rank)
end

local function GetUserStatusImages(userName, isInBattle, userControl)
	local userInfo = userControl.lobby:GetUser(userName) or {}
	if userInfo.isInGame or (userInfo.battleID and not isInBattle) then
		if userInfo.isInGame then
			return IMAGE_INGAME, (userInfo.isAway and IMAGE_AFK)
		else
			return IMAGE_BATTLE, (userInfo.isAway and IMAGE_AFK)
		end
	elseif userInfo.isAway then
		return IMAGE_AFK
	end
end

local function UpdateUserActivity(listener, userName)
	for i = 1, #userListList do
		local userList = userListList[i]
		local data = userList[userName]
		if data then
			data.mainControl.items = GetUserComboBoxOptions(userName, data.isInBattle, data)
			
			local status1, status2 = GetUserStatusImages(userName, data.isInBattle, data)
			data.statusFirst.file = status1
			data.statusSecond.file = status2
			data.statusFirst:Invalidate()
			data.statusSecond:Invalidate()
		end
	end
end

local function UpdateUserBattleStatus(listener, userName)
	for i = 1, #userListList do
		local userList = userListList[i]
		local data = userList[userName]
		if data then
			if data.syncStatus then
				data.syncStatus.file = GetUserSyncStatus(userName, data)
				data.syncStatus:Invalidate()
			end
		end
	end
end

local function UpdateUserCountry(listener, userName, country)
	for i = 1, #userListList do
		local userList = userListList[i]
		local data = userList[userName]
		if data then
			data.country.file = GetUserCountryImage(userName, data)
			data.country:Invalidate()
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Control Handling

local function GetUserControls(userName, opts)
	local autoResize         = opts.autoResize
	local maxNameLength      = opts.maxNameLength
	local isInBattle         = opts.isInBattle
	local isSingleplayer     = opts.isSingleplayer
	local reinitialize       = opts.reinitialize
	local disableInteraction = opts.disableInteraction
	local supressSync        = opts.supressSync

	local userControls = reinitialize or {}
	
	userControls.isInBattle = isInBattle
	userControls.lobby = (isSingleplayer and WG.LibLobby.localLobby) or lobby
	userControls.isSingleplayer = isSingleplayer 
	
	local offset = 0
	
	if reinitialize then
		userControls.mainControl:ClearChildren()
	else
		local tooltip = ((isSingleplayer and USER_SP_TOOLTIP_PREFIX) or (isInBattle and USER_MP_TOOLTIP_PREFIX) or USER_CH_TOOLTIP_PREFIX) .. userName
	
		local ControlType = ComboBox
		if disableInteraction then
			ControlType = Control
		end
	
		userControls.mainControl = ControlType:New {
			name = userName,
			x = 0,
			y = 0,
			right = 0,
			height = 22,
			backgroundColor = {0, 0, 0, 0},
			borderColor = {0, 0, 0, 0},
			padding = {0, 0, 0, 0},
			caption = "",
			tooltip = (not disableInteraction) and tooltip,
			ignoreItemCaption = true,
			selectByName = true,
			itemFontSize = WG.Chobby.Configuration:GetFont(2).size,
			itemHeight = 30,
			selected = 0,
			maxDropDownWidth = 120,
			minDropDownHeight = 0,
			items = GetUserComboBoxOptions(userName, isInBattle, userControls),
			OnOpen = {
				function (obj)
					obj.tooltip = nil
				end
			},
			OnClose = {
				function (obj)
					obj.tooltip = tooltip
				end
			},
			OnSelectName = {
				function (obj, selectedName)
					if selectedName == "Message" then
						local chatWindow = WG.Chobby.interfaceRoot.GetChatWindow()
						chatWindow.switchToTab = userName
						chatWindow:GetPrivateChatConsole(userName)
					elseif selectedName == "Kick" then
						local userBattleInfo = userControls.lobby:GetUserBattleStatus(userName) or {}
						if userBattleInfo and userBattleInfo.aiLib then
							userControls.lobby:RemoveAi(userName)
						else
							Spring.Echo("TODO - Implement player kick.")
						end
					elseif selectedName == "Unfriend" then
						userControls.lobby:Unfriend(userName)
					elseif selectedName == "Friend" then
						local userInfo = userControls.lobby:GetUser(userName)
						if userInfo and userInfo.hasFriendRequest then
							userControls.lobby:AcceptFriendRequest(userName)
						else
							
							userControls.lobby:FriendRequest(userName)
						end
					elseif selectedName == "Join Battle" then
						local userInfo = userControls.lobby:GetUser(userName) or {}
						if userInfo.battleID then
							-- TODO: Passworded battles
							WG.BattleRoomWindow.LeaveBattle()
							userControls.lobby:JoinBattle(userInfo.battleID)
						end
					elseif selectedName == "Report" then
						Spring.Echo("TODO - Open the right webpage")
					elseif selectedName == "Ignore" then
						userControls.lobby:Ignore(userName)
					end
				end
			}
		}
	end
	
	if isInBattle and not supressSync then
		offset = offset + 1
		userControls.syncStatus = Image:New {
			name = "syncStatus",
			x = offset,
			y = 1,
			width = 21,
			height = 19,
			parent = userControls.mainControl,
			keepAspect = true,
			file = GetUserSyncStatus(userName, userControls),
		}
		offset = offset + 23
	end
	
	if not isSingleplayer then
		offset = offset + 1
		userControls.country = Image:New {
			name = "country",
			x = offset,
			y = 1,
			width = 21,
			height = 19,
			parent = userControls.mainControl,
			keepAspect = true,
			file = GetUserCountryImage(userName, userControls),
		}
		offset = offset + 23
	end
	
	offset = offset + 2
	userControls.level = Image:New {
		name = "level",
		x = offset,
		y = 1,
		width = 19,
		height = 19,
		parent = userControls.mainControl,
		keepAspect = true,
		file = GetUserRankImageName(userName, userControls),
	}
	offset = offset + 23
	
	offset = offset + 1
	userControls.name = TextBox:New {
		name = "name",
		x = offset,
		y = 4,
		right = 0,
		bottom = 4,
		align = "left",
		parent = userControls.mainControl,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = userName,
	}
	local userNameStart = offset
	local truncatedName = StringUtilities.TruncateStringIfRequiredAndDotDot(userName, userControls.name.font, maxNameLength)
	if truncatedName then
		userControls.name:SetText(truncatedName)
	end
	offset = offset + userControls.name.font:GetTextWidth(userControls.name.text)
	
	local status1, status2 = GetUserStatusImages(userName, isInBattle, userControls)
	offset = offset + 3
	userControls.statusFirst = Image:New {
		name = "statusFirst",
		x = offset,
		y = 1,
		width = 19,
		height = 19,
		parent = userControls.mainControl,
		keepAspect = true,
		file = status1,
	}
	offset = offset + 20
	
	offset = offset + 1
	userControls.statusSecond = Image:New {
		name = "statusSecond",
		x = offset,
		y = 1,
		width = 19,
		height = 19,
		parent = userControls.mainControl,
		keepAspect = true,
		file = status2,
	}
	offset = offset + 20
	
	if autoResize then
		userControls.mainControl.OnResize = userControls.mainControl.OnResize or {}
		userControls.mainControl.OnResize[#userControls.mainControl.OnResize + 1] = function (obj, sizeX, sizeY)
			local maxWidth = sizeX - userNameStart - 40
			local truncatedName = StringUtilities.GetTruncatedStringWithDotDot(userName, userControls.name.font, maxWidth)
			userControls.name:SetText(truncatedName)
			
			offset = userNameStart + userControls.name.font:GetTextWidth(userControls.name.text) + 3
			userControls.statusFirst:SetPos(offset)
			offset = offset + 21
			userControls.statusSecond:SetPos(offset)
		end
	end
	
	-- This is always checked against main lobby.
	userControls.needReinitialization = lobby.status ~= "connected"
	
	return userControls
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local userHandler = {
	CountryShortnameToFlag = CountryShortnameToFlag,
	UserLevelToImage = UserLevelToImage,
}

local function _GetUser(userList, userName, opts)
	opts.reinitialize = userList[userName]
	if not userList[userName] or userList[userName].needReinitialization then
		userList[userName] = GetUserControls(userName, opts)
	end
	return userList[userName].mainControl
end

function userHandler.GetBattleUser(userName, isSingleplayer)
	if isSingleplayer then
		return userHandler.GetSingleplayerUser(userName)
	end

	return _GetUser(battleUsers, userName, {
		autoResize     = true,
		isInBattle     = true,
	})
end

function userHandler.GetTooltipUser(userName)
	return _GetUser(tooltipUsers, userName, {
		isInBattle     = true,
		supressSync    = true,
	})
end

function userHandler.GetSingleplayerUser(userName)
	return _GetUser(singleplayerUsers, userName, {
		autoResize     = true,
		isInBattle     = true,
		isSingleplayer = true,
	})
end

function userHandler.GetChannelUser(userName)
	return _GetUser(channelUsers, userName, {
		maxNameLength  = WG.Chobby.Configuration.chatMaxNameLength,
	})
end

function userHandler.GetTeamUser(userName)
	return _GetUser(teamUsers, userName, {
	})
end

function userHandler.GetStatusUser(userName)
	return _GetUser(statusUsers, userName, {
		maxNameLength       = WG.Chobby.Configuration.statusMaxNameLength,
		disableInteraction  = true,
	})
end

function userHandler.GetFriendUser(userName)
	return _GetUser(friendUsers, userName, {
		maxNameLength  = WG.Chobby.Configuration.friendMaxNameLength,
	})
end

function userHandler.GetNotificationUser(userName)
	return _GetUser(notificationUsers, userName, {
		maxNameLength  = WG.Chobby.Configuration.notificationMaxNameLength,
	})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Connection

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local function AddListeners()
	lobby:AddListener("OnUpdateUserStatus", UpdateUserActivity)
	lobby:AddListener("OnAddUser", UpdateUserActivity)
	lobby:AddListener("OnRemoveUser", UpdateUserActivity)
	lobby:AddListener("OnAddUser", UpdateUserCountry)
	lobby:AddListener("OnUpdateUserBattleStatus", UpdateUserBattleStatus)
	WG.LibLobby.localLobby:AddListener("OnUpdateUserBattleStatus", UpdateUserBattleStatus)
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
