-- Zero-K Server protocol implementation
-- TODO: Add URL for the protocol (There's a CS file?)

VFS.Include(LIB_LOBBY_DIRNAME .. "json.lua")
VFS.Include(LIB_LOBBY_DIRNAME .. "interface_shared.lua")

-- map lobby commands by name
Interface.commands = {}
-- map json lobby commands by name
Interface.jsonCommands = {}
-- define command format with pattern (regex)
Interface.commandPattern = {}

-------------------------------------------------
-- BEGIN Client commands
-------------------------------------------------

------------------------
-- Connectivity commands
------------------------

function Interface:Login(user, password, cpu, localIP)
	self:super("Login", user, password, cpu, localIP)
	if localIP == nil then
		localIP = "*"
	end
	password = VFS.CalculateHash(password, 0)
	
	local sendData = {
		Name = user,
		PasswordHash = password,
		UserID = 12,
		ClientType = 1,
	}
	
	self:_SendCommand("Login " .. json.encode(sendData))
end

function Interface:Ping()
	self:super("Ping")
	self:_SendCommand("Ping {}")
	return self
end

------------------------
-- User commands
------------------------

function Interface:Register(userName, password, email)
	-- FIXME: email argument is currently not sent to the server
	password = VFS.CalculateHash(password, 0)
	local sendData = {
		Name = userName,
		PasswordHash = password,
	}
	self:_SendCommand("Register " .. json.encode(sendData))
	return self
end

------------------------
-- Battle commands
------------------------

function Interface:JoinBattle(battleID, password, scriptPassword)
	local sendData = {
		BattleID = battleID,
		Password = password,
		scriptPassword = scriptPassword
	}
	self:_SendCommand("JoinBattle " .. json.encode(sendData))
	return self
end

function Interface:LeaveBattle()
	local sendData = {
		BattleID = self:GetMyBattleID(),
	}
	self:_SendCommand("LeaveBattle " .. json.encode(sendData))
	return self
end

function Interface:SetBattleStatus(status)
	local sendData = {
		Name = self:GetMyUserName(),
		AllyNumber = status.allyNumber,
		TeamNumber = status.teamNumber,
		Sync = status.sync,
	}

	self:_SendCommand("UpdateUserBattleStatus " .. json.encode(sendData))
	return self
end

function Interface:SayBattle(message)
	local sendData = {
		Place = 1, -- Battle?
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = message,
		Ring = false,
		Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

------------------------
-- Channel & private chat commands
------------------------

function Interface:Join(chanName, key)
	local sendData = {
		ChannelName = chanName
	}
	self:_SendCommand("JoinChannel " .. json.encode(sendData))
	return self
end


function Interface:Say(chanName, message)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z"
	local sendData = {
		Place = 0, -- Does 0 mean say to a channel???
		Target = chanName,
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = message,
		Ring = false,
		Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:SayPrivate(userName, message)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z"
	local sendData = {
		Place = 2, -- Does 2 mean say to a player???
		Target = userName,
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = message,
		Ring = false,
		Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

-------------------------------------------------
-- END Client commands
-------------------------------------------------

-------------------------------------------------
-- BEGIN Server commands
-------------------------------------------------

------------------------
-- Connectivity commands
------------------------

local loginOrRegisterResponseCodes = {
	[1] = "Already connected",
	[2] = "Name exists",
	[3] = "Password wrong",
	[4] = "Banned",
	[5] = "Bad characters in name",
}

function Interface:_Welcome(data)
	-- Engine
	-- Game
	-- Version of Game
	self:_OnConnect(4, data.Engine, 2, 1)
end
Interface.jsonCommands["Welcome"] = Interface._Welcome

function Interface:_Ping(data)
	self:_OnPong()
	self:Ping()
end
Interface.jsonCommands["Ping"] = Interface._Ping

function Interface:_RegisterResponse(data)
	-- ResultCode: 1 = connected, 2 = name exists, 3 = password wrong, 4 = banned, 5 = bad name characters
	-- Reason (for ban I presume)
	if data.ResultCode == 0 then
		self:_OnRegistrationAccepted()
	else
		self:_OnRegistrationDenied(loginOrRegisterResponseCodes[data.ResultCode] or "Reason error")
	end
end
Interface.jsonCommands["RegisterResponse"] = Interface._RegisterResponse

function Interface:_LoginResponse(data)
	-- ResultCode: 1 = connected, 2 = name exists, 3 = password wrong, 4 = banned
	-- Reason (for ban I presume)
	if data.ResultCode == 0 then
		self:_OnAccepted()
	else
		self:_OnDenied(loginOrRegisterResponseCodes[data.ResultCode] or "Reason error")
	end
end
Interface.jsonCommands["LoginResponse"] = Interface._LoginResponse

------------------------
-- User commands
------------------------

function Interface:_OnAddUser(userName, country, cpu, accountID)
	cpu = tonumber(cpu)
	accountID = tonumber(accountID)
	self:super("_OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Interface._OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)%s*(.*)"

function Interface:_User(data)
	-- CHECKME: verify that name, country, cpu and similar info doesn't change
	if self.users[userName] == nil then
		self:_OnAddUser(data.Name, data.Country, 3, data.AccountID)
	end
	self:_OnUpdateUserStatus(data.Name, {isInGame=data.IsInGame, isAway=data.IsAway, isAdmin=data.IsAdmin})
	
	-- User {"AccountID":212941,"SpringieLevel":1,"Avatar":"corflak","Country":"CZ","EffectiveElo":1100,"Effective1v1Elo":1100,"InGameSince":"2016-06-25T11:36:38.9075025Z","IsAdmin":false,"IsBot":true,"IsInBattleRoom":false,"BanMute":false,"BanSpecChat":false,"Level":0,"ClientType":4,"LobbyVersion":"Springie 1.3.2.116","Name":"Elerium","IsAway":false,"IsInGame":true}
end
Interface.jsonCommands["User"] = Interface._User

function Interface:_UserDisconnected(data)
	-- UserDisconnected {"Name":"Springiee81","Reason":"quit"}
	self:_OnRemoveUser(data.Name)
end
Interface.jsonCommands["UserDisconnected"] = Interface._UserDisconnected

------------------------
-- Battle commands
------------------------

function Interface:_LeftBattle(data)
	self:_OnLeftBattle(data.BattleID, data.User)
end
Interface.jsonCommands["LeftBattle"] = Interface._LeftBattle

function Interface:_BattleAdded(data)
	-- {"Header":{"BattleID":3,"Engine":"100.0","Game":"Zero-K v1.4.6.11","Map":"Zion_v1","MaxPlayers":16,"SpectatorCount":1,"Title":"SERIOUS HOST","Port":8760,"Ip":"158.69.140.0","Founder":"Neptunium"}}
	local header = data.Header
	local passworded = false -- TODO: detect pw-protected rooms
	self:_OnBattleOpened(header.BattleID, 0, 0, header.Founder, header.Ip, 
		header.Port, header.MaxPlayers, passworded, 0, 4, "Spring " .. header.Engine, header.Engine, 
		header.Map, header.Title or "no title", header.Game, header.SpectatorCount)
end
Interface.jsonCommands["BattleAdded"] = Interface._BattleAdded

function Interface:_BattleRemoved(data)
	-- BattleRemoved {"BattleID":366}
	self:_OnBattleClosed(data.BattleID)
end
Interface.jsonCommands["BattleRemoved"] = Interface._BattleRemoved

function Interface:_JoinedBattle(data)
	-- {"BattleID":3,"User":"Neptunium"}
	if data.User ~= self:GetBattle(data.BattleID).founder then
		self:_OnJoinedBattle(data.BattleID, data.User, 0)
	end
	if data.User == self:GetMyUserName() then
		self:_OnBattleScriptPassword(data.ScriptPassword)
		self:_OnJoinBattle(data.BattleID, 0)
	end
end
Interface.jsonCommands["JoinedBattle"] = Interface._JoinedBattle

function Interface:_BattleUpdate(data)
	-- BattleUpdate {"Header":{"BattleID":362,"Map":"Quicksilver 1.1"}
	local header = data.Header
	--Spring.Utilities.TableEcho(header, "header")
	if not self.battles[header.BattleID] then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Interface:_BattleUpdate no such battle with ID: " .. tostring(header.BattleID))
		return
	end
	self:_OnUpdateBattleInfo(header.BattleID, header.SpectatorCount, header.Locked, 0, header.Map)
end
Interface.jsonCommands["BattleUpdate"] = Interface._BattleUpdate

function Interface:_UpdateUserBattleStatus(data)
	-- UpdateUserBattleStatus {"AllyNumber":0,"IsSpectator":true,"Name":"GoogleFrog","Sync":1,"TeamNumber":1}
	local status = {
		allyNumber = data.AllyNumber,
		teamNumber = data.TeamNumber,
		sync = data.Sync,
	}
	if not data.Name then
		Spring.Log(LOG_SECTION, LOG.ERROR, "_UpdateUserBattleStatus missing data.Name field")
		return
	end
	self:_OnUpdateUserBattleStatus(data.Name, status)
end
Interface.jsonCommands["UpdateUserBattleStatus"] = Interface._UpdateUserBattleStatus

------------------------
-- Channel & private chat commands
------------------------

function Interface:_JoinChannelResponse(data)
	-- JoinChannelResponse {"ChannelName":"sy","Success":true,"Channel":{"Users":["GoogleFrog","ikinz","DeinFreund","NorthChileanG","hokomoko"],"ChannelName":"sy"}}
	if data.Success then
		self:_OnJoin(data.ChannelName)
		self:_OnClients(data.ChannelName, data.Channel.Users)
	end
end
Interface.jsonCommands["JoinChannelResponse"] = Interface._JoinChannelResponse

function Interface:_ChannelUserAdded(data)
	if data.UserName ~= self:GetMyUserName() then
		self:_OnJoined(data.ChannelName, data.UserName)
	end
end
Interface.jsonCommands["ChannelUserAdded"] = Interface._ChannelUserAdded

function Interface:_ChannelUserRemoved(data)
	-- ChannelUserRemoved {"ChannelName":"zk","UserName":"Springiee81"}
	self:_OnLeft(data.ChannelName, data.UserName, "")
end
Interface.jsonCommands["ChannelUserRemoved"] = Interface._ChannelUserRemoved

function Interface:_Say(data)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z}"
	local emote = data.IsEmote
	if data.Place == 0 then -- Send to channel?
		if emote then
			self:_OnSaidEx(data.Target, data.User, data.Text)
		else
			self:_OnSaid(data.Target, data.User, data.Text)
		end
	elseif data.Place == 1 then -- Send to battle?
		if emote then
			self:_OnSaidBattleEx(data.User, data.Text)
		else
			self:_OnSaidBattle(data.User, data.Text)
		end
	elseif data.Place == 2 then -- Send to user?
		if data.Target == self:GetMyUserName() then
			self:_OnSaidPrivate(data.User, data.Text)
		else
			self:_OnSayPrivate(data.Target, data.Text)
		end
	end
end
Interface.jsonCommands["Say"] = Interface._Say

-- OTHER

function Interface:_UpdateBotStatus(data)
	-- SetModOptions {"Options":{}}
	self:_OnUpdateUserBattleStatus(data.Name, data)
end
Interface.jsonCommands["UpdateBotStatus"] = Interface._UpdateBotStatus

function Interface:_RemoveBot(data)
	self:_OnRemoveAi(self:GetMyBattleID(), data.Name)
end
Interface.jsonCommands["RemoveBot"] = Interface._RemoveBot

-------------------
-- Unimplemented --

function Interface:_ChannelHeader(data)
	-- List of users
	-- Channel Name
	-- Password for channel
	-- Topic ???
	Spring.Echo("Implement ChannelHeader")
	--Spring.Utilities.TableEcho(data)
end
Interface.jsonCommands["ChannelHeader"] = Interface._ChannelHeader

function Interface:_SetRectangle(data)
	-- SetRectangle {"Number":1,"Rectangle":{"Bottom":120,"Left":140,"Right":200,"Top":0}}
	Spring.Echo("Implement SetRectangle")
	--Spring.Utilities.TableEcho(data, "SetRectangle")
end
Interface.jsonCommands["SetRectangle"] = Interface._SetRectangle

function Interface:_SetModOptions(data)
	-- SetModOptions {"Options":{}}
	Spring.Echo("Implement SetModOptions")
	--Spring.Utilities.TableEcho(data, "SetModOptions")
end
Interface.jsonCommands["SetModOptions"] = Interface._SetModOptions

--SiteToLobbyCommand
--PwMatchCommand

-------------------------------------------------
-- END Client commands
-------------------------------------------------


function Interface:UpdateBotStatus(data)
	self:_SendCommand("UpdateBotStatus " .. json.encode(data))
	return self
end

--Register
--JoinChannel
--LeaveChannel
--User
--OpenBattle
--RemoveBot
--ChangeUserStatus
--SetRectangle
--SetModOptions
--KickFromBattle
--KickFromServer
--KickFromChannel
--ForceJoinChannel
--ForceJoinBattle
--LinkSteam
--PwMatchCommand

return Interface
