if not Spring.GetConfigInt("LuaSocketEnabled", 0) == 1 then
    Spring.Echo("LuaSocketEnabled is disabled")
    return false
end

local function dumpConfig()
	-- dump all luasocket related config settings to console
	for _, conf in ipairs({"TCPAllowConnect", "TCPAllowListen", "UDPAllowConnect", "UDPAllowListen"  }) do
		Spring.Echo(conf .. " = " .. Spring.GetConfigString(conf, ""))
	end
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

local function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  -- for each divider found
  for st,sp in function() return string.find(str,div,pos,true) end do
    table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
    pos = sp + 1 -- Jump past current divider
  end
  table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
  return arr
end

local function concat(...)
    return table.concat({...}, " ")
end

Interface = Observable:extends{}

-- map lobby commands by name
Interface.commands = {}
-- define command format with pattern (regex)
Interface.commandPattern = {}

function Interface:Initialize()
   -- dumpConfig()
    self.messagesSentCount = 0
    self.messagesReceivedCount = 0
    self.lastSentSeconds = Spring.GetGameSeconds()
    self.connected = false
    self.listeners = {}
    self.awaitingChannelsList = false
end

function Interface:Connect(host, port)
    self.client = socket.tcp()
	self.client:settimeout(0)
	local res, err = self.client:connect(host, port)
	if res == nil and not res == "timeout" then
		Spring.Echo("Error in connect: " .. err)
		return false
	end
    self.connected = true
	return true
end

function Interface:_SendCommand(command, sendMessageCount)
    if sendMessageCount then
        self.messagesSentCount = self.messagesSentCount + 1
        command = "#" .. self.messagesSentCount .. " " .. command
    end
    if command[#command] ~= "\n" then
        command = command .. "\n"
    end
    self.client:send(command)
    self:CallListeners("OnCommandSent", command:sub(1, #command-1))
    self.lastSentSeconds = Spring.GetGameSeconds()
end

function Interface:SendCustomCommand(command)
    self:_SendCommand(command, false)
end

function Interface:Login(user, password, cpu, localIP)
    if localIP == nil then
        localIP = "*"
    end
    -- use HASH command so we can send passwords in plain text
    self:_SendCommand("HASH")
    self:_SendCommand(concat("LOGIN", user, password, cpu, localIP, "LuaLobby"))
end

function Interface:Ping()
    self:_SendCommand("PING", true)
end

function Interface:Join(chanName, key)
    local command = concat("JOIN", chanName)
    if key ~= nil then
        command = concat(command, key)
    end
    self:_SendCommand(command, true)
end

function Interface:OnAccepted(username)
    self:CallListeners("OnAccepted", username)
end
Interface.commands["ACCEPTED"] = Interface.OnAccepted
Interface.commandPattern["ACCEPTED"] = "(%S+)"

--TODO: should also send a respond with USERID
function Interface:OnAcquireUserID()
    self:CallListeners("OnAcquireUserID", username)
end
Interface.commands["ACQUIREUSERID"] = Interface.OnAcquireUserID

function Interface:OnAddBot(battleID, name, battleStatus, teamColor, aiDll)
    battleID = tonumber(battleID)
    local ai, dll = explode(aiDll, "\t")
    self:CallListeners("OnAddBot", battleID, name, battleStatus, teamColor, ai, dll)
end
Interface.commands["ADDBOT"] = Interface.OnAddBot
Interface.commandPattern["ADDBOT"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(.*)"

function Interface:OnAddStartRect(allyNo, left, top, right, bottom)
    self:CallListeners("OnAddStartRect", allyNo, left, top, right, bottom)
end
Interface.commands["ADDSTARTRECT"] = Interface.OnAddStartRect
Interface.commandPattern["ADDSTARTRECT"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)
    self:CallListeners("OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Interface.OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)%s*(.*)"

function Interface:OnAgreement(line)
    self:CallListeners("OnAgreement", line)
end
Interface.commands["AGREEMENT"] = Interface.OnAgreement
Interface.commandPattern["DENIED"] = "(.+)"

function Interface:OnAgreementEnd()
    self:CallListeners("OnAgreementEnd")
end
Interface.commands["AGREEMENTEND"] = Interface.OnAgreementEnd

function Interface:OnBattleClosed(battleID)
    battleID = tonumber(battleID)
    self:CallListeners("OnBattleClosed", battleID)
end
Interface.commands["BATTLECLOSED"] = Interface.OnBattleClosed
Interface.commandPattern["BATTLECLOSED"] = "(%d+)"

-- mapHash (32bit) will remain a string, since spring lua uses floats (24bit mantissa)
function Interface:OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
    battleID = tonumber(battleID)
    type = tonumber(type)
    natType = tonumber(natType)
    port = tonumber(port)
    maxPlayers = tonumber(maxPlayers)
    passworded = tonumber(passworded)
    local engineName, engineVersion, map, title, gameName = explode(other, "\t")
    self:CallListeners("OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, engineName, engineVersion, map, title, gameName)
end
Interface.commands["BATTLEOPENED"] = Interface.OnBattleOpened
Interface.commandPattern["BATTLEOPENED"] = "(%d+)%s+(%d)%s+(%d)%s+(%S+)%s+(%S+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%S+)%s+(%S+)%s*(.*)"

function Interface:OnBroadcast(message)
    self:CallListeners("OnBroadcast", message)
end
Interface.commands["BROADCAST"] = Interface.OnBroadcast
Interface.commandPattern["BROADCAST"] = "(.+)"

function Interface:OnChannel(chanName, userCount, topic)
    userCount = tonumber(userCount)
    self:CallListeners("OnChannel", chanName, userCount, topic)
end
Interface.commands["CHANNEL"] = Interface.OnChannel
Interface.commandPattern["CHANNEL"] = "(%S+)%s+(%d+)%s*(.*)"

function Interface:OnChannelMessage(chanName, message)
    self:CallListeners("OnChannelMessage", chanName, message)
end
Interface.commands["CHANNELMESSAGE"] = Interface.OnChannelMessage
Interface.commandPattern["CHANNELMESSAGE"] = "(%S+)%s+(%S+)"

function Interface:OnChannelTopic(chanName, author, changedTime, topic)
    self:CallListeners("OnChannelTopic", chanName, author, changedTime, topic)
end
Interface.commands["CHANNELTOPIC"] = Interface.OnChannelTopic
Interface.commandPattern["CHANNELTOPIC"] = "(%S+)%s+(%S+)%s+(%S+)%s+([^\t]+)"

function Interface:OnClientBattleStatus(userName, battleStatus, teamColor)
    self:CallListeners("OnClientBattleStatus", userName, battleStatus, teamColor)
end
Interface.commands["CLIENTBATTLESTATUS"] = Interface.OnClientBattleStatus
Interface.commandPattern["CLIENTBATTLESTATUS"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:OnClientIpPort(userName, ip, port)
    self:CallListeners("OnClientIpPort", userName, ip, port)
end
Interface.commands["CLIENTIPPORT"] = Interface.OnClientIpPort
Interface.commandPattern["CLIENTIPPORT"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:OnClients(chanName, clientsStr)
    local clients = explode(clientsStr, " ")
    self:CallListeners("OnClients", chanName, clients)
end
Interface.commands["CLIENTS"] = Interface.OnClients
Interface.commandPattern["CLIENTS"] = "(%S+)%s+(.+)"

function Interface:OnClientStatus(userName, status)
    self:CallListeners("OnClientStatus", userName, status)
end
Interface.commands["CLIENTSTATUS"] = Interface.OnClientStatus
Interface.commandPattern["CLIENTSTATUS"] = "(%S+)%s+(%S+)"

function Interface:OnCompFlags(compFlags)
    compFlags = explode(compflags, "\t")
    self:CallListeners("OnCompFlags", compFlags)
end
Interface.commands["COMPFLAGS"] = Interface.OnCompFlags
Interface.commandPattern["COMPFLAGS"] = "(%S+)%s+(%S+)"

function Interface:OnConnectUser(ip, port, scriptPassword)
    self:CallListeners("OnConnectUser", ip, port, scriptPassword)
end
Interface.commands["CONNECTUSER"] = Interface.OnConnectUser
Interface.commandPattern["CONNECTUSER"] = "([^:%s]+):([^:%s])%s*(%S*)"

function Interface:OnConnectUserFailed(userName, reason)
    self:CallListeners("OnConnectUserFailed", userName, reason)
end
Interface.commands["CONNECTUSERFAILED"] = Interface.OnConnectUserFailed
Interface.commandPattern["CONNECTUSERFAILED"] = "(%S+)%s+([^\t]*)"

function Interface:OnDenied(reason)
    self:CallListeners("OnDenied", reason)
end
Interface.commands["DENIED"] = Interface.OnDenied
Interface.commandPattern["DENIED"] = "(.+)"

function Interface:OnDisableUnits(unitNames)
    unitNames = explode(unitNames, " ")
    self:CallListeners("OnDisableUnits", unitNames)
end
Interface.commands["DISABLEUNITS"] = Interface.OnDisableUnits
Interface.commandPattern["DISABLEUNITS"] = "(.+)"

function Interface:OnEnableAllUnits()
    self:CallListeners("OnEnableAllUnits")
end
Interface.commands["ENABLEALLUNITS"] = Interface.OnEnableAllUnits

function Interface:OnEnableUnits(unitNames)
    unitNames = explode(unitNames, " ")
    self:CallListeners("OnEnableUnits", unitNames)
end
Interface.commands["ENABLEUNITS"] = Interface.OnEnableUnits
Interface.commandPattern["ENABLEUNITS"] = "(.+)"

function Interface:OnEndOfChannels()
    self:CallListeners("OnEndOfChannels")
    self.awaitingChannelsList = false
end
Interface.commands["ENDOFCHANNELS"] = Interface.OnEndOfChannels

function Interface:OnForceJoinBattle(destinationBattleID, destinationBattlePassword)
    destinationBattleID = tonumber(destinationBattleID)
    self:CallListeners("OnForceJoinBattle", destinationBattleID, destinationBattlePassword)
end
Interface.commands["FORCEJOINBATTLE"] = Interface.OnForceJoinBattle
Interface.commandPattern["FORCEJOINBATTLE"] = "(%d+)%s*(%S*)"

function Interface:OnForceJoinBattleFailed(userName, reason)
    self:CallListeners("OnForceJoinBattleFailed", userName, reason)
end
Interface.commands["FORCEJOINBATTLEFAILED"] = Interface.OnForceJoinBattleFailed
Interface.commandPattern["FORCEJOINBATTLEFAILED"] = "(%S+)%s*(%[^\t]*)"

function Interface:OnForceLeaveChannel(chanName, userName, reason)
    self:CallListeners("OnForceLeaveChannel", chanName, userName, reason)
end
Interface.commands["FORCELEAVECHANNEL"] = Interface.OnForceLeaveChannel
Interface.commandPattern["FORCELEAVECHANNEL"] = "(%S+)%s+(%S+)%s*(%[^\t]*)"

function Interface:OnForceQuitBattle()
    self:CallListeners("OnForceQuitBattle")
end
Interface.commands["FORCEQUITBATTLE"] = Interface.OnForceQuitBattle

function Interface:OnHostPort(port)
    port = tonumber(port)
    self:CallListeners("OnHostPort", port)
end
Interface.commands["HOSTPORT"] = Interface.OnHostPort
Interface.commandPattern["HOSTPORT"] = "(%d+)"

function Interface:OnJoin(chanName)
    self:CallListeners("OnJoin", chanName)
end
Interface.commands["JOIN"] = Interface.OnJoin
Interface.commandPattern["JOIN"] = "(%S+)"

-- hashCode will be a string due to lua limitations
function Interface:OnJoinBattle(battleID, hashCode)
    battleID = tonumber(battleID)
    self:CallListeners("OnJoinBattle", battleID, hashCode)
end
Interface.commands["JOINBATTLE"] = Interface.OnJoinBattle
Interface.commandPattern["JOINBATTLE"] = "(%d+)%s+(%S+)"

function Interface:OnJoinBattleFailed(reason)
    self:CallListeners("OnJoinBattleFailed", reason)
end
Interface.commands["JOINBATTLEFAILED"] = Interface.OnJoinBattleFailed
Interface.commandPattern["JOINBATTLEFAILED"] = "(%[^\t]+)"

function Interface:OnJoinBattleRequest(userName, ip)
    self:CallListeners("OnJoinBattleRequest", userName, ip)
end
Interface.commands["JOINBATTLEREQUEST"] = Interface.OnJoinBattleRequest
Interface.commandPattern["JOINBATTLEREQUEST"] = "(%S+)%s+(%S+)"

function Interface:OnJoined(chanName, userName)
    self:CallListeners("OnJoined", chanName, userName)
end
Interface.commands["JOINED"] = Interface.OnJoined
Interface.commandPattern["JOINED"] = "(%S+)%s+(%S+)"

function Interface:OnJoinedBattle(battleID, userName, scriptPassword)
    battleID = tonumber(battleID)
    self:CallListeners("OnJoinedBattle", battleID, userName, scriptPassword)
end
Interface.commands["JOINEDBATTLE"] = Interface.OnJoinedBattle
Interface.commandPattern["JOINEDBATTLE"] = "(%d+)%s+(%S+)%s*(%S*)"

function Interface:OnJoinFailed(chanName, reason)
    self:CallListeners("OnJoinFailed", chanName, reason)
end
Interface.commands["JOINFAILED"] = Interface.OnJoinFailed
Interface.commandPattern["JOINFAILED"] = "(%S+)%s+([^\t]+)"

function Interface:OnLeft(chanName, userName, reason)
    self:CallListeners("OnLeft", chanName, userName, reason)
end
Interface.commands["LEFT"] = Interface.OnLeft
Interface.commandPattern["LEFT"] = "(%S+)%s+(%S+)%s*([^\t]*)"

function Interface:OnLeftBattle(battleID, userName)
    battleID = tonumber(battleID)
    self:CallListeners("OnLeftBattle", battleID, userName)
end
Interface.commands["LEFTBATTLE"] = Interface.OnLeftBattle
Interface.commandPattern["LEFTBATTLE"] = "(%d+)%s+(%S+)"

function Interface:OnLoginInfoEnd()
    self:CallListeners("OnLoginInfoEnd")
end
Interface.commands["LOGININFOEND"] = Interface.OnLoginInfoEnd

function Interface:OnMOTD(message)
    self:CallListeners("OnMOTD", message)
end
Interface.commands["MOTD"] = Interface.OnMOTD
Interface.commandPattern["MOTD"] = "([^\t]*)"

function Interface:OnMuteList(muteDescription)
    self:CallListeners("OnMuteList", muteDescription)
end
Interface.commands["MUTELIST"] = Interface.OnMuteList
Interface.commandPattern["MUTELIST"] = "([^\t]*)"

function Interface:OnMuteListBegin(chanName)
    self:CallListeners("OnMuteListBegin", chanName)
end
Interface.commands["MUTELISTBEGIN"] = Interface.OnMuteListBegin
Interface.commandPattern["MUTELISTBEGIN"] = "(%S+)"

function Interface:OnMuteListEnd()
    self:CallListeners("OnMuteListEnd")
end
Interface.commands["MUTELISTEND"] = Interface.OnMuteListEnd

function Interface:OnNoChannelTopic(chanName)
    self:CallListeners("OnNoChannelTopic", chanName)
end
Interface.commands["NOCHANNELTOPIC"] = Interface.OnNoChannelTopic
Interface.commandPattern["NOCHANNELTOPIC"] = "(%S+)"

function Interface:OnOpenBattle(battleID)
    battleID = tonumber(battleID)
    self:CallListeners("OnOpenBattle", battleID)
end
Interface.commands["OPENBATTLE"] = Interface.OnOpenBattle
Interface.commandPattern["OPENBATTLE"] = "(%d+)"

function Interface:OnOpenBattleFailed(reason)
    self:CallListeners("OnOpenBattleReason", reason)
end
Interface.commands["OPENBATTLEFAILED"] = Interface.OnOpenBattleFailed
Interface.commandPattern["OPENBATTLEFAILED"] = "([^\t]+)"

function Interface:OnPong()
    self:CallListeners("OnPong")
end
Interface.commands["PONG"] = Interface.OnPong

function Interface:OnRedirect(ip)
    self:CallListeners("OnRedirect", ip)
end
Interface.commands["REDIRECT"] = Interface.OnRedirect
Interface.commandPattern["REDIRECT"] = "(%S+)"

function Interface:OnRegistrationAccepted()
    self:CallListeners("OnRegistrationAccepted")
end
Interface.commands["REGISTRATIONACCEPTED"] = Interface.OnRegistrationAccepted

function Interface:OnRegistrationDenied(reason)
    self:CallListeners("OnRegistrationDenied", reason)
end
Interface.commands["REGISTRATIONDENIED"] = Interface.OnRegistrationDenied
Interface.commandPattern["REGISTRATIONDENIED"] = "([^\t]+)"

function Interface:OnRemoveBot(battleID, name)
    battleID = tonumber(battleID)
    self:CallListeners("OnRemoveBot", battleID, name)
end
Interface.commands["REMOVEBOT"] = Interface.OnRemoveBot
Interface.commandPattern["REMOVEBOT"] = "(%d+)%s+(%S+)"

function Interface:OnRemoveScriptTags(keys)
    keys = explode(keys, " ")
    self:CallListeners("OnRemoveScriptTags", keys)
end
Interface.commands["REMOVESCRIPTTAGS"] = Interface.OnRemoveScriptTags
Interface.commandPattern["REMOVESCRIPTTAGS"] = "([^\t]+)"

function Interface:OnRemoveStartRect(allyNo)
    allyNo = tonumber(allyNo)
    self:CallListeners("OnRemoveStartRect", allyNo)
end
Interface.commands["REMOVESTARTRECT"] = Interface.OnRemoveStartRect
Interface.commandPattern["REMOVESTARTRECT"] = "(%d+)"

function Interface:OnRemoveUser(userName)
    self:CallListeners("OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Interface.OnRemoveUser
Interface.commandPattern["REMOVEUSER"] = "(%S+)"

function Interface:OnRequestBattleStatus()
    self:CallListeners("OnRequestBattleStatus")
end
Interface.commands["REQUESTBATTLESTATUS"] = Interface.OnRequestBattleStatus

function Interface:OnRing(userName)
    self:CallListeners("OnRing", userName)
end
Interface.commands["RING"] = Interface.OnRing
Interface.commandPattern["RING"] = "(%S+)"

function Interface:OnSaid(chanName, userName, message)
    self:CallListeners("OnSaid", chanName, userName, message)
end
Interface.commands["SAID"] = Interface.OnSaid
Interface.commandPattern["SAID"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:OnSaidBattle(userName, message)
    self:CallListeners("OnSaidBattle", userName, message)
end
Interface.commands["SAIDBATTLE"] = Interface.OnSaidBattle
Interface.commandPattern["SAIDBATTLE"] = "(%S+)%s+(.*)"

function Interface:OnSaidBattleEx(userName, message)
    self:CallListeners("OnSaidBattleEx", userName, message)
end
Interface.commands["SAIDBATTLEEX"] = Interface.OnSaidBattleEx
Interface.commandPattern["SAIDBATTLEEX"] = "(%S+)%s+(.*)"

function Interface:OnSaidData(chanName, userName, message)
    self:CallListeners("OnSaidData", chanName, userName, message)
end
Interface.commands["SAIDDATA"] = Interface.OnSaidData
Interface.commandPattern["SAIDDATA"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:OnSaidDataBattle(userName, message)
    self:CallListeners("OnSaidDataBattle", userName, message)
end
Interface.commands["SAIDDATABATTLE"] = Interface.OnSaidDataBattle
Interface.commandPattern["SAIDDATABATTLE"] = "(%S+)%s+(.*)"

function Interface:OnSaidDataPrivate(userName, message)
    self:CallListeners("OnSaidDataPrivate", userName, message)
end
Interface.commands["SAIDDATAPRIVATE"] = Interface.OnSaidDataPrivate
Interface.commandPattern["SAIDDATAPRIVATE"] = "(%S+)%s+(.*)"

function Interface:OnSaidEx(chanName, userName, message)
    self:CallListeners("OnSaidEx", chanName, userName, message)
end
Interface.commands["SAIDEX"] = Interface.OnSaidEx
Interface.commandPattern["SAIDEX"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:OnSaidPrivate(userName, message)
    self:CallListeners("OnSaidPrivate", userName, message)
end
Interface.commands["SAIDPRIVATE"] = Interface.OnSaidPrivate
Interface.commandPattern["SAIDPRIVATE"] = "(%S+)%s+(.*)"

function Interface:OnSayPrivate(userName, message)
    self:CallListeners("OnSayPrivate", userName, message)
end
Interface.commands["SAYPRIVATE"] = Interface.OnSayPrivate
Interface.commandPattern["SAYPRIVATE"] = "(%S+)%s+(.*)"

function Interface:OnScript(line)
    self:CallListeners("OnScript", line)
end
Interface.commands["SCRIPT"] = Interface.OnScript
Interface.commandPattern["SCRIPT"] = "([^\t]+)"

function Interface:OnScriptEnd()
    self:CallListeners("OnScriptEnd")
end
Interface.commands["SCRIPTEND"] = Interface.OnScriptEnd

function Interface:OnScriptStart()
    self:CallListeners("OnScriptStart")
end
Interface.commands["SCRIPTSTART"] = Interface.OnScriptStart

function Interface:OnServerMSG(message)
    self:CallListeners("OnServerMSG", message)
end
Interface.commands["SERVERMSG"] = Interface.OnServerMSG
Interface.commandPattern["SERVERMSG"] = "([^\t]+)"

function Interface:OnServerMSGBox(message, url)
    self:CallListeners("OnServerMSG", message, url)
end
Interface.commands["SERVERMSGBOX"] = Interface.OnServerMSGBox
Interface.commandPattern["SERVERMSGBOX"] = "([^\t]+)\t+([^\t]+)"

function Interface:OnSetScriptTags(pairs)
    pairs = explode(pairs, " ")
    self:CallListeners("OnSetScriptTags", pairs)
end
Interface.commands["SETSCRIPTTAGS"] = Interface.OnSetScriptTags
Interface.commandPattern["SETSCRIPTTAGS"] = "([^\t]+)"

function Interface:OnTASServer(protocolVersion, springVersion, udpPort, serverMode)
    self:CallListeners("OnTASServer", protocolVersion, springVersion, udpPort, serverMode)
end
Interface.commands["TASSERVER"] = Interface.OnTASServer
Interface.commandPattern["TASSERVER"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:OnTestLoginAccept(message)
    self:CallListeners("OnTestLoginAccept", message)
end
Interface.commands["TESTLOGINACCEPT"] = Interface.OnTestLoginAccept

function Interface:OnTestLoginDeny(message)
    self:CallListeners("OnTestLoginDeny", message)
end
Interface.commands["TESTLOGINDENY"] = Interface.OnTestLoginDeny

function Interface:OnUDPSourcePort(port)
    port = tonumber(port)
    self:CallListeners("OnUDPSourcePort", port)
end
Interface.commands["UDPSOURCEPORT"] = Interface.OnUDPSourcePort
Interface.commandPattern["UDPSOURCEPORT"] = "(%d+)"

function Interface:OnUpdateBattleInfo(battleID, spectatorCount, locked, mapHash, mapName)
    battleID = tonumber(battleID)
    self:CallListeners("OnUpdateBattleInfo", battleID, spectatorCount, locked, mapHash, mapName)
end
Interface.commands["UPDATEBATTLEINFO"] = Interface.OnUpdateBattleInfo
Interface.commandPattern["UPDATEBATTLEINFO"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+([^\t]+)"

function Interface:OnUpdateBot(battleID, name, battleStatus, teamColor)
    battleID = tonumber(battleID)
    self:CallListeners("OnUpdateBot", battleID, name, battleStatus, teamColor)
end
Interface.commands["UPDATEBOT"] = Interface.OnUpdateBot
Interface.commandPattern["UPDATEBOT"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:Say(chanName, message)
    self:_SendCommand(concat("SAY", chanName, message), true)
end

function Interface:ConfirmAgreement()
    self:_SendCommand("CONFIRMAGREEMENT")
end

function Interface:Channels()
    self:_SendCommand("CHANNELS")
    self.awaitingChannelsList = true
end

-- has a listener, but isn't a real command
function Interface:OnConnect()
    self:CallListeners("OnConnect")
end

function Interface:CommandReceived(command)
    -- if it's the first message received, then it's probably the server greeting
    if self.messagesReceivedCount == 1 then
        self:CallListeners("OnConnect")
        return
    end

    local args = explode(" ", command)
    if string.starts(args[1], "#") then
        table.remove(args, 1)
    end

    local arguments = table.concat(args, " ", 2)
    
    local commandFunction = Interface.commands[args[1]]
    if commandFunction ~= nil then
        local pattern = Interface.commandPattern[args[1]]
        if pattern then
            local funArgs = {arguments:match(pattern)}
            if #funArgs ~= 0 then
                commandFunction(self, unpack(funArgs))
            else
                Spring.Echo("Failed to match command: ", args[1], ", args: " .. arguments .. " with pattern: ", pattern)
            end
        else
            --Spring.Echo("No pattern for command: " .. args[1])
            commandFunction(self)
        end
    else
        Spring.Echo("No such function: " .. args[1] .. ", for command: " .. command)
    end
    self:CallListeners("OnCommandReceived", command)
end

function Interface:_SocketUpdate()
    if self.client == nil then
        return
    end
	-- get sockets ready for read
	local readable, writeable, err = socket.select({self.client}, {self.client}, 0)
	if err~=nil then
		-- some error happened in select
		if err=="timeout" then
			-- nothing to do, return
			return
		end
		Spring.Echo("Error in select: " .. error)
	end
	for _, input in ipairs(readable) do
		local s, status, commandsStr = input:receive('*a') --try to read all data
        print(commandsStr)
		if status == "timeout" or status == nil then
            local commands = explode("\n", commandsStr)
            for i = 1, #commands-1 do
                local command = commands[i]
                if command ~= nil then
                    self.messagesReceivedCount = self.messagesReceivedCount + 1
                    self:CommandReceived(command)
                end
            end
		elseif status == "closed" then
            Spring.Echo("closed connection")
			input:close()
            self.connected = false
		end
	end
end

function Interface:Update()
    self:_SocketUpdate()
    -- prevent timeout with PING
    if self.connected then
        local nowSeconds = Spring.GetGameSeconds()
        if nowSeconds - self.lastSentSeconds > 30 then
            self:Ping()
        end
    end
end

return Interface
