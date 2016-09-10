-- Zero-K Server protocol implementation
-- https://github.com/ZeroK-RTS/Zero-K-Infrastructure/blob/master/Shared/LobbyClient/Protocol/Messages.cs

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

function Interface:Register(userName, password, email)
	self:super("Register", userName, password, email)
	-- FIXME: email argument is currently not sent to the server
	password = VFS.CalculateHash(password, 0)
	local sendData = {
		Name = userName,
		PasswordHash = password,
	}
	self:_SendCommand("Register " .. json.encode(sendData))
	return self
end

function Interface:Login(user, password, cpu, localIP, lobbyVersion)
	self:super("Login", user, password, cpu, localIP)
	if localIP == nil then
		localIP = "*"
	end
	password = VFS.CalculateHash(password, 0)
	
	local sendData = {
		Name = user,
		PasswordHash = password,
		UserID = 0,
		ClientType = 1,
		LobbyVersion = lobbyVersion,
	}
	
	self:_SendCommand("Login " .. json.encode(sendData))
end

function Interface:Ping()
	self:super("Ping")
	self:_SendCommand("Ping {}")
	return self
end

------------------------
-- Status commands
------------------------

function Interface:SetIngameStatus(isInGame)
	local sendData = {
		IsInGame = isInGame,
	}

	self:_SendCommand("ChangeUserStatus " .. json.encode(sendData))
	return self
end

function Interface:SetAwayStatus(isAway)
	local sendData = {
		IsAfk = isAway,
	}

	self:_SendCommand("ChangeUserStatus " .. json.encode(sendData))
	return self
end

------------------------
-- User commands
------------------------

function Interface:FriendRequest(userName)
	self:super("FriendRequest", userName)
	local sendData = {
		TargetName = userName,
		Relation = 1, -- Friend
	}
	
	self:_SendCommand("SetAccountRelation " .. json.encode(sendData))
	return self
end

function Interface:AcceptFriendRequest(userName)
	self:super("AcceptFriendRequest", userName)
	Spring.Echo("TODO: Implement AcceptFriendRequest")
	return self
end

function Interface:DeclineFriendRequest(userName)
	self:super("DeclineFriendRequest", userName)
	Spring.Echo("TODO: Implement DeclineFriendRequest")
	return self
end

function Interface:Unfriend(userName)
	self:super("Unfriend", userName)
	local sendData = {
		TargetName = userName,
		Relation = 0, -- None
	}
	
	self:_SendCommand("SetAccountRelation " .. json.encode(sendData))
	return self
end

function Interface:Ignore(userName)
	self:super("Ignore", userName)
	local sendData = {
		TargetName = userName,
		Relation = 2, -- Ignore
	}
	
	self:_SendCommand("SetAccountRelation " .. json.encode(sendData))
	return self
end

function Interface:Unignore(userName)
	self:super("Unignore", userName)
	local sendData = {
		TargetName = userName,
		Relation = 0, -- None
	}
	
	self:_SendCommand("SetAccountRelation " .. json.encode(sendData))
	return self
end

------------------------
-- Battle commands
------------------------

local modeToName = {
	[5] = "Cooperative",
	[6] = "Team",
	[3] = "1v1",
	[4] = "FFA",
	[0] = "Custom",
}

local nameToMode = {}
for i, v in pairs(modeToName) do
	nameToMode[v] = i
end

function Interface:HostBattle(battleTitle, password, modeName)
	--OpenBattle {"Header":{"Mode":6,"Password":"bla","Title":"GoogleFrog's Teams"}}
	-- Mode:
	-- 5 = Cooperative
	-- 6 = Teams
	-- 3 = 1v1
	-- 4 = FFA
	-- 0 = Custom
	local engineName
	if tonumber(Game.version) then
		engineName = Game.version .. ".0"
	else
		engineName = string.gsub(Game.version, " develop", "")
	end
	
	local sendData = {
		Header = {
			Title = battleTitle,
			Mode = (modeName and nameToMode[modeName]) or 0,
			Password = password,
			Engine = engineName
		}
	}
	
	self:_SendCommand("OpenBattle " .. json.encode(sendData))
end

function Interface:RejoinBattle(battleID)
	local sendData = {
		BattleID = battleID,
	}
	self:_SendCommand("RequestConnectSpring " .. json.encode(sendData))
	return self
end

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
	local myBattleID = self:GetMyBattleID()
	if not myBattleID then
		Spring.Echo("LeaveBattle sent while not in battle")
		return
	end
	local sendData = {
		BattleID = myBattleID,
	}
	self:_SendCommand("LeaveBattle " .. json.encode(sendData))
	return self
end

function Interface:SetBattleStatus(status)
	local sendData = {
		Name        = self:GetMyUserName(),
		IsSpectator = status.isSpectator,
		AllyNumber  = status.allyNumber,
		TeamNumber  = status.teamNumber,
		Sync        = status.sync,
	}

	self:_SendCommand("UpdateUserBattleStatus " .. json.encode(sendData))
	return self
end

function Interface:AddAi(aiName, aiLib, allyNumber)
	local sendData = {
		Name         = aiName,
		AiLib        = aiLib,
		AllyNumber   = allyNumber,
		Owner        = self:GetMyUserName(),
	}
	self:_SendCommand("UpdateBotStatus " .. json.encode(sendData))
	return self
end

function Interface:RemoveAi(aiName)
	local sendData = {
		Name        = aiName,
	}
	self:_SendCommand("RemoveBot " .. json.encode(sendData))
	return self
end

function Interface:SayBattle(message)
	local sendData = {
		Place = 1, -- Battle?
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = message,
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:SayBattleEx(message)
	local sendData = {
		Place = 1, -- Battle?
		User = self:GetMyUserName(),
		IsEmote = true,
		Text = message,
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:VoteYes()
	local sendData = {
		Place = 1, -- Battle?
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = "!y",
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:VoteNo()
	local sendData = {
		Place = 1, -- Battle?
		User = self:GetMyUserName(),
		IsEmote = false,
		Text = "!n",
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:SetModOptions(data)
	local sendData = {
		Options = data,
	}
	
	self:_SendCommand("SetModOptions " .. json.encode(sendData))
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

function Interface:Leave(chanName)
	local sendData = {
		ChannelName = chanName
	}
	self:_SendCommand("LeaveChannel " .. json.encode(sendData))
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
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:SayEx(chanName, message)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z"
	local sendData = {
		Place = 0, -- Does 0 mean say to a channel???
		Target = chanName,
		User = self:GetMyUserName(),
		IsEmote = true,
		Text = message,
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
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
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

function Interface:SayPrivateEx(userName, message)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z"
	local sendData = {
		Place = 2, -- Does 2 mean say to a player???
		Target = userName,
		User = self:GetMyUserName(),
		IsEmote = true,
		Text = message,
		Ring = false,
		--Time = "2016-06-25T07:17:20.7548313Z",
	}
	self:_SendCommand("Say " .. json.encode(sendData))
	return self
end

------------------------
-- Matchmaking commands
------------------------

function Lobby:JoinMatchmaking(queueList)
	local sendData = {
		Queues = queueList
	}
	self:_SendCommand("MatchMakerQueueRequest " .. json.encode(sendData))
	return self
end

function Lobby:LeaveMatchmaking()
	local sendData = {
		Queues = {}
	}
	self:_SendCommand("MatchMakerQueueRequest " .. json.encode(sendData))
	return self
end

function Lobby:AcceptMatchmakingMatch()
	local sendData = {
		Ready = true
	}
	self:_SendCommand("AreYouReadyResponse " .. json.encode(sendData))
	return self
end

function Lobby:RejectMatchmakingMatch()
	local sendData = {
		Ready = false
	}
	self:_SendCommand("AreYouReadyResponse " .. json.encode(sendData))
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

local registerResponseCodes = {
	[0] = "Ok",
	[1] = "Name already registered",
	[2] = "Smurf",
	[3] = "Invalid name",
	[4] = "Invalid password",
}

local loginResponseCodes = {
	[0] = "Ok",
	[1] = "Invalid password",
	[2] = "Invalid login",
	[3] = "Name not registered",
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
		self:_OnRegistrationDenied(registerResponseCodes[data.ResultCode] or "Reason error")
	end
end
Interface.jsonCommands["RegisterResponse"] = Interface._RegisterResponse

function Interface:_LoginResponse(data)
	-- ResultCode: 1 = connected, 2 = name exists, 3 = password wrong, 4 = banned
	-- Reason (for ban I presume)
	if data.ResultCode == 0 then
		self:_OnAccepted()
	else
		self:_OnDenied(loginResponseCodes[data.ResultCode] or "Reason error")
	end
end
Interface.jsonCommands["LoginResponse"] = Interface._LoginResponse

------------------------
-- User commands
------------------------

function Interface:_OnAddUser(userName, country, cpu, accountID, lobbyVersion, clan)
	cpu = tonumber(cpu)
	accountID = tonumber(accountID)
	self:super("_OnAddUser", userName, country, cpu, accountID, lobbyVersion, clan)
end
Interface.commands["ADDUSER"] = Interface._OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)%s*(.*)"

function Interface:_User(data)
	-- CHECKME: verify that name, country, cpu and similar info doesn't change
	-- It can change now that we remember user data of friends through disconnect.
	if self.users[data.Name] == nil or self.users[data.Name].isOffline then
		self:_OnAddUser(data.Name, {
			country = data.Country,
			clan = data.Clan,
			lobbyVersion = data.LobbyVersion,
			accountID = data.AccountID,
			isInGame = data.IsInGame,
			isAway = data.IsAway,
			isAdmin = data.IsAdmin,
			level = data.Level,
			skill1v1 = data.Effective1v1Elo,
			skill = data.EffectiveElo,
			isBot = data.IsBot,
			awaySince = data.AwaySince,
			inGameSince = data.InGameSince,
		})
		return
	end
	self:_OnUpdateUserStatus(data.Name, {
		country = data.Country,
		clan = data.Clan,
		lobbyVersion = data.LobbyVersion,
		accountID = data.AccountID,
		isInGame = data.IsInGame,
		isAway = data.IsAway,
		isAdmin = data.IsAdmin,
		level = data.Level,
		skill1v1 = data.Effective1v1Elo,
		skill = data.EffectiveElo,
		isBot = data.IsBot,
		awaySince = data.AwaySince,
		inGameSince = data.InGameSince,
	})
	
	-- User {"AccountID":212941,"SpringieLevel":1,"Avatar":"corflak","Country":"CZ","EffectiveElo":1100,"Effective1v1Elo":1100,"InGameSince":"2016-06-25T11:36:38.9075025Z","IsAdmin":false,"IsBot":true,"IsInBattleRoom":false,"BanMute":false,"BanSpecChat":false,"Level":0,"ClientType":4,"LobbyVersion":"Springie 1.3.2.116","Name":"Elerium","IsAway":false,"IsInGame":true}
end
Interface.jsonCommands["User"] = Interface._User

function Interface:_UserDisconnected(data)
	-- UserDisconnected {"Name":"Springiee81","Reason":"quit"}
	self:_OnRemoveUser(data.Name)
end
Interface.jsonCommands["UserDisconnected"] = Interface._UserDisconnected

------------------------
-- Friend and Ignore lists
------------------------

function Interface:_FriendList(data)
	--if self.friendListRecieved then
		local newFriendMap = {}
		for i = 1, #data.Friends do
			local userName = data.Friends[i]
			if not self.isFriend[userName] then
				self:_OnFriend(userName)
				self:_OnRemoveIgnoreUser(userName)
			end
			newFriendMap[userName] = true
		end
	
		for _, userName in pairs(self.friends) do
			if not newFriendMap[userName] then
				self:_OnUnfriend(userName)
				self:_OnRemoveIgnoreUser(userName)
			end
		end
		--return
	--end
	--self.friendListRecieved = true
	--
	--self:_OnFriendList(data.Friends)
end
Interface.jsonCommands["FriendList"] = Interface._FriendList

function Interface:_IgnoreList(data)
	--if self.ignoreListRecieved then
		local newIgnoreMap = {}
		for i = 1, #data.Ignores do
			local userName = data.Ignores[i]
			if not self.isIgnored[userName] then
				self:_OnAddIgnoreUser(userName)
				self:_OnUnfriend(userName)
			end
			newIgnoreMap[userName] = true
		end
	
		for _, userName in pairs(self.ignored) do
			if not newIgnoreMap[userName] then
				self:_OnUnfriend(userName)
				self:_OnRemoveIgnoreUser(userName)
			end
		end
		--return
	--end
	--self.ignoreListRecieved = true
	--
	--self:_OnIgnoreList(data.Ignores)
end
Interface.jsonCommands["IgnoreList"] = Interface._IgnoreList

------------------------
-- Battle commands
------------------------

function Interface:_ConnectSpring(data)
	if data.Ip and data.Port and data.ScriptPassword then
		Spring.Echo("Connecting to battle", data.Game, data.Map, data.Engine)
		self:ConnectToBattle(self.useSpringRestart, data.Ip, data.Port, data.ScriptPassword)
	end
end
Interface.jsonCommands["ConnectSpring"] = Interface._ConnectSpring

function Interface:_LeftBattle(data)
	self:_OnLeftBattle(data.BattleID, data.User)
end
Interface.jsonCommands["LeftBattle"] = Interface._LeftBattle

function Interface:_BattleAdded(data)
	-- {"Header":{"BattleID":3,"Engine":"100.0","Game":"Zero-K v1.4.6.11","Map":"Zion_v1","MaxPlayers":16,"SpectatorCount":1,"Title":"SERIOUS HOST","Port":8760,"Ip":"158.69.140.0","Founder":"Neptunium"}}
	local header = data.Header
	self:_OnBattleOpened(header.BattleID, 0, 0, header.Founder, header.Ip, 
		header.Port, header.MaxPlayers, (header.Password and true) or false, 0, 4, "Spring " .. header.Engine, header.Engine, 
		header.Map, header.Title or "no title", header.Game, header.SpectatorCount, header.IsRunning, header.RunningSince, header.Mode)
end
Interface.jsonCommands["BattleAdded"] = Interface._BattleAdded

function Interface:_BattleRemoved(data)
	-- BattleRemoved {"BattleID":366}
	self:_OnBattleClosed(data.BattleID)
end
Interface.jsonCommands["BattleRemoved"] = Interface._BattleRemoved

function Interface:_JoinedBattle(data)
	-- {"BattleID":3,"User":"Neptunium"}
	if data.User == self:GetMyUserName() then
		self:_OnBattleScriptPassword(data.ScriptPassword)
		self:_OnJoinBattle(data.BattleID, 0)
	end
	self:_OnJoinedBattle(data.BattleID, data.User, 0)
end
Interface.jsonCommands["JoinedBattle"] = Interface._JoinedBattle

function Interface:_BattleUpdate(data)
	-- BattleUpdate {"Header":{"BattleID":362,"Map":"Quicksilver 1.1"}
	-- BattleUpdate {"Header":{"BattleID":21,"Engine":"103.0.1-88-g1a9cfdd"}
	local header = data.Header
	--Spring.Utilities.TableEcho(header, "header")
	if not self.battles[header.BattleID] then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Interface:_BattleUpdate no such battle with ID: " .. tostring(header.BattleID))
		return
	end
	if header.IsRunning ~= nil then
		self:_OnBattleIngameUpdate(header.BattleID, header.IsRunning)
	end
	
		Spring.Echo("header.Gameheader.Game", header.Game)
	self:_OnUpdateBattleInfo(header.BattleID, header.SpectatorCount, header.Locked, 0, header.Map, header.Engine, header.RunningSince, header.Game, header.Mode)
end
Interface.jsonCommands["BattleUpdate"] = Interface._BattleUpdate

function Interface:_UpdateUserBattleStatus(data)
	-- UpdateUserBattleStatus {"AllyNumber":0,"IsSpectator":true,"Name":"GoogleFrog","Sync":1,"TeamNumber":1}
	local status = {
		isSpectator   = data.IsSpectator,
		allyNumber    = data.AllyNumber,
		teamNumber    = data.TeamNumber,
		sync          = data.Sync,
	}
	if not data.Name then
		Spring.Log(LOG_SECTION, LOG.ERROR, "_UpdateUserBattleStatus missing data.Name field")
		return
	end
	self:_OnUpdateUserBattleStatus(data.Name, status)
end
Interface.jsonCommands["UpdateUserBattleStatus"] = Interface._UpdateUserBattleStatus

function Interface:_UpdateBotStatus(data)
	local status = {
		allyNumber    = data.AllyNumber,
		teamNumber    = data.TeamNumber,
		aiLib         = data.AiLib,
		owner         = data.Owner,
	}
	if not data.Name then
		Spring.Log(LOG_SECTION, LOG.ERROR, "_UpdateBotStatus missing data.Name field")
		return
	end
	self:_OnAddAi(self:GetMyBattleID(), data.Name, status)
end
Interface.jsonCommands["UpdateBotStatus"] = Interface._UpdateBotStatus

function Interface:_RemoveBot(data)
	self:_OnRemoveAi(self:GetMyBattleID(), data.Name)
end
Interface.jsonCommands["RemoveBot"] = Interface._RemoveBot

------------------------
-- Channel & private chat commands
------------------------

local SPRINGIE_HOST_MESSAGE = "I'm here! Ready to serve you! Join me!"
local POLL_START_MESSAGE = "Poll:"
local POLL_END = "END:"
local POLL_END_SUCCESS = "END:SUCCESS"
local AUTOHOST_SUPRESSION = {
	["Sorry, you do not have rights to execute map"] = true,
}

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

local function FindLastOccurence(mainString, subString)
	local position = string.find(mainString, subString)
	local nextPosition = position
	while nextPosition do
		nextPosition = string.find(mainString, subString, position + 1)
		if nextPosition then
			position = nextPosition
		end
	end
	return position
end

function Interface:ProcessVote(data, battle, duplicateMessageTime)
	if (not battle) and battle.founder == data.User then
		return false
	end
	local message = data.Text
	if not message:starts(POLL_START_MESSAGE) then
		return false
	end
	
	local lastOpen = FindLastOccurence(message, "%[")
	local lastClose = FindLastOccurence(message, "%]")
	local lastQuestion = FindLastOccurence(message, "%?")
	if not (lastOpen and lastClose and lastQuestion) then
		return false
	end
	
	local voteMessage = string.sub(message, 0, lastQuestion)
	local lasturl = FindLastOccurence(message, " http")
	if lasturl then
		voteMessage = string.sub(voteMessage, 0, lasturl - 1) .. "?"
	end
	
	local voteData = string.sub(message, lastOpen + 1, lastClose - 1)
	if voteData:starts(POLL_END) then
		self:_OnVoteEnd(voteMessage, (voteData:starts(POLL_END_SUCCESS) and true) or false)
		return true
	end
	
	local lastSlash = FindLastOccurence(voteData, "/")
	if not lastSlash then
		return false
	end
	local votesNeeded = tonumber(string.sub(voteData, lastSlash + 1))
	
	local firstNo = string.find(voteData, "!n=")
	if not firstNo then
		return false
	end
	local noVotes = tonumber(string.sub(voteData, firstNo + 3, lastSlash - 1))
	
	local firstSlash = string.find(voteData, "/")
	if not firstSlash then
		return false
	end
	local yesVotes = tonumber(string.sub(voteData, 4, firstSlash - 1))
	
	if duplicateMessageTime and yesVotes == 0 then
		-- Workaround message ordering ZKLS bug.
		return true
	end
	
	self:_OnVoteUpdate(voteMessage, yesVotes, noVotes, votesNeeded)
	return true
end

function Interface:_Say(data)
	-- Say {"Place":0,"Target":"zk","User":"GoogleFrog","IsEmote":false,"Text":"bla","Ring":false,"Time":"2016-06-25T07:17:20.7548313Z}"
	local duplicateMessageTime = false
	if data.Time then
		if self.duplicateMessageTimes[data.Time] then
			duplicateMessageTime = true
			if self.duplicateMessageTimes[data.Time] == data.Text then
				return
			end
		end
		self.duplicateMessageTimes[data.Time] = data.Text
	end
	
	if AUTOHOST_SUPRESSION[data.Text] then
		if data.User and self.users[data.User] and self.users[data.User].isBot then
			return
		end
	end
	
	local emote = data.IsEmote
	if data.Place == 0 then -- Send to channel?
		if emote then
			self:_OnSaidEx(data.Target, data.User, data.Text, data.Time)
		else
			self:_OnSaid(data.Target, data.User, data.Text, data.Time)
		end
	elseif data.Place == 1 or data.Place == 3 then
		-- data.Place == 1 -> General battle chat
		-- data.Place == 3 -> Battle chat directed at user
		local battleID = self:GetMyBattleID()
		local battle = battleID and self:GetBattle(battleID)
		if self:ProcessVote(data, battle, duplicateMessageTime) then
			return
		end
		if emote then
			self:_OnSaidBattleEx(data.User, data.Text, data.Time)
		else
			self:_OnSaidBattle(data.User, data.Text, data.Time)
		end
	elseif data.Place == 2 then -- Send to user?
		if data.Target == self:GetMyUserName() then
			if emote then
				self:_OnSaidPrivateEx(data.User, data.Text, data.Time)
			else
				self:_OnSaidPrivate(data.User, data.Text, data.Time)
			end
		else
			if emote then
				self:_OnSayPrivateEx(data.Target, data.Text, data.Time)
			else
				self:_OnSayPrivate(data.Target, data.Text, data.Time)
			end
		end
	elseif data.Place == 5 then -- Protocol etc.. commands?
		if data.Text == "Invalid password" then
			self:_CallListeners("OnJoinBattleFailed", data.Text)
		end
	end
end
Interface.jsonCommands["Say"] = Interface._Say

------------------------
-- Matchmaking commands
------------------------

function Interface:_MatchMakerSetup(data)
	local queues = data.PossibleQueues
	self.queueCount = 0
	self.queues = {}
	for _, queue in pairs(queues) do
		self:_OnQueueOpened(queue.Name, queue.Description, queue.Maps, queue.MaxPartySize)
	end
end
Interface.jsonCommands["MatchMakerSetup"] = Interface._MatchMakerSetup

function Interface:_MatchMakerStatus(data)
	self:_OnMatchMakerStatus(data.MatchMakerEnabled, data.JoinedQueues, data.Text)
end
Interface.jsonCommands["MatchMakerStatus"] = Interface._MatchMakerStatus

function Interface:_MatchMakerQueueRequestFailed(data)
	self:_OnMatchMakerStatus(false, nil, data.Reason)
end
Interface.jsonCommands["MatchMakerQueueRequestFailed"] = Interface._MatchMakerQueueRequestFailed

function Interface:_AreYouReady(data)
	self:_OnMatchMakerReadyCheck(data.NeedReadyResponse, data.Text, data.SecondsRemaining)
end
Interface.jsonCommands["AreYouReady"] = Interface._AreYouReady

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
	if not data.Options then
		Spring.Echo("Invalid modoptions format")
		return
	end
	
	data.Options.commanderTypes = nil
	
	self:_OnSetModOptions(data.Options)
end
Interface.jsonCommands["SetModOptions"] = Interface._SetModOptions

--PwMatchCommand

-------------------------------------------------
-- END Client commands
-------------------------------------------------

function Interface:_OnSiteToLobbyCommand(msg)
	local springLink = msg.Command;

	if (springLink) then
		springLink = tostring(springLink);
		Spring.Echo(springLink);
	    local s,e = springLink:find('@start_replay:') 
		if(s == 1)then
			local repString = springLink:sub(15)
			Spring.Echo(repString);

			local replay, game, map, engine = repString:match("([^,]+),([^,]+),([^,]+),([^,]+)");
			self:_OnLaunchRemoteReplay(replay, game, map, engine);
		end
	end
end

Interface.jsonCommands["SiteToLobbyCommand"] = Interface._OnSiteToLobbyCommand

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
