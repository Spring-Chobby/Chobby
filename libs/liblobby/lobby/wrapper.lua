VFS.Include(LIB_LOBBY_DIRNAME .. "utilities.lua")

Wrapper = Interface:extends()

-- map lobby commands by name
Wrapper.commands = {}
-- map json lobby commands by name
Wrapper.jsonCommands = {}

function Wrapper:init()
	self:super("init")
	-- don't use these fields directly, they are subject to change
	self:_Clean()
end

function Wrapper:_Clean()
	self.users = {}
	self.userCount = 0

	self.friends = {}
	self.friendCount = 0

	self.channels = {}
	self.channelCount = 0
	self.myChannels = {}

	self.battles = {}
	self.battleCount = 0

	self.queues = {}
	self.queueCount = 0

	self.team = nil

	self.latency = 0 -- in ms

	self.loginData = nil
	self.myUserName = nil
	self.myBattleID = nil
	self.scriptPassword = nil
	
	self.battlePlayerData = {}
	
	-- reconnection delay in seconds
	self.reconnectionDelay = 5
end

function Wrapper:_PreserveData()
	self._oldData = {
		channels = ShallowCopy(self.channels),
		battles = ShallowCopy(self.battles),
		loginData = ShallowCopy(self.loginData),
		myUserName = self.myUserName,
		host = self.host,
		port = self.port,
	}
end

local function GenerateScriptTxt(battleID)
	local battle = lobby:GetBattle(battleID)
	local scriptTxt = 
[[
[GAME]
{
	HostIP=__IP__;
	HostPort=__PORT__;
	IsHost=0;
	MyPlayerName=__MY_PLAYER_NAME__;
	MyPasswd=__MY_PASSWD__;
}
]]

	scriptTxt = scriptTxt:gsub("__IP__", battle.ip)
						:gsub("__PORT__", battle.port)
						:gsub("__MY_PLAYER_NAME__", lobby:GetMyUserName())
						:gsub("__MY_PASSWD__", lobby:GetScriptPassword())
	return scriptTxt
end

-- Interface function
function Wrapper:_SetScriptPassword(scriptPassword)
	self.scriptPassword = scriptPassword
end


----------------------------------------------------------------------------
-- Listeners 
----------------------------------------------------------------------------
-- These functions override the interface recieving commands to the server.
-- Most of the time they just store information then let the command 
-- through

-- override
function Wrapper:_OnTASServer(...)
	if self.status == "disconnected" and self.disconnectTime ~= nil then -- in the process of reconnecting
		self.disconnectTime = nil
		self:Login(unpack(self._oldData.loginData))
	end
	self.finishedConnecting = true
	self:super("_OnTASServer", ...)
	--self:super("_OnTASServer")
end
Wrapper.commands["TASServer"] = Wrapper._OnTASServer

-- override
function Wrapper:_OnAddUser(userName, country, cpu, accountID)
	cpu = tonumber(cpu)
	accountID = tonumber(accountID)

	if self.users[userName] == nil then
		self.userCount = self.userCount + 1
	end
	self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}

	self:super("_OnAddUser", userName, country, cpu, accountID)
end
Wrapper.commands["ADDUSER"] = Wrapper._OnAddUser

-- override
function Wrapper:_OnRemoveUser(userName)
	self.users[userName] = nil
	self.userCount = self.userCount - 1

	self:super("_OnRemoveUser", userName)
end
Wrapper.commands["REMOVEUSER"] = Wrapper._OnRemoveUser

-- override
function Wrapper:_OnPong()
	self.pongTimer = Spring.GetTimer()
	if self.pingTimer then
		self.latency = Spring.DiffTimers(self.pongTimer, self.pingTimer, true)
	else
		Spring.Echo("missing self.pingTimer")
	end
	self:super("_OnPong")
end
Wrapper.commands["PONG"] = Wrapper._OnPong

-- override
function Wrapper:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other, engineVersion, mapName, title, gameName, spectatorCount)
	battleID = tonumber(battleID)
	type = tonumber(type)
	natType = tonumber(natType)
	port = tonumber(port)
	maxPlayers = tonumber(maxPlayers)
	passworded = tonumber(passworded) ~= 0
	
	if not WG.Server.ZKServer then
		local engineName
		engineName, engineVersion, mapName, title, gameName = unpack(explode("\t", other))
	end
	
	self.battles[battleID] = { 
		battleID=battleID, type=type, natType=natType, founder=founder, ip=ip, port=port, 
		maxPlayers=maxPlayers, passworded=passworded, rank=rank, mapHash=mapHash, spectatorCount = spectatorCount or 0,
		engineName=engineName, engineVersion=engineVersion, mapName=mapName, title=title, gameName=gameName, users={founder},
	}
	self.battleCount = self.battleCount + 1

	self:super("_OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other, engineVersion, mapName, title, gameName, spectatorCount)
end
Wrapper.commands["BATTLEOPENED"] = Wrapper._OnBattleOpened

-- override
function Wrapper:_OnBattleClosed(battleID)
	battleID = tonumber(battleID)
	self.battles[battleID] = nil
	self.battleCount = self.battleCount - 1

	self:super("_OnBattleClosed", battleID)
end
Wrapper.commands["BATTLECLOSED"] = Wrapper._OnBattleClosed

-- override
function Wrapper:_OnJoinedBattle(battleID, userName, scriptPassword)
	battleID = tonumber(battleID)
	table.insert(self.battles[battleID].users, userName)

	if self:GetMyUserName() == userName then
		self.myBattleID = battleID
	end
	
	self:super("_OnJoinedBattle", battleID, userName, scriptPassword)
end
Wrapper.commands["JOINEDBATTLE"] = Wrapper._OnJoinedBattle

-- override
function Wrapper:_OnLeftBattle(battleID, userName)
	battleID = tonumber(battleID)
	
	if self:GetMyUserName() == userName then
		self.myBattleID = nil
	end
	
	local battleUsers = self.battles[battleID].users
	for i, v in pairs(battleUsers) do
		if v == userName then
			table.remove(battleUsers, i)
			break
		end
	end

	self:super("_OnLeftBattle", battleID, userName)
end
Wrapper.commands["LEFTBATTLE"] = Wrapper._OnLeftBattle

-- override
function Wrapper:_OnUpdateBattleInfo(battleID, spectatorCount, locked, mapHash, mapName)
	battleID = tonumber(battleID)
	--Spring.Utilities.TableEcho(self.battles[battleID], battleID)
	if self.battles[battleID] then
		self.battles[battleID].spectatorCount = spectatorCount or self.battles[battleID].spectatorCount
		self.battles[battleID].locked = locked or self.battles[battleID].locked
		self.battles[battleID].mapHash = mapHash or self.battles[battleID].mapHash
		self.battles[battleID].mapName = mapName or self.battles[battleID].mapName
	end
	
	self:super("_OnUpdateBattleInfo", battleID, spectatorCount, locked, mapHash, mapName)
end
Wrapper.jsonCommands["OnUpdateBattleInfo"] = Wrapper._OnUpdateBattleInfo

-- override
function Wrapper:_UpdateUserBattleStatus(data)
	if data.Name then
		if not self.battlePlayerData[data.Name] then
			self.battlePlayerData[data.Name] = {}
		end
		local userData = self.battlePlayerData[data.Name]
		userData.AllyNumber = data.AllyNumber or userData.AllyNumber
		userData.TeamNumber = data.TeamNumber or userData.TeamNumber
		if data.IsSpectator ~= nil then
			userData.IsSpectator = data.IsSpectator
		end
		userData.AiLib = data.AiLib or userData.AiLib
		userData.Sync = data.Sync or userData.Sync
		
		data.AllyNumber = userData.AllyNumber
		data.TeamNumber = userData.TeamNumber
		data.IsSpectator = userData.IsSpectator
		data.AiLib = userData.AiLib
		data.Sync = userData.Sync
	end
	self:super("_UpdateUserBattleStatus", data)
end
Wrapper.jsonCommands["UpdateUserBattleStatus"] = Wrapper._UpdateUserBattleStatus

-- will also create a channel if it doesn't already exist
function Wrapper:_GetChannel(chanName)
	local channel = self.channels[chanName]
	if channel == nil then
		channel = { chanName = chanName }
		self.channels[chanName] = channel
		self.channelCount = self.channelCount + 1
	end
	return channel
end

-- override
function Wrapper:_OnChannel(chanName, userCount, topic)
	local channel = self:_GetChannel(chanName)
	channel.userCount = userCount
	channel.topic = topic

	self:super("_OnChannel", chanName, userCount, topic)
end
Wrapper.commands["CHANNEL"] = Wrapper._OnChannel

-- override
function Wrapper:_OnChannelTopic(chanName, author, changedTime, topic)
	local channel = self:_GetChannel(chanName)
	channel.topic = topic

	self:super("_OnChannelTopic", chanName, author, changedTime, topic)
end
Wrapper.commands["CHANNELTOPIC"] = Wrapper._OnChannelTopic

-- override
function Wrapper:_OnClients(chanName, clientsStr)
	local channel = self:_GetChannel(chanName)
	local users
	if WG.Server.ZKServer then
		users = clientsStr
	else
		users = explode(" ", clientsStr)
	end

	if channel.users ~= nil then
		for _, user in pairs(users) do
			local found = false
			for _, existingUser in pairs(channel.users) do
				if user == existingUser then
					found = true
					break
				end
			end
			if not found then
				table.insert(channel.users, user)
			end
		end
	else
		channel.users = users
	end
	self:super("_OnClients", chanName, clientsStr)
end
Wrapper.commands["CLIENTS"] = Wrapper._OnClients

-- override
function Wrapper:_OnJoined(chanName, userName)
	local channel = self:_GetChannel(chanName)

	-- only add users after CLIENTS was received
	if channel.users ~= nil then
		table.insert(channel.users, userName)
	end
	self:super("_OnJoined", chanName, userName)
end
Wrapper.commands["JOINED"] = Wrapper._OnJoined

-- override
function Wrapper:_OnJoin(chanName)

	table.insert(self.myChannels, chanName)
	
	self:super("_OnJoin", chanName)
end
Wrapper.commands["JOIN"] = Wrapper._OnJoin

-- override
function Wrapper:_OnLeft(chanName, userName, reason)
	local channel = self:_GetChannel(chanName)
	
	if userName == self.myUsername then
		for i, v in pairs(self.myChannels) do
			if v == chanName then
				table.remove(self.myChannels, i)
				break
			end
		end
	end
	for i, v in pairs(channel.users) do
		if v == userName then
			table.remove(channel.users, i)
			break
		end
	end

	self:super("_OnLeft", chanName, userName, reason)
end
Wrapper.commands["LEFT"] = Wrapper._OnLeft

-- override
function Wrapper:_OnFriendListBegin(...)
	self.friends = {}
	self.friendCount = 0
	self:super("_OnFriendListBegin", ...)
end
Wrapper.commands["FRIENDLISTBEGIN"] = Wrapper._OnFriendListBegin

-- override
function Wrapper:_OnFriendList(userName, ...)
	table.insert(self.friends, userName)
	self.friendCount = self.friendCount + 1
	self:super("_OnFriendList", userName, ...)
end

-- override
function Wrapper:_OnListQueues(queues, ...)
	self.queueCount = 0
	self.queues = {}
	for _, queue in pairs(queues) do
		self.queues[queue.name] = queue
		self.queueCount = self.queueCount + 1
	end
	self:super("_OnListQueues", queues, ...)
end
Wrapper.jsonCommands["LISTQUEUES"] = Wrapper._OnListQueues

-- override
function Wrapper:_OnQueueOpened(queue)
	local name = queue.name
	self.queues[name] = queue
	self.queueCount = self.queueCount + 1
	self:super("_OnQueueOpened", queue)
end
Wrapper.jsonCommands["QUEUEOPENED"] = Wrapper._OnQueueOpened

-- override
function Wrapper:_OnQueueClosed(queue)
	local name = queue.name
	self.queues[name] = nil
	self.queueCount = self.queueCount - 1
	self:super("_OnQueueClosed", queue)
end
Wrapper.jsonCommands["QUEUECLOSED"] = Wrapper._OnQueueClosed

-- override
function Wrapper:_OnJoinedTeam(obj)
	local userName = obj.userName
	table.insert(self.team.users, userName)
	self:super("_OnJoinedTeam", obj)
end
Wrapper.jsonCommands["JOINEDTEAM"] = Wrapper._OnJoinedTeam

-- override
function Wrapper:_OnJoinTeam(obj)
	local userNames = obj.userNames
	local leader = obj.leader
	self.team = { users = userNames, leader = leader }
	self:super("_OnJoinTeam", obj)
end
Wrapper.jsonCommands["JOINTEAM"] = Wrapper._OnJoinTeam

function Wrapper:_OnLeftTeam(obj)
	local userName = obj.userName
	local reason = obj.reason
	if userName == self.myUserName then
		self.team = nil
	else
		for i, v in pairs(self.team.users) do
			if v == userName then
				table.remove(self.team.users, i)
				break
			end
		end
	end
	self:super("_OnLeftTeam", obj)
end
Wrapper.jsonCommands["LEFTTEAM"] = Wrapper._OnLeftTeam

-- override
function Wrapper:_OnDisconnected(...)
	if self.disconnectTime == nil then
		self:_PreserveData()
		self:_Clean()
	end
	self.disconnectTime = Spring.GetGameSeconds()
	self:super("_OnDisconnected", ...)
end

function Wrapper:_ProcessClientStatus(userName, ingame, isAway, isModerator, isBot)
	local function StartBattle(battleID)
		Spring.Echo("Game starts!")
		local battle = self:GetBattle(battleID)
		local springURL = "spring://" .. self:GetMyUserName() .. ":" .. self:GetScriptPassword() .. "@" .. battle.ip .. ":" .. battle.port
		Spring.Echo(springURL)
		Spring.Start(springURL, "")
		--local scriptFileName = "scriptFile.txt"
		--local scriptFile = io.open(scriptFileName, "w")
		--local scriptTxt = GenerateScriptTxt(battleID)
		--Spring.Echo(scriptTxt)
		--scriptFile:write(scriptTxt)
		--scriptFile:close()
		--Spring.Restart(scriptFileName, "")
		--Spring.Restart("", scriptTxt)
	end
	
	if ingame ~= nil then
		self:_CallListeners("UserIngameStatus", userName, ingame)
		if self.myBattleID then
			local myBattle = self:GetBattle(self.myBattleID)
			if myBattle and myBattle.founder == userName then
				self:_CallListeners("BattleAboutToStart")
				StartBattle(self.myBattleID)
			end
		end
	end
	if isAway ~= nil then
		self.users[userName].isAway = isAway
		self:_CallListeners("UserAwayStatus", userName, isAway)
	end
	if isModerator ~= nil then
		self.users[userName].isModerator = isModerator
		self:_CallListeners("UserModeratorStatus", userName, isModerator)
	end
	if isBot ~= nil then
		self.users[userName].isBot = isBot
		self:_CallListeners("UserBotStatus", userName, isBot)
	end
end

----------------------------------------------------------------------------
-- Internals 
----------------------------------------------------------------------------

-- override
function Wrapper:SafeUpdate(...)
	if self.status == "disconnected" and self.disconnectTime ~= nil then
		local nowSeconds = Spring.GetGameSeconds()
		if self.lastReconnectionAttempt == nil or nowSeconds - self.lastReconnectionAttempt > self.reconnectionDelay then
			self:Reconnect()
		end
	end
	self:super("SafeUpdate", ...)
end

-- override
function Wrapper:_GetCommandFunction(cmdName)
	local cmd = Wrapper.commands[cmdName]	
	if cmd == nil then
		cmd = self:super("_GetCommandFunction", cmdName)
	end
	return cmd
end

-- override
function Wrapper:_GetJsonCommandFunction(cmdName)
	local cmd = Wrapper.jsonCommands[cmdName]
	if cmd == nil then
		cmd = self:super("_GetJsonCommandFunction", cmdName)
	end
	return cmd
end

----------------------------------------------------------------------------
-- Setters 
----------------------------------------------------------------------------
-- Many setters are implemented directly in the interface. This section
-- contains overrides and abstractions.

--------------------------------------
-- Overrides

function Wrapper:Ping()
	self.pingTimer = Spring.GetTimer()
	return self:super("Ping")
end

function Wrapper:Connect(host, port)
	self.host = host
	self.port = port
	self:super("Connect", host, port)
end

function Wrapper:Login(user, password, cpu, localIP) 
	self.myUserName = user
	self.loginData = { user, password, cpu, localIP }
	self:super("Login", user, password, cpu, localIP)
end

function Wrapper:Leave(chanName)
	self:super("Leave", chanName)
	self:_OnLeft(chanName, self.myUserName, "left")
	return self
end

--------------------------------------
-- Abstractions

function Wrapper:Reconnect()
	self.lastReconnectionAttempt = Spring.GetGameSeconds()
	self:Connect(self._oldData.host, self._oldData.port)
end

function Wrapper:StartBattle()
	self:SayBattle("!start")
end

function Wrapper:SelectMap(mapName)
	self:SayBattle("!map " .. mapName)
end

function Wrapper:AddAi(aiName, allyNumber, Name)
	local botData = {
		AllyNumber = allyNumber or 0,
		AiLib = aiName or "NullAI",
		Name = Name or (aiName .. "_" .. math.floor(math.random()*100)),
		TeamNumber = self:GetUnusedTeamID(allyNumber)
	}
	self:UpdateBotStatus(botData)
end

----------------------------------------------------------------------------
-- Getters
----------------------------------------------------------------------------
-- Returns information stored in the wrapper

--------------------------------------
-- Social queue/team handling

function Wrapper:GetUnusedTeamID()
	local unusedTeamID = 0
	local takenTeamID = {}
	for name, data in pairs(self.battlePlayerData) do
		if data.TeamNumber and not data.IsSpectator then
			local teamID = data.TeamNumber
			takenTeamID[teamID] = true
			while takenTeamID[unusedTeamID] do
				unusedTeamID = unusedTeamID + 1
			end
		end
	end
	return unusedTeamID
end

-- friends
function Wrapper:GetFriendCount()
	return self.friendCount
end
-- returns friends table (not necessarily an array)
function Wrapper:GetFriends()
	return ShallowCopy(self.friends)
end

-- queues
function Wrapper:GetQueueCount()
	return self.queueCount
end
function Wrapper:GetQueue(queueID)
	return self.queues[queueID]
end
-- returns queues table (not necessarily an array)
function Wrapper:GetQueues()
	return ShallowCopy(self.queues)
end

-- team
function Wrapper:GetTeam()
	return self.team
end

--------------------------------------
-- Global list handling: users, queues, rooms, channels

-- users
-- returns users table (not necessarily an array)
function Wrapper:GetUsers()
	return ShallowCopy(self.users)
end
function Wrapper:GetUserCount()
	return self.userCount
end
function Wrapper:GetUser(userName)
	return self.users[userName]
end

-- channels
function Wrapper:GetChannelCount()
	return self.channelCount
end
function Wrapper:GetChannel(channelName)
	return self.channels[channelName]
end

function Wrapper:GetMyChannels()
	return self.myChannels
end

-- returns channels table (not necessarily an array)
function Wrapper:GetChannels()
	return ShallowCopy(self.channels)
end

-- battles
function Wrapper:GetBattleCount()
	return self.battleCount
end
function Wrapper:GetBattle(battleID)
	return self.battles[battleID]
end
-- returns battles table (not necessarily an array)
function Wrapper:GetBattles()
	return ShallowCopy(self.battles)
end

--------------------------------------
-- Battle room information

function Wrapper:GetScriptPassword()
	return self.scriptPassword or 0
end

function Wrapper:GetMyAllyNumber()
	if self.battlePlayerData[self.myUserName] then		
		return self.battlePlayerData[self.myUserName].AllyNumber
	end	
end 

function Wrapper:GetMyTeamNumber()
	if self.battlePlayerData[self.myUserName] then		
		return self.battlePlayerData[self.myUserName].TeamNumber
	end
end

function Wrapper:GetMyIsSpectator()
	if self.battlePlayerData[self.myUserName] then		
		return self.battlePlayerData[self.myUserName].IsSpectator
	end
end

function Wrapper:GetMySync()
	if self.battlePlayerData[self.myUserName] then		
		return self.battlePlayerData[self.myUserName].Sync
	end
end

--------------------------------------
-- Global information

function Wrapper:GetMyBattleID()
	return self.myBattleID
end

function Wrapper:GetLatency()
	return self.latency
end

function Wrapper:GetMyUserName()
	return self.myUserName
end

return Wrapper
