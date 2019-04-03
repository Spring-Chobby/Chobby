-- Official SpringRTS Lobby protocol implementation
-- http://springrts.com/dl/LobbyProtocol/

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
	password = VFS.CalculateHash(password, 0)
	self:_SendCommand(concat("REGISTER", userName, password, email))
	return self
end

function Interface:Login(user, password, cpu, localIP, lobbyVersion)
	self:super("Login", user, password, cpu, localIP, lobbyVersion)
	if localIP == nil then
		localIP = "*"
	end
	password = VFS.CalculateHash(password, 0)
	sentence = "LuaLobby " .. lobbyVersion .. "\t" .. self.agent .. "\t" .. "t l b cl"
	cmd = concat("LOGIN", user, password, "0", localIP, sentence)
	self:_SendCommand(cmd)
	return self
end

function Interface:Ping()
	self:super("Ping")
	self:_SendCommand("PING", true)
	return self
end

------------------------
-- User commands
------------------------

function Interface:FriendList()
	self:_SendCommand("FRIENDLIST", true)
	return self
end

function Interface:FriendRequestList()
	self:_SendCommand("FRIENDREQUESTLIST", true)
	return self
end

function Interface:FriendRequest(userName)
	self:super("FriendRequest", userName)
	self:_SendCommand(concat("FRIENDREQUEST", "userName="..userName))
	return self
end

function Interface:AcceptFriendRequest(userName)
	self:super("AcceptFriendRequest", userName)
	self:_SendCommand(concat("ACCEPTFRIENDREQUEST", "userName="..userName))
	return self
end

function Interface:DeclineFriendRequest(userName)
	self:super("DeclineFriendRequest", userName)
	self:_SendCommand(concat("DECLINEFRIENDREQUEST", "userName="..userName))
	return self
end

function Interface:Unfriend(userName)
	self:super("Unfriend", userName)
	self:_SendCommand(concat("UNFRIEND", "userName="..userName))
	return self
end

function Interface:Ignore(userName)
	self:super("Ignore", userName)
	self:_SendCommand(concat("IGNORE", "userName="..userName))
	return self
end

function Interface:Unignore(userName)
	self:super("Unignore", userName)
	self:_SendCommand(concat("UNIGNORE", "userName="..userName))
	return self
end

------------------------
-- Battle commands
------------------------

function Interface:RejoinBattle(battleID)
	local battle = self:GetBattle(battleID)
	if battle then
		self:ConnectToBattle(self.useSpringRestart, battle.ip, battle.port, nil, self:GetScriptPassword())
	end

	return self
end

function Interface:JoinBattle(battleID, password, scriptPassword)
	self:super("JoinBattle", battleID, password, scriptPassword)
	self:_SendCommand(concat("JOINBATTLE", battleID, password, scriptPassword))
	return self
end

function Interface:LeaveBattle()
	self:super("LeaveBattle")
	self:_SendCommand("LEAVEBATTLE")
	return self
end

function Interface:SetBattleStatus(status)
	if not self._requestedBattleStatus then
		return
	end
	self:super("SetBattleStatus", status)

  -- FIXME: (or rather FIX UI code)
	-- This function is invoked too many times (before an answer gets received),
	-- so we're setting the values before
	-- they get confirmed from the server, otherwise we end up sending different info
	local myUserName = self:GetMyUserName()
	if not self.userBattleStatus[myUserName] then
		self.userBattleStatus[userName] = {}
	end
	local userData = self.userBattleStatus[myUserName]

	local bs = {}
	if status.isReady ~= nil then
		bs.isReady       = status.isReady
		userData.isReady = status.isReady
	else
		bs.isReady = self:GetMyIsReady()
	end
	if status.teamNumber ~= nil then
		bs.teamNumber       = status.teamNumber
		userData.teamNumber = status.teamNumber
	else
		bs.teamNumber  = self:GetMyTeamNumber() or 0
	end
	if status.teamColor ~= nil then
		bs.teamColor       = status.teamColor
		userData.teamColor = status.teamColor
	else
		bs.teamColor   = self:GetMyTeamColor()
	end
	if status.allyNumber ~= nil then
		bs.allyNumber       = status.allyNumber
		userData.allyNumber = status.allyNumber
	else
		bs.allyNumber  = self:GetMyAllyNumber() or 0
	end
	if status.isSpectator ~= nil then
		bs.isSpectator       = status.isSpectator
		userData.isSpectator = status.isSpectator
	else
		bs.isSpectator = self:GetMyIsSpectator()
	end
	if status.sync ~= nil then
		bs.sync        = status.sync
		userData.sync  = status.sync
	else
		bs.sync        = self:GetMySync()
	end
	if status.side ~= nil then
		bs.side        = status.side
		userData.side  = status.side
	else
		bs.side        = self:GetMySide() or 0
	end

	playMode = 1 -- not spectator
	if bs.isSpectator then
		playMode = 0 -- spectator
	end
	bs.isReady = playMode

	local battleStatusString = tostring(
		(bs.isReady and 2 or 0) +
		lshift(bs.teamNumber, 2) +
		lshift(bs.allyNumber, 6) +
		lshift(playMode, 10) +
		(bs.sync and 2^22 or 2^23) +
		lshift(bs.side, 24)
	)
	myTeamColor = status.teamColor or math.floor(math.random() * 255 * 2^16 + math.random() * 255 * 2^8 + math.random() * 255)
	self:_SendCommand(concat("MYBATTLESTATUS", battleStatusString, myTeamColor))
	return self
end

-- function Interface:JoinBattleAccept(userName)
-- 	self:super("JoinBattleAccept", userName)
-- 	self:_SendCommand(concat("JOINBATTLEACCEPT", userName))
-- 	return self
-- end
--
-- function Interface:JoinBattleDeny(userName, reason)
-- 	self:super("JoinBattleDeny", userName, reason)
-- 	self:_SendCommand(concat("JOINBATTLEDENY", userName, reason))
-- 	return self
-- end

function Interface:SayBattle(message)
	self:super("SayBattle", message)
	self:_SendCommand(concat("SAYBATTLE", message))
	return self
end

function Interface:SayBattleEx(message)
	self:super("SayBattleEx", message)
	self:_SendCommand(concat("SAYBATTLEEX", message))
	return self
end

function Interface:SetModOptions(data)
	for k, v in pairs(data) do
		if self.modoptions[k] ~= v then
			self:SayBattle("!bSet " .. tostring(k) .. " " .. tostring(v))
		end
		-- self:_SendCommand("SETSCRIPTTAGS game/modoptions/" .. k .. '=' .. v)
	end
	return self
end

function Interface:AddAi(aiName, aiLib, allyNumber, version)
	aiName = aiName:gsub(" ", "")
	local battleStatusString = tostring(
		2 +
		lshift(allyNumber, 2) +
		lshift(allyNumber, 6) +
		lshift(1, 10) +
		(1 and 2^22 or 2^23) +
		lshift(0, 24)
	)
	self:_SendCommand(concat("ADDBOT", aiName, battleStatusString, 0, aiLib))
	return self
end

-- Ugliness
function Interface:StartBattle()
	self:SayBattle("!cv start")
	return self
end

------------------------
-- Channel & private chat commands
------------------------

function Interface:Join(chanName, key)
	self:super("Join", chanName, key)
	if not self:GetInChannel(chanName) then
		self:_SendCommand(concat("JOIN", chanName, key))
	end
	return self
end

function Interface:Leave(chanName)
	self:super("Leave", chanName)
	self:_SendCommand(concat("LEAVE", chanName))
	return
end

function Interface:Say(chanName, message)
	self:super("Say", chanName, message)
	self:_SendCommand(concat("SAY", chanName, message))
	return self
end

function Interface:SayEx(chanName, message)
	self:super("SayEx", chanName, message)
	self:_SendCommand(concat("SAYEX", chanName, message))
	return self
end

function Interface:SayPrivate(userName, message)
	self:super("SayPrivate", userName, message)
	self:_SendCommand(concat("SAYPRIVATE", userName, message))
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

function Interface:_OnTASServer(protocolVersion, springVersion, udpPort, serverMode)
	self:_OnConnect(protocolVersion, springVersion, udpPort, serverMode)
end
Interface.commands["TASServer"] = Interface._OnTASServer
Interface.commandPattern["TASServer"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnMOTD(message)
	-- IGNORED
end
Interface.commands["MOTD"] = Interface._OnMOTD
Interface.commandPattern["MOTD"] = "([^\t]*)"

function Interface:_OnAccepted()
	self:super("_OnAccepted")
end
Interface.commands["ACCEPTED"] = Interface._OnAccepted
Interface.commandPattern["ACCEPTED"] = "(%S+)"

function Interface:_OnDenied(reason)
	self:super("_OnDenied", reason)
end
Interface.commands["DENIED"] = Interface._OnDenied
Interface.commandPattern["DENIED"] = "(.+)"

function Interface:_OnAgreement(line)
	self:super("_OnAgreement", line)
end
Interface.commands["AGREEMENT"] = Interface._OnAgreement
Interface.commandPattern["AGREEMENT"] = "(.*)"

function Interface:_OnAgreementEnd()
	self:super("_OnAgreementEnd")
end
Interface.commands["AGREEMENTEND"] = Interface._OnAgreementEnd

function Interface:_OnRegistrationAccepted()
	self:super("_OnRegistrationAccepted")
end
Interface.commands["REGISTRATIONACCEPTED"] = Interface._OnRegistrationAccepted

function Interface:_OnRegistrationDenied(reason)
	self:super("_OnRegistrationDenied", reason)
end
Interface.commands["REGISTRATIONDENIED"] = Interface._OnRegistrationDenied
Interface.commandPattern["REGISTRATIONDENIED"] = "([^\t]+)"

function Interface:_OnLoginInfoEnd()
	self:super("_OnLoginInfoEnd")
end
Interface.commands["LOGININFOEND"] = Interface._OnLoginInfoEnd

function Interface:_OnPong()
	self:super("_OnPong")
end
Interface.commands["PONG"] = Interface._OnPong

------------------------
-- User commands
------------------------

function Interface:_OnAddUser(userName, country, accountID, lobbyID)
	local userTable = {
		-- constant
		accountID = tonumber(accountID),
		lobbyID = lobbyID,
		-- persistent
		country = country,
		--cpu = tonumber(cpu),
	}
	self:super("_OnAddUser", userName, userTable)
end
Interface.commands["ADDUSER"] = Interface._OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)%s*(.*)"

function Interface:_OnRemoveUser(userName)
	self:super("_OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Interface._OnRemoveUser
Interface.commandPattern["REMOVEUSER"] = "(%S+)"

function Interface:_OnClientStatus(userName, status)
	status = {
		isInGame = (status%2 == 1),
		isAway = (status%4 >= 2),
		isAdmin = rshift(status, 5) % 2 == 1,
		isBot = rshift(status, 6) % 2 == 1,

		-- level is rank in Spring terminology
		level = rshift(status, 2) % 8 + 1,
	}
	self:_OnUpdateUserStatus(userName, status)

	if status.isInGame ~= nil then
		local battleID = self:GetBattleFoundedBy(userName)
		if battleID then
			self:_OnBattleIngameUpdate(battleID, status.isInGame)
		end
		if self.myBattleID and status.isInGame then
			local myBattle = self:GetBattle(self.myBattleID)
			if myBattle and myBattle.founder == userName then
				local battle = self:GetBattle(self.myBattleID)
				self:ConnectToBattle(self.useSpringRestart, battle.ip, battle.port, nil, self:GetScriptPassword())
			end
		end
	end
end
Interface.commands["CLIENTSTATUS"] = Interface._OnClientStatus
Interface.commandPattern["CLIENTSTATUS"] = "(%S+)%s+(%S+)"

--friends
function Interface:_OnFriend(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	self:super("_OnFriend", userName)
end
Interface.commands["FRIEND"] = Interface._OnFriend
Interface.commandPattern["FRIEND"] = "(.+)"

function Interface:_OnUnfriend(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	self:super("_OnUnfriend", userName)
end
Interface.commands["UNFRIEND"] = Interface._OnUnfriend
Interface.commandPattern["UNFRIEND"] = "(.+)"

function Interface:_OnFriendList(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	table.insert(self._friendList, userName)
end
Interface.commands["FRIENDLIST"] = Interface._OnFriendList
Interface.commandPattern["FRIENDLIST"] = "(.+)"

function Interface:_OnFriendListBegin()
	self._friendList = {}
end
Interface.commands["FRIENDLISTBEGIN"] = Interface._OnFriendListBegin

function Interface:_OnFriendListEnd()
	self:super("_OnFriendList", self._friendList)
	self._friendList = {}
end
Interface.commands["FRIENDLISTEND"] = Interface._OnFriendListEnd

-- friend requests
function Interface:_OnFriendRequest(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	self:super("_OnFriendRequest", userName)
end
Interface.commands["FRIENDREQUEST"] = Interface._OnFriendRequest
Interface.commandPattern["FRIENDREQUEST"] = "(.+)"

function Interface:_OnFriendRequestList(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	table.insert(self._friendRequestList, userName)
end
Interface.commands["FRIENDREQUESTLIST"] = Interface._OnFriendRequestList
Interface.commandPattern["FRIENDREQUESTLIST"] = "(.+)"

function Interface:_OnFriendRequestListBegin()
	self._friendRequestList = {}
end
Interface.commands["FRIENDREQUESTLISTBEGIN"] = Interface._OnFriendRequestListBegin

function Interface:_OnFriendRequestListEnd()
	self:super("_OnFriendRequestList", self._friendRequestList)
	self._friendRequestList = {}
end
Interface.commands["FRIENDREQUESTLISTEND"] = Interface._OnFriendRequestListEnd

------------------------
-- Battle commands
------------------------

-- mapHash (32bit) will remain a string, since spring lua uses floats (24bit mantissa)
function Interface:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
	local engineName, engineVersion, map, title, gameName = unpack(explode("\t", other))

	self:super("_OnBattleOpened", tonumber(battleID), {
		founder = founder,
		users = {founder}, -- initial users

		ip = ip,
		port = tonumber(port),

		maxPlayers = tonumber(maxPlayers),
		passworded = tonumber(passworded) ~= 0,

		engineName = engineName,
		engineVersion = engineVersion,
		mapName = map,
		title = title,
		gameName = gameName,

		spectatorCount = 0,
		--playerCount = nil,
		isRunning = self.users[founder].isInGame,

		-- Spring stuff
		-- unsupported
		--type = tonumber(type)
		--natType = tonumber(natType)
	})
end
Interface.commands["BATTLEOPENED"] = Interface._OnBattleOpened
Interface.commandPattern["BATTLEOPENED"] = "(%d+)%s+(%d)%s+(%d)%s+(%S+)%s+(%S+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%S+)%s+(%S+)%s*(.*)"

function Interface:_OnBattleClosed(battleID)
	battleID = tonumber(battleID)
	self:super("_OnBattleClosed", battleID)
end
Interface.commands["BATTLECLOSED"] = Interface._OnBattleClosed
Interface.commandPattern["BATTLECLOSED"] = "(%d+)"

-- hashCode will be a string due to lua limitations
function Interface:_OnJoinBattle(battleID, hashCode)
	self._requestedBattleStatus = nil
	battleID = tonumber(battleID)
	self:super("_OnJoinBattle", battleID, hashCode)
end
Interface.commands["JOINBATTLE"] = Interface._OnJoinBattle
Interface.commandPattern["JOINBATTLE"] = "(%d+)%s+(%S+)"

function Interface:_OnJoinedBattle(battleID, userName, scriptPassword)
	battleID = tonumber(battleID)
	self:super("_OnJoinedBattle", battleID, userName, scriptPassword)
end
Interface.commands["JOINEDBATTLE"] = Interface._OnJoinedBattle
Interface.commandPattern["JOINEDBATTLE"] = "(%d+)%s+(%S+)%s*(%S*)"

-- TODO: Missing _OnBattleScriptPassword

function Interface:_OnLeftBattle(battleID, userName)
	battleID = tonumber(battleID)
	self:super("_OnLeftBattle", battleID, userName)
end
Interface.commands["LEFTBATTLE"] = Interface._OnLeftBattle
Interface.commandPattern["LEFTBATTLE"] = "(%d+)%s+(%S+)"

function Interface:_OnUpdateBattleInfo(battleID, spectatorCount, locked, mapHash, mapName)
	battleID = tonumber(battleID)

	local battleInfo = {
		locked = (locked == "1"),
		mapName = mapName,
		spectatorCount = tonumber(spectatorCount)
	}

	self:super("_OnUpdateBattleInfo", battleID, battleInfo)
end
Interface.commands["UPDATEBATTLEINFO"] = Interface._OnUpdateBattleInfo
Interface.commandPattern["UPDATEBATTLEINFO"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+([^\t]+)"

function Interface:_OnClientBattleStatus(userName, battleStatus, teamColor)
	battleStatus = tonumber(battleStatus)
	status = {
		isReady      = rshift(battleStatus, 1) % 2 == 1,
		teamNumber   = rshift(battleStatus, 2) % 16,
		allyNumber   = rshift(battleStatus, 6) % 16,
		isSpectator  = rshift(battleStatus, 10) % 2 == 0,
		handicap     = rshift(battleStatus, 11) % 128,
		sync         = rshift(battleStatus, 22) % 4,
		side         = rshift(battleStatus, 24) % 16,
	}
	self:_OnUpdateUserBattleStatus(userName, status)
end
Interface.commands["CLIENTBATTLESTATUS"] = Interface._OnClientBattleStatus
Interface.commandPattern["CLIENTBATTLESTATUS"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnAddBot(battleID, name, owner, battleStatus, teamColor, aiDll)
	battleID = tonumber(battleID)
	-- local ai, dll = unpack(explode("\t", aiDll)))
	Spring.Echo(battleID, name, owner, battleStatus, teamColor, aiDll)
	Spring.Echo(battleStatus)
	battleStatus = tonumber(battleStatus)
	Spring.Echo(battleStatus)
	status = {
		isReady      = rshift(battleStatus, 1) % 2 == 1,
		teamNumber   = rshift(battleStatus, 2) % 16,
		allyNumber   = rshift(battleStatus, 6) % 16,
		isSpectator  = rshift(battleStatus, 10) % 2 == 0,
		handicap     = rshift(battleStatus, 11) % 128,
		sync         = rshift(battleStatus, 22) % 4,
		side         = rshift(battleStatus, 24) % 16,
	}
	self:_OnAddAi(battleID, name, status)
end
Interface.commands["ADDBOT"] = Interface._OnAddBot
Interface.commandPattern["ADDBOT"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnRemoveBot(battleID, name)
	battleID = tonumber(battleID)
	self:_OnRemoveAi(battleID, name)
end
Interface.commands["REMOVEBOT"] = Interface._OnRemoveBot
Interface.commandPattern["REMOVEBOT"] = "(%d+)%s+(%S+)"

function Interface:_OnSaidBattle(userName, message)
	self:super("_OnSaidBattle", userName, message)
end
Interface.commands["SAIDBATTLE"] = Interface._OnSaidBattle
Interface.commandPattern["SAIDBATTLE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidBattleEx(userName, message)
	self:super("_OnSaidBattleEx", userName, message)
end
Interface.commands["SAIDBATTLEEX"] = Interface._OnSaidBattleEx
Interface.commandPattern["SAIDBATTLEEX"] = "(%S+)%s+(.*)"

------------------------
-- Channel & private chat commands
------------------------

function Interface:_OnJoin(chanName)
	self:super("_OnJoin", chanName)
end
Interface.commands["JOIN"] = Interface._OnJoin
Interface.commandPattern["JOIN"] = "(%S+)"

function Interface:_OnJoined(chanName, userName)
	self:super("_OnJoined", chanName, userName)
end
Interface.commands["JOINED"] = Interface._OnJoined
Interface.commandPattern["JOINED"] = "(%S+)%s+(%S+)"

function Interface:_OnJoinFailed(chanName, reason)
	self:super("_OnJoinFailed", chanName, reason)
end
Interface.commands["JOINFAILED"] = Interface._OnJoinFailed
Interface.commandPattern["JOINFAILED"] = "(%S+)%s+([^\t]+)"

function Interface:_OnLeft(chanName, userName, reason)
	self:super("_OnLeft", chanName, userName, reason)
end
Interface.commands["LEFT"] = Interface._OnLeft
Interface.commandPattern["LEFT"] = "(%S+)%s+(%S+)%s*([^\t]*)"

function Interface:_OnClients(chanName, clientsStr)
	local clients = explode(" ", clientsStr)
	self:super("_OnClients", chanName, clients)
end
Interface.commands["CLIENTS"] = Interface._OnClients
Interface.commandPattern["CLIENTS"] = "(%S+)%s+(.+)"

function Interface:_OnChannel(chanName, userCount, topic)
	userCount = tonumber(userCount)
	self:super("_OnChannel", chanName, userCount, topic)
end
Interface.commands["CHANNEL"] = Interface._OnChannel
Interface.commandPattern["CHANNEL"] = "(%S+)%s+(%d+)%s*(.*)"

function Interface:_OnEndOfChannels()
	self:_CallListeners("OnEndOfChannels")
end
Interface.commands["ENDOFCHANNELS"] = Interface._OnEndOfChannels

function Interface:_OnChannelMessage(chanName, message)
	self:super("_OnChannelMessage", chanName, message)
end
Interface.commands["CHANNELMESSAGE"] = Interface._OnChannelMessage
Interface.commandPattern["CHANNELMESSAGE"] = "(%S+)%s+(%S+)"

function Interface:_OnChannelTopic(chanName, author, topic)
	topic = topic and tostring(topic) or ""
	self:super("_OnChannelTopic", chanName, author, 0, topic)
end
Interface.commands["CHANNELTOPIC"] = Interface._OnChannelTopic
Interface.commandPattern["CHANNELTOPIC"] = "(%S+)%s+(%S+)%s*(.*)"

function Interface:_OnSaid(chanName, userName, message)
	self:super("_OnSaid", chanName, userName, message)
end
Interface.commands["SAID"] = Interface._OnSaid
Interface.commandPattern["SAID"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnSaidEx(chanName, userName, message)
	self:super("_OnSaidEx", chanName, userName, message)
end
Interface.commands["SAIDEX"] = Interface._OnSaidEx
Interface.commandPattern["SAIDEX"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnSaidPrivate(userName, message)
	self:super("_OnSaidPrivate", userName, message)
end
Interface.commands["SAIDPRIVATE"] = Interface._OnSaidPrivate
Interface.commandPattern["SAIDPRIVATE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidPrivateEx(userName, message)
	self:super("_OnSaidPrivateEx", userName, message)
end
Interface.commands["SAIDPRIVATEEX"] = Interface._OnSaidPrivateEx
Interface.commandPattern["SAIDPRIVATEEX"] = "(%S+)%s+(.*)"

function Interface:_OnSayPrivate(userName, message)
	self:super("_OnSayPrivate", userName, message)
end
Interface.commands["SAYPRIVATE"] = Interface._OnSayPrivate
Interface.commandPattern["SAYPRIVATE"] = "(%S+)%s+(.*)"

------------
------------
-- TODO
------------
------------

function Interface:UpdateBotStatus(data)
	Spring.Echo("Implement UpdateBotStatus with ADDBOT etc..")
end

function Interface:AddStartRect(allyNo, left, top, right, bottom)
	self:_SendCommand(concat("ADDSTARTRECT", allyNo, left, top, right, bottom))
	return self
end

function Interface:ChangeEmail(newEmail, userName)
	self:_SendCommand(concat("CHANGEEMAIL", newEmail, userName))
	return self
end

function Interface:ChangePassword(oldPassword, newPassword)
	self:_SendCommand(concat("CHANGEPASSWORD", oldPassword, newPassword))
	return self
end

function Interface:Channels()
	self:_SendCommand("CHANNELS")
	return self
end

function Interface:ChannelTopic(chanName, topic)
	self:_SendCommand(concat("CHANNELTOPIC", chanName, topic))
	return self
end

function Interface:CloseQueue(name)
	self:_SendCommand(concat("CLOSEQUEUE", json.encode(name)))
	return self
end

function Interface:ConfirmAgreement(verif_code)
	self:_SendCommand(concat("CONFIRMAGREEMENT", verif_code))
	return self
end

function Interface:ConnectUser(userName, ip, port, engine, scriptPassword)
	self:_SendCommand(concat("CONNECTUSER", json.encode({userName=userName, ip=ip, port=port, engine=engine, scriptPassword=scriptPassword})))
	return self
end

function Interface:DisableUnits(...)
	self:_SendCommand(concat("DISABLEUNITS", ...))
	return self
end

function Interface:EnableAllUnits()
	self:_SendCommand("ENABLEALLUNITS")
	return self
end

function Interface:EnableUnits(...)
	self:_SendCommand(concat("ENABLEUNITS", ...))
	return self
end

function Interface:Exit(reason)
	-- should this could be set _after_ server has disconnected us?
	self.status = "offline"
	self.finishedConnecting = false
	self:_SendCommand(concat("EXIT", reason))
	return self
end

function Interface:ForceAllyNo(userName, teamNo)
	self:_SendCommand(concat("FORCEALLYNO", userName, teamNo))
	return self
end

function Interface:ForceJoinBattle(userName, destinationBattleId, destinationBattlePassword)
	self:_SendCommand(concat("FORCEJOINBATTLE", userName, destinationBattleId, destinationBattlePassword))
	return self
end

function Interface:ForceLeaveChannel(chanName, userName, reason)
	self:_SendCommand(concat("FORCELEAVECHANNEL", chanName, userName, reason))
	return self
end

function Interface:ForceSpectatorMode(userName)
	self:_SendCommand(concat("FORCESPECTATORMODE", userName))
	return self
end

function Interface:ForceTeamColor(userName, color)
	self:_SendCommand(concat("FORCETEAMCOLOR", userName, color))
	return self
end

function Interface:ForceTeamNo(userName, teamNo)
	self:_SendCommand(concat("FORCETEAMNO", userName, teamNo))
	return self
end

function Interface:GetInGameTime()
	self:_SendCommand("GETINGAMETIME")
	return self
end

function Interface:Handicap(userName, value)
	self:_SendCommand(concat("HANDICAP", userName, value))
	return self
end

function Interface:InviteTeam(userName)
	self:_SendCommand(concat("INVITETEAM", json.encode({userName=userName})))
	return self
end

function Interface:InviteTeamAccept(userName)
	self:_SendCommand(concat("INVITETEAMACCEPT", json.encode({userName=userName})))
	return self
end

function Interface:InviteTeamDecline(userName)
	self:_SendCommand(concat("INVITETEAMDECLINE", json.encode({userName=userName})))
	return self
end

function Interface:JoinQueue(name, params)
	local tbl = {name=name}
	if params ~= nil then
		tbl["params"] = params
	end
	self:_SendCommand(concat("JOINQUEUE", json.encode(tbl)))
	return self
end

function Interface:JoinQueueAccept(name, userNames)
	self:_SendCommand(concat("JOINQUEUEACCEPT", json.encode({name=name,userNames=userNames})))
	return self
end

function Interface:JoinQueueDeny(name, userNames, reason)
	self:_SendCommand(concat("JOINQUEUEDENY", json.encode({name=name,userNames=userNames,reason=reason})))
	return self
end

function Interface:KickFromBattle(userName)
	self:_SendCommand(concat("KICKFROMBATTLE", userName))
	return self
end

function Interface:KickFromTeam(userName)
	self:_SendCommand(concat("KICKFROMTEAM", json.encode({userName=userName})))
	return self
end

function Interface:LeaveTeam()
	self:_SendCommand("LEAVETEAM")
	return self
end

function Interface:LeaveQueue(name)
	self:_SendCommand(concat("LEAVEQUEUE", json.encode({name=name})))
	return self
end

function Interface:ListCompFlags()
	self:_SendCommand("LISTCOMPFLAGS")
	return self
end

function Interface:ListQueues()
	self:_SendCommand("LISTQUEUES")
	return self
end

function Interface:MuteList(chanName)
	self:_SendCommand(concat("MUTELIST", chanName))
	return self
end

function Interface:MyStatus(status)
	self:_SendCommand(concat("MYSTATUS", status))
	return self
end

function Interface:OpenBattle(type, natType, password, port, maxPlayers, gameHash, rank, mapHash, engineName, engineVersion, map, title, gameName)
	self:_SendCommand(concat("OPENBATTLE", type, natType, password, port, maxPlayers, gameHash, rank, mapHash, engineName, "\t", engineVersion, "\t", map, "\t", title, "\t", gameName))
	return self
end

function Interface:OpenQueue(queue)
	self:_SendCommand(concat("OPENQUEUE", json.encode({queue=queue})))
	return self
end

function Interface:RecoverAccount(email, userName)
	self:_SendCommand(concat("RECOVERACCOUNT", email, userName))
	return self
end

function Interface:ReadyCheck(name, userNames, responseTime)
	self:_SendCommand(concat("READYCHECK", json.encode({name=name, userNames=userNames, responseTime=responseTime})))
	return self
end

function Interface:ReadyCheckResponse(name, response, responseTime)
	local response = {name=name, response=response}
	if responseTime ~= nil then
		response.responseTime = responseTime
	end
	self:_SendCommand(concat("READYCHECKRESPONSE", json.encode(response)))
	return self
end

function Interface:RemoveBot(name)
	self:_SendCommand(concat("REMOVEBOT", name))
	return self
end

function Interface:RemoveQueueUser(name, userNames)
	self:_SendCommand(concat("REMOVEQUEUEUSER", {name=name, userNames=userNames}))
	return self
end

function Interface:RemoveScriptTags(...)
	self:_SendCommand(concat("REMOVESCRIPTTAGS", ...))
	return self
end

function Interface:RemoveStartRect(allyNo)
	self:_SendCommand(concat("REMOVESTARTRECT", allyNo))
	return self
end

function Interface:RenameAccount(newUsername)
	self:_SendCommand(concat("RENAMEACCOUNT", newUsername))
	return self
end

function Interface:Ring(userName)
	self:_SendCommand(concat("RING", userName))
	return self
end

-- function Interface:SayData(chanName, message)
-- 	self:_SendCommand(concat("SAYDATA", chanName, message))
-- 	return self
-- end
--
-- function Interface:SayDataBattle(message)
-- 	self:_SendCommand(concat("SAYDATABATTLE", message))
-- 	return self
-- end
--
-- function Interface:SayDataPrivate(userName, message)
-- 	self:_SendCommand(concat("SAYDATAPRIVATE", userName, message))
-- 	return self
-- end

function Interface:SayTeam(msg)
	self:_SendCommand(concat("SAYTEAM", json.encode({msg=msg})))
	return self
end

function Interface:SayTeamEx(msg)
	self:_SendCommand(concat("SAYTEAMEX", json.encode({msg=msg})))
	return self
end

function Interface:Script(line)
	self:_SendCommand(concat("SCRIPT", line))
	return self
end

function Interface:ScriptEnd()
	self:_SendCommand("SCRIPTEND")
	return self
end

function Interface:ScriptStart()
	self:_SendCommand("SCRIPTSTART")
	return self
end

function Interface:SetScriptTags(...)
	self:_SendCommand(concat("SETSCRIPTTAGS", ...))
	return self
end

function Interface:SetTeamLeader(userName)
	self:_SendCommand(concat("SETTEAMLEADER", json.encode({userName=userName})))
	return self
end

function Interface:TestLogin(userName, password)
	self:_SendCommand(concat("TESTLOGIN", userName, password))
	return self
end

function Interface:UpdateBattleInfo(spectatorCount, locked, mapHash, mapName)
	self:_SendCommand(concat("UPDATEBATTLEINFO", spectatorCount, locked, mapHash, mapName))
	return self
end

function Interface:UpdateBot(name, battleStatus, teamColor)
	self:_SendCommand(concat("UPDATEBOT", name, battleStatus, teamColor))
	return self
end

--TODO: should also send a respond with USERID
function Interface:_OnAcquireUserID()
	self:_CallListeners("OnAcquireUserID", username)
end
Interface.commands["ACQUIREUSERID"] = Interface._OnAcquireUserID

function Interface:_OnAddStartRect(allyNo, left, top, right, bottom)
	self:_CallListeners("OnAddStartRect", allyNo, left, top, right, bottom)
end
Interface.commands["ADDSTARTRECT"] = Interface._OnAddStartRect
Interface.commandPattern["ADDSTARTRECT"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnBroadcast(message)
	self:_CallListeners("OnBroadcast", message)
end
Interface.commands["BROADCAST"] = Interface._OnBroadcast
Interface.commandPattern["BROADCAST"] = "(.+)"

function Interface:_OnClientIpPort(userName, ip, port)
	self:_CallListeners("OnClientIpPort", userName, ip, port)
end
Interface.commands["CLIENTIPPORT"] = Interface._OnClientIpPort
Interface.commandPattern["CLIENTIPPORT"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnCompFlags(compFlags)
	compFlags = explode("\t", compflags)
	self:_CallListeners("OnCompFlags", compFlags)
end
Interface.commands["COMPFLAGS"] = Interface._OnCompFlags
Interface.commandPattern["COMPFLAGS"] = "(%S+)%s+(%S+)"

function Interface:_OnConnectUser(obj)
	self:_CallListeners("OnConnectUser", obj.ip, obj.port, obj.engine, obj.password)
end
Interface.jsonCommands["CONNECTUSER"] = Interface._OnConnectUser

function Interface:_OnConnectUserFailed(obj)
	self:_CallListeners("OnConnectUserFailed", obj.userName, obj.reason)
end
Interface.jsonCommands["CONNECTUSERFAILED"] = Interface._OnConnectUserFailed

function Interface:_OnDisableUnits(unitNames)
	unitNames = explode(" ", unitNames)
	self:_CallListeners("OnDisableUnits", unitNames)
end
Interface.commands["DISABLEUNITS"] = Interface._OnDisableUnits
Interface.commandPattern["DISABLEUNITS"] = "(.+)"

function Interface:_OnEnableAllUnits()
	self:_CallListeners("OnEnableAllUnits")
end
Interface.commands["ENABLEALLUNITS"] = Interface._OnEnableAllUnits

function Interface:_OnEnableUnits(unitNames)
	unitNames = explode(" ", unitNames)
	self:_CallListeners("OnEnableUnits", unitNames)
end
Interface.commands["ENABLEUNITS"] = Interface._OnEnableUnits
Interface.commandPattern["ENABLEUNITS"] = "(.+)"

function Interface:_OnForceJoinBattle(destinationBattleID, destinationBattlePassword)
	destinationBattleID = tonumber(destinationBattleID)
	self:_CallListeners("OnForceJoinBattle", destinationBattleID, destinationBattlePassword)
end
Interface.commands["FORCEJOINBATTLE"] = Interface._OnForceJoinBattle
Interface.commandPattern["FORCEJOINBATTLE"] = "(%d+)%s*(%S*)"

function Interface:_OnForceJoinBattleFailed(userName, reason)
	self:_CallListeners("OnForceJoinBattleFailed", userName, reason)
end
Interface.commands["FORCEJOINBATTLEFAILED"] = Interface._OnForceJoinBattleFailed
Interface.commandPattern["FORCEJOINBATTLEFAILED"] = "(%S+)%s*([^\t]*)"

function Interface:_OnForceLeaveChannel(chanName, userName, reason)
	self:_CallListeners("OnForceLeaveChannel", chanName, userName, reason)
end
Interface.commands["FORCELEAVECHANNEL"] = Interface._OnForceLeaveChannel
Interface.commandPattern["FORCELEAVECHANNEL"] = "(%S+)%s+(%S+)%s*([^\t]*)"

function Interface:_OnForceQuitBattle()
	self:_CallListeners("OnForceQuitBattle")
end
Interface.commands["FORCEQUITBATTLE"] = Interface._OnForceQuitBattle

function Interface:_OnHostPort(port)
	port = tonumber(port)
	self:_CallListeners("OnHostPort", port)
end
Interface.commands["HOSTPORT"] = Interface._OnHostPort
Interface.commandPattern["HOSTPORT"] = "(%d+)"

function Interface:_OnJoinBattleFailed(reason)
	self:_CallListeners("OnJoinBattleFailed", reason)
end
Interface.commands["JOINBATTLEFAILED"] = Interface._OnJoinBattleFailed
Interface.commandPattern["JOINBATTLEFAILED"] = "([^\t]+)"

function Interface:_OnJoinBattleRequest(userName, ip)
	self:_CallListeners("OnJoinBattleRequest", userName, ip)
end
Interface.commands["JOINBATTLEREQUEST"] = Interface._OnJoinBattleRequest
Interface.commandPattern["JOINBATTLEREQUEST"] = "(%S+)%s+(%S+)"

function Interface:_OnJoinQueue(obj)
	local name = obj.name
	self:_CallListeners("OnJoinQueue", name)
end
Interface.jsonCommands["JOINQUEUE"] = Interface._OnJoinQueue

function Interface:_OnJoinQueueRequest(obj)
	local name = obj.name
	local userNames = obj.userNames
	local params = obj.params
	self:_CallListeners("OnJoinQueueRequest", name, userNames, params)
end
Interface.jsonCommands["JOINQUEUEREQUEST"] = Interface._OnJoinQueueRequest

function Interface:_OnJoinedQueue(obj)
	local name = obj.name
	local userNames = obj.userNames
	local params = obj.params
	self:_CallListeners("OnJoinedQueue", name, userNames, params)
end
Interface.jsonCommands["JOINEDQUEUE"] = Interface._OnJoinedQueue

function Interface:_OnJoinQueueFailed(obj)
	local name = obj.name
	local reason = obj.reason
	self:_CallListeners("OnJoinQueueFailed", name, reason)
end
Interface.jsonCommands["JOINQUEUEFAILED"] = Interface._OnJoinQueueFailed

function Interface:_OnJoinTeam(obj)
	local userNames = obj.userNames
	local leader = obj.leader
	self:_CallListeners("OnJoinTeam", userNames, leader)
end
Interface.jsonCommands["JOINTEAM"] = Interface._OnJoinTeam

function Interface:_OnJoinedTeam(obj)
	local userName = obj.userName
	self:_CallListeners("OnJoinedTeam", userName)
end
Interface.jsonCommands["JOINEDTEAM"] = Interface._OnJoinedTeam

function Interface:_OnLeftQueue(obj)
	self:_CallListeners("OnLeftQueue", obj.name, obj.reason)
end
Interface.jsonCommands["LEFTQUEUE"] = Interface._OnLeftQueue

function Interface:_OnLeftTeam(obj)
	local userName = obj.userName
	local reason = obj.reason
	self:_CallListeners("OnLeftTeam", userName, reason)
end
Interface.jsonCommands["LEFTTEAM"] = Interface._OnLeftTeam

function Interface:_OnMuteList(muteDescription)
	self:_CallListeners("OnMuteList", muteDescription)
end
Interface.commands["MUTELIST"] = Interface._OnMuteList
Interface.commandPattern["MUTELIST"] = "([^\t]*)"

function Interface:_OnMuteListBegin(chanName)
	self:_CallListeners("OnMuteListBegin", chanName)
end
Interface.commands["MUTELISTBEGIN"] = Interface._OnMuteListBegin
Interface.commandPattern["MUTELISTBEGIN"] = "(%S+)"

function Interface:_OnMuteListEnd()
	self:_CallListeners("OnMuteListEnd")
end
Interface.commands["MUTELISTEND"] = Interface._OnMuteListEnd

function Interface:_OnOpenBattle(battleID)
	battleID = tonumber(battleID)
	self:_CallListeners("OnOpenBattle", battleID)
end
Interface.commands["OPENBATTLE"] = Interface._OnOpenBattle
Interface.commandPattern["OPENBATTLE"] = "(%d+)"

function Interface:_OnOpenBattleFailed(reason)
	self:_CallListeners("OnOpenBattleReason", reason)
end
Interface.commands["OPENBATTLEFAILED"] = Interface._OnOpenBattleFailed
Interface.commandPattern["OPENBATTLEFAILED"] = "([^\t]+)"

function Interface:_QueueOpened(obj)
	self:_OnQueueOpened(obj.name, obj.title, obj.mapNames, nil, obj.gameNames)
end
Interface.jsonCommands["QUEUEOPENED"] = Interface._QueueOpened

function Interface:_QueueClosed(obj)
	self:_OnQueueClosed(obj.name)
end
Interface.jsonCommands["QUEUECLOSED"] = Interface._QueueClosed

function Interface:_OnQueueLeft(obj)
	self:_CallListeners("OnQueueLeft", obj.name, obj.userNames)
end
Interface.jsonCommands["QUEUELEFT"] = Interface._OnQueueLeft

function Interface:_OnReadyCheck(obj)
	self:_CallListeners("OnReadyCheck", obj.name, obj.responseTime)
end
Interface.jsonCommands["READYCHECK"] = Interface._OnReadyCheck

function Interface:_OnReadyCheckResult(obj)
	self:_CallListeners("OnReadyCheckResult", obj.name, obj.result)
end
Interface.jsonCommands["READYCHECKRESULT"] = Interface._OnReadyCheckResult

function Interface:_OnReadyCheckResponse(obj)
	self:_CallListeners("OnReadyCheckResponse", obj.name, obj.userName, obj.answer, obj.responseTime)
end
Interface.jsonCommands["READYCHECKRESPONSE"] = Interface._OnReadyCheckResponse

function Interface:_OnRedirect(ip)
	self:_CallListeners("OnRedirect", ip)
end
Interface.commands["REDIRECT"] = Interface._OnRedirect
Interface.commandPattern["REDIRECT"] = "(%S+)"

function Interface:_OnRemoveScriptTags(keys)
	keys = explode(" ", keys)
	self:_CallListeners("OnRemoveScriptTags", keys)
end
Interface.commands["REMOVESCRIPTTAGS"] = Interface._OnRemoveScriptTags
Interface.commandPattern["REMOVESCRIPTTAGS"] = "([^\t]+)"

function Interface:_OnRemoveStartRect(allyNo)
	allyNo = tonumber(allyNo)
	self:_CallListeners("OnRemoveStartRect", allyNo)
end
Interface.commands["REMOVESTARTRECT"] = Interface._OnRemoveStartRect
Interface.commandPattern["REMOVESTARTRECT"] = "(%d+)"

function Interface:_OnRequestBattleStatus()
	self._requestedBattleStatus = true
	self:SetBattleStatus({})
end
Interface.commands["REQUESTBATTLESTATUS"] = Interface._OnRequestBattleStatus

function Interface:_OnRing(userName)
	self:_CallListeners("OnRing", userName)
end
Interface.commands["RING"] = Interface._OnRing
Interface.commandPattern["RING"] = "(%S+)"

-- function Interface:_OnSaidData(chanName, userName, message)
-- 	self:_CallListeners("OnSaidData", chanName, userName, message)
-- end
-- Interface.commands["SAIDDATA"] = Interface._OnSaidData
-- Interface.commandPattern["SAIDDATA"] = "(%S+)%s+(%S+)%s+(.*)"
--
-- function Interface:_OnSaidDataBattle(userName, message)
-- 	self:_CallListeners("OnSaidDataBattle", userName, message)
-- end
-- Interface.commands["SAIDDATABATTLE"] = Interface._OnSaidDataBattle
-- Interface.commandPattern["SAIDDATABATTLE"] = "(%S+)%s+(.*)"
--
-- function Interface:_OnSaidDataPrivate(userName, message)
-- 	self:_CallListeners("OnSaidDataPrivate", userName, message)
-- end
-- Interface.commands["SAIDDATAPRIVATE"] = Interface._OnSaidDataPrivate
-- Interface.commandPattern["SAIDDATAPRIVATE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidTeam(obj)
	local userName = obj.userName
	local msg = obj.msg
	self:_CallListeners("OnSaidTeam", userName, msg)
end
Interface.jsonCommands["SAIDTEAM"] = Interface._OnSaidTeam

function Interface:_OnSaidTeamEx(obj)
	local userName = obj.userName
	local msg = obj.msg
	self:_CallListeners("OnSaidTeamEx", userName, msg)
end
Interface.jsonCommands["SAIDTEAMEX"] = Interface._OnSaidTeamEx

-- function Interface:_OnScript(line)
-- 	self:_CallListeners("OnScript", line)
-- end
-- Interface.commands["SCRIPT"] = Interface._OnScript
-- Interface.commandPattern["SCRIPT"] = "([^\t]+)"
--
-- function Interface:_OnScriptEnd()
-- 	self:_CallListeners("OnScriptEnd")
-- end
-- Interface.commands["SCRIPTEND"] = Interface._OnScriptEnd
--
-- function Interface:_OnScriptStart()
-- 	self:_CallListeners("OnScriptStart")
-- end
-- Interface.commands["SCRIPTSTART"] = Interface._OnScriptStart

function Interface:_OnServerMSG(message)
	self:_CallListeners("OnServerMSG", message)
end
Interface.commands["SERVERMSG"] = Interface._OnServerMSG
Interface.commandPattern["SERVERMSG"] = "([^\t]+)"

function Interface:_OnServerMSGBox(message, url)
	self:_CallListeners("OnServerMSG", message, url)
end
Interface.commands["SERVERMSGBOX"] = Interface._OnServerMSGBox
Interface.commandPattern["SERVERMSGBOX"] = "([^\t]+)\t+([^\t]+)"

local mod_opts_pre = "game/modoptions/"
local mod_opts_pre_indx = #mod_opts_pre + 1
local function string_starts(String, Start)
	return string.sub(String, 1, string.len(Start)) == Start
end
function Interface:_OnSetScriptTags(tagsTxt)
	local tags = explode("\t", tagsTxt)
	if self.modoptions == nil then
		self.modoptions = {}
	end
	for _, tag in pairs(tags) do
		if string_starts(tag, mod_opts_pre) then
			local kv = tag:sub(mod_opts_pre_indx)
			local kvTable = explode("=", kv)
			local k = kvTable[1]
			local v = kvTable[2]
			self.modoptions[k] = v
		end
	end
	self:_OnSetModOptions(self.modoptions)
end
Interface.commands["SETSCRIPTTAGS"] = Interface._OnSetScriptTags
Interface.commandPattern["SETSCRIPTTAGS"] = "(.*)"
-- Interface.commandPattern["SETSCRIPTTAGS"] = "([^\t]+)"

function Interface:_OnSetTeamLeader(obj)
	local userName = obj.userName
	self:_CallListeners("OnSetTeamLeader", userName)
end
Interface.jsonCommands["SETTEAMLEADER"] = Interface._OnSetTeamLeader

function Interface:_OnTestLoginAccept(message)
	self:_CallListeners("OnTestLoginAccept", message)
end
Interface.commands["TESTLOGINACCEPT"] = Interface._OnTestLoginAccept

function Interface:_OnTestLoginDeny(message)
	self:_CallListeners("OnTestLoginDeny", message)
end
Interface.commands["TESTLOGINDENY"] = Interface._OnTestLoginDeny

function Interface:_OnUDPSourcePort(port)
	port = tonumber(port)
	self:_CallListeners("OnUDPSourcePort", port)
end
Interface.commands["UDPSOURCEPORT"] = Interface._OnUDPSourcePort
Interface.commandPattern["UDPSOURCEPORT"] = "(%d+)"

function Interface:_OnUpdateBot(battleID, name, battleStatus, teamColor)
	battleID = tonumber(battleID)
	self:_CallListeners("OnUpdateBot", battleID, name, battleStatus, teamColor)
end
Interface.commands["UPDATEBOT"] = Interface._OnUpdateBot
Interface.commandPattern["UPDATEBOT"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnIgnoreListParse(tags)
	local tags = parseTags(tags)
	local userName = getTag(tags, "userName", true)
	local reason = getTag(tags, "reason")
	self:_OnIgnoreList(userName, reason)
end

function Interface:_OnIgnoreList(userName, reason)
	self:_CallListeners("OnIgnoreList", userName, reason)
end
Interface.commands["IGNORELIST"] = Interface._OnIgnoreListParse
Interface.commandPattern["IGNORELIST"] = "(.+)"

function Interface:_OnIgnoreListBegin()
	self:_CallListeners("OnIgnoreListBegin")
end
Interface.commands["IGNORELISTBEGIN"] = Interface._OnIgnoreListBegin

function Interface:_OnIgnoreListEnd()
	self:_CallListeners("OnIgnoreListEnd")
end
Interface.commands["IGNORELISTEND"] = Interface._OnIgnoreListEnd

function Interface:_OnInviteTeam(obj)
	self:_CallListeners("OnInviteTeam", obj.userName)
end
Interface.jsonCommands["INVITETEAM"] = Interface._OnInviteTeam

function Interface:_OnInviteTeamAccepted(obj)
	self:_CallListeners("OnInviteTeamAccepted", obj.userName)
end
Interface.jsonCommands["INVITETEAMACCEPTED"] = Interface._OnInviteTeamAccepted

function Interface:_OnInviteTeamDeclined(obj)
	self:_CallListeners("OnInviteTeamDeclined", obj.userName, obj.reason)
end
Interface.jsonCommands["INVITETEAMDECLINED"] = Interface._OnInviteTeamDeclined

function Interface:_OnListQueues(queues)
	self.queueCount = 0
	self.queues = {}
	for _, queue in pairs(queues) do
		self:_OnQueueOpened(obj.name, obj.title, obj.mapNames, nil, obj.gameNames)
	end
end
Interface.jsonCommands["LISTQUEUES"] = Interface._OnListQueues

return Interface
