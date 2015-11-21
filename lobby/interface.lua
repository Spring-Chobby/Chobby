VFS.Include(LIB_LOBBY_DIRNAME .. "json.lua")

local LOG_SECTION = "liblobby"

if not Spring.GetConfigInt("LuaSocketEnabled", 0) == 1 then
    Spring.Log(LOG_SECTION, LOG.ERROR, "LuaSocketEnabled is disabled")
    return false
end

local function dumpConfig()
    -- dump all luasocket related config settings to console
    for _, conf in ipairs({"TCPAllowConnect", "TCPAllowListen", "UDPAllowConnect", "UDPAllowListen"  }) do
        Spring.Log(LOG_SECTION, LOG.INFO, conf .. " = " .. Spring.GetConfigString(conf, ""))
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
    local args = {...}
    local argsClean = {}
    for k, v in pairs(args) do
        if v == nil then
            break
        end
        table.insert(argsClean, v)
    end
    return table.concat(argsClean, " ")
end

local function parseTags(tags)
    local tags = explode("\t", tags)
    local tagsMap = {}
    for _, tag in pairs(tags) do
        local indx = string.find(tag, "=")
        local key = string.sub(tag, 1, indx-1)
        local value = string.sub(tag, indx+1)
        tagsMap[key] = value
    end
    return tagsMap
end

local function getTag(tags, tagName, mandatory)
    local value = tags[tagName]
    if mandatory and value == nil then
        error("Missing mandatory parameter: " .. tostring(tagName))
    end
    return value
end

Interface = Observable:extends{}

-- map lobby commands by name
Interface.commands = {}
-- map json lobby commands by name
Interface.jsonCommands = {}
-- define command format with pattern (regex)
Interface.commandPattern = {}

function Interface:init()
-- dumpConfig()
    self.messagesSentCount = 0
    self.lastSentSeconds = Spring.GetGameSeconds()
	self.status = "offline"
    self.listeners = {}

    -- private
    self.buffer = ""
end

function Interface:Connect(host, port)
    self.client = socket.tcp()
    self.client:settimeout(0)
    local res, err = self.client:connect(host, port)
    -- FIXME: this error check makes no sense!
    if res == nil and not res == "timeout" then
        Spring.Log(LOG_SECTION, LOG.ERROR, "Error in connect: " .. err)
        return false
    end
    self.status = "connected"
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
    self:_CallListeners("OnCommandSent", command:sub(1, #command-1))
    self.lastSentSeconds = Spring.GetGameSeconds()
end

function Interface:SendCustomCommand(command)
    self:_SendCommand(command, false)
end

function Interface:AddBot(name, battleStatus, teamColor, aiDll)
    self:_SendCommand(concat("ADDBOT", name, battleStatus, teamColor, aiDll))
    return self
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

function Interface:ConfirmAgreement()
    self:_SendCommand("CONFIRMAGREEMENT")
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

function Interface:FriendList()
    self:_SendCommand("FRIENDLIST", true)
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

function Interface:Join(chanName, key)
    self:_SendCommand(concat("JOIN", chanName, key))
    return self
end

function Interface:JoinBattle(battleID, password, scriptPassword)
    self:_SendCommand(concat("JOINBATTLE", battleID, password, scriptPassword))
    return self
end

function Interface:JoinBattleAccept(userName)
    self:_SendCommand(concat("JOINBATTLEACCEPT", userName))
    return self
end

function Interface:JoinBattleDeny(userName, reason)
    self:_SendCommand(concat("JOINBATTLEDENY", userName, reason))
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

function Interface:Leave(chanName)
    self:_SendCommand(concat("LEAVE", chanName))
    return self
end

function Interface:LeaveBattle()
    self:_SendCommand("LEAVEBATTLE")
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

function Interface:Login(user, password, cpu, localIP)
    if localIP == nil then
        localIP = "*"
    end
    -- calculate MD5 hash
    password = VFS.CalculateHash(password, 0)
    self:_SendCommand(concat("LOGIN", user, password, cpu, localIP, "LuaLobby\t", "0\t", "a b m cl et p"))
    return self
end

function Interface:MuteList(chanName)
    self:_SendCommand(concat("MUTELIST", chanName))
    return self
end

function Interface:MyBattleStatus(ready, team, allyTeam, mode, handicap, sync, side, myTeamColor)
    local battleStatus = tostring((ready and 2 or 0) + (mode and 2^10 or 0) + (sync and 2^22 or 2^23))
    myTeamColor = myTeamColor or math.floor(math.random() * 255 * 2^16 + math.random() * 255 * 2^8 + math.random() * 255)
    self:_SendCommand(concat("MYBATTLESTATUS", battleStatus, myTeamColor))
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

function Interface:Ping()
    self:_SendCommand("PING", true)
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

function Interface:Register(userName, password, email)
    -- FIXME: email argument is currently not sent to the server
    self:_SendCommand(concat("REGISTER", userName, password))
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

function Interface:Say(chanName, message)
    self:_SendCommand(concat("SAY", chanName, message))
    return self
end

function Interface:SayBattle(message)
    self:_SendCommand(concat("SAYBATTLE", message))
    return self
end

function Interface:SayBattleEx(message)
    self:_SendCommand(concat("SAYBATTLEEX", message))
    return self
end

function Interface:SayData(chanName, message)
    self:_SendCommand(concat("SAYDATA", chanName, message))
    return self
end

function Interface:SayDataBattle(message)
    self:_SendCommand(concat("SAYDATABATTLE", message))
    return self
end

function Interface:SayDataPrivate(userName, message)
    self:_SendCommand(concat("SAYDATAPRIVATE", userName, message))
    return self
end

function Interface:SayEx(chanName, message)
    self:_SendCommand(concat("SAYEX", chanName, message))
    return self
end

function Interface:SayPrivate(userName, message)
    self:_SendCommand(concat("SAYPRIVATE", userName, message))
    return self
end

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

function Interface:_OnAccepted(username)
    self:_CallListeners("OnAccepted", username)
end
Interface.commands["ACCEPTED"] = Interface._OnAccepted
Interface.commandPattern["ACCEPTED"] = "(%S+)"

--TODO: should also send a respond with USERID
function Interface:_OnAcquireUserID()
    self:_CallListeners("OnAcquireUserID", username)
end
Interface.commands["ACQUIREUSERID"] = Interface._OnAcquireUserID

function Interface:_OnAddBot(battleID, name, battleStatus, teamColor, aiDll)
    battleID = tonumber(battleID)
    local ai, dll = unpack(explode("\t", aiDll))
    self:_CallListeners("OnAddBot", battleID, name, battleStatus, teamColor, ai, dll)
end
Interface.commands["ADDBOT"] = Interface._OnAddBot
Interface.commandPattern["ADDBOT"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnAddStartRect(allyNo, left, top, right, bottom)
    self:_CallListeners("OnAddStartRect", allyNo, left, top, right, bottom)
end
Interface.commands["ADDSTARTRECT"] = Interface._OnAddStartRect
Interface.commandPattern["ADDSTARTRECT"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)
    self:_CallListeners("OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Interface._OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)%s*(.*)"

function Interface:_OnAgreement(line)
    self:_CallListeners("OnAgreement", line)
end
Interface.commands["AGREEMENT"] = Interface._OnAgreement
Interface.commandPattern["AGREEMENT"] = "(.*)"

function Interface:_OnAgreementEnd()
    self:_CallListeners("OnAgreementEnd")
end
Interface.commands["AGREEMENTEND"] = Interface._OnAgreementEnd

function Interface:_OnBattleClosed(battleID)
    battleID = tonumber(battleID)
    self:_CallListeners("OnBattleClosed", battleID)
end
Interface.commands["BATTLECLOSED"] = Interface._OnBattleClosed
Interface.commandPattern["BATTLECLOSED"] = "(%d+)"

-- mapHash (32bit) will remain a string, since spring lua uses floats (24bit mantissa)
function Interface:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
    battleID = tonumber(battleID)
    type = tonumber(type)
    natType = tonumber(natType)
    port = tonumber(port)
    maxPlayers = tonumber(maxPlayers)
    passworded = tonumber(passworded) ~= 0

    local engineName, engineVersion, map, title, gameName = unpack(explode("\t", other))

    self:_CallListeners("OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, engineName, engineVersion, map, title, gameName)
end
Interface.commands["BATTLEOPENED"] = Interface._OnBattleOpened
Interface.commandPattern["BATTLEOPENED"] = "(%d+)%s+(%d)%s+(%d)%s+(%S+)%s+(%S+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%S+)%s+(%S+)%s*(.*)"

function Interface:_OnBroadcast(message)
    self:_CallListeners("OnBroadcast", message)
end
Interface.commands["BROADCAST"] = Interface._OnBroadcast
Interface.commandPattern["BROADCAST"] = "(.+)"

function Interface:_OnChannel(chanName, userCount, topic)
    userCount = tonumber(userCount)
    self:_CallListeners("OnChannel", chanName, userCount, topic)
end
Interface.commands["CHANNEL"] = Interface._OnChannel
Interface.commandPattern["CHANNEL"] = "(%S+)%s+(%d+)%s*(.*)"

function Interface:_OnChannelMessage(chanName, message)
    self:_CallListeners("OnChannelMessage", chanName, message)
end
Interface.commands["CHANNELMESSAGE"] = Interface._OnChannelMessage
Interface.commandPattern["CHANNELMESSAGE"] = "(%S+)%s+(%S+)"

function Interface:_OnChannelTopic(chanName, author, changedTime, topic)
    self:_CallListeners("OnChannelTopic", chanName, author, changedTime, topic)
end
Interface.commands["CHANNELTOPIC"] = Interface._OnChannelTopic
Interface.commandPattern["CHANNELTOPIC"] = "(%S+)%s+(%S+)%s+(%S+)%s+([^\t]+)"

function Interface:_OnClientBattleStatus(userName, battleStatus, teamColor)
    self:_CallListeners("OnClientBattleStatus", userName, battleStatus, teamColor)
end
Interface.commands["CLIENTBATTLESTATUS"] = Interface._OnClientBattleStatus
Interface.commandPattern["CLIENTBATTLESTATUS"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnClientIpPort(userName, ip, port)
    self:_CallListeners("OnClientIpPort", userName, ip, port)
end
Interface.commands["CLIENTIPPORT"] = Interface._OnClientIpPort
Interface.commandPattern["CLIENTIPPORT"] = "(%S+)%s+(%S+)%s+(%S+)"

function Interface:_OnClients(chanName, clientsStr)
    local clients = explode(" ", clientsStr)
    self:_CallListeners("OnClients", chanName, clients)
end
Interface.commands["CLIENTS"] = Interface._OnClients
Interface.commandPattern["CLIENTS"] = "(%S+)%s+(.+)"

function Interface:_OnClientStatus(userName, status)
    self:_CallListeners("OnClientStatus", userName, status)
end
Interface.commands["CLIENTSTATUS"] = Interface._OnClientStatus
Interface.commandPattern["CLIENTSTATUS"] = "(%S+)%s+(%S+)"

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

function Interface:_OnDenied(reason)
    self:_CallListeners("OnDenied", reason)
end
Interface.commands["DENIED"] = Interface._OnDenied
Interface.commandPattern["DENIED"] = "(.+)"

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

function Interface:_OnEndOfChannels()
    self:_CallListeners("OnEndOfChannels")
end
Interface.commands["ENDOFCHANNELS"] = Interface._OnEndOfChannels

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

function Interface:_OnJoin(chanName)
    self:_CallListeners("OnJoin", chanName)
end
Interface.commands["JOIN"] = Interface._OnJoin
Interface.commandPattern["JOIN"] = "(%S+)"

-- hashCode will be a string due to lua limitations
function Interface:_OnJoinBattle(battleID, hashCode)
    battleID = tonumber(battleID)
    self:_CallListeners("OnJoinBattle", battleID, hashCode)
end
Interface.commands["JOINBATTLE"] = Interface._OnJoinBattle
Interface.commandPattern["JOINBATTLE"] = "(%d+)%s+(%S+)"

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

function Interface:_OnJoined(chanName, userName)
    self:_CallListeners("OnJoined", chanName, userName)
end
Interface.commands["JOINED"] = Interface._OnJoined
Interface.commandPattern["JOINED"] = "(%S+)%s+(%S+)"

function Interface:_OnJoinedBattle(battleID, userName, scriptPassword)
    battleID = tonumber(battleID)
    self:_CallListeners("OnJoinedBattle", battleID, userName, scriptPassword)
end
Interface.commands["JOINEDBATTLE"] = Interface._OnJoinedBattle
Interface.commandPattern["JOINEDBATTLE"] = "(%d+)%s+(%S+)%s*(%S*)"

function Interface:_OnJoinFailed(chanName, reason)
    self:_CallListeners("OnJoinFailed", chanName, reason)
end
Interface.commands["JOINFAILED"] = Interface._OnJoinFailed
Interface.commandPattern["JOINFAILED"] = "(%S+)%s+([^\t]+)"

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

function Interface:_OnLeft(chanName, userName, reason)
    self:_CallListeners("OnLeft", chanName, userName, reason)
end
Interface.commands["LEFT"] = Interface._OnLeft
Interface.commandPattern["LEFT"] = "(%S+)%s+(%S+)%s*([^\t]*)"

function Interface:_OnLeftBattle(battleID, userName)
    battleID = tonumber(battleID)
    self:_CallListeners("OnLeftBattle", battleID, userName)
end
Interface.commands["LEFTBATTLE"] = Interface._OnLeftBattle
Interface.commandPattern["LEFTBATTLE"] = "(%d+)%s+(%S+)"

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

function Interface:_OnLoginInfoEnd()
    self:_CallListeners("OnLoginInfoEnd")
end
Interface.commands["LOGININFOEND"] = Interface._OnLoginInfoEnd

function Interface:_OnMOTD(message)
    self:_CallListeners("OnMOTD", message)
end
Interface.commands["MOTD"] = Interface._OnMOTD
Interface.commandPattern["MOTD"] = "([^\t]*)"

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

function Interface:_OnNoChannelTopic(chanName)
    self:_CallListeners("OnNoChannelTopic", chanName)
end
Interface.commands["NOCHANNELTOPIC"] = Interface._OnNoChannelTopic
Interface.commandPattern["NOCHANNELTOPIC"] = "(%S+)"

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

function Interface:_OnPong()
    self:_CallListeners("OnPong")
end
Interface.commands["PONG"] = Interface._OnPong

function Interface:_OnQueueOpened(obj)
    self:_CallListeners("OnQueueOpened", obj)
end
Interface.jsonCommands["QUEUEOPENED"] = Interface._OnQueueOpened

function Interface:_OnQueueClosed(obj)
    self:_CallListeners("OnQueueClosed", obj.name)
end
Interface.jsonCommands["QUEUECLOSED"] = Interface._OnQueueClosed

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

function Interface:_OnRegistrationAccepted()
    self:_CallListeners("OnRegistrationAccepted")
end
Interface.commands["REGISTRATIONACCEPTED"] = Interface._OnRegistrationAccepted

function Interface:_OnRegistrationDenied(reason)
    self:_CallListeners("OnRegistrationDenied", reason)
end
Interface.commands["REGISTRATIONDENIED"] = Interface._OnRegistrationDenied
Interface.commandPattern["REGISTRATIONDENIED"] = "([^\t]+)"

function Interface:_OnRemoveBot(battleID, name)
    battleID = tonumber(battleID)
    self:_CallListeners("OnRemoveBot", battleID, name)
end
Interface.commands["REMOVEBOT"] = Interface._OnRemoveBot
Interface.commandPattern["REMOVEBOT"] = "(%d+)%s+(%S+)"

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

function Interface:_OnRemoveUser(userName)
    self:_CallListeners("OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Interface._OnRemoveUser
Interface.commandPattern["REMOVEUSER"] = "(%S+)"

function Interface:_OnRequestBattleStatus()
    self:_CallListeners("OnRequestBattleStatus")
end
Interface.commands["REQUESTBATTLESTATUS"] = Interface._OnRequestBattleStatus

function Interface:_OnRing(userName)
    self:_CallListeners("OnRing", userName)
end
Interface.commands["RING"] = Interface._OnRing
Interface.commandPattern["RING"] = "(%S+)"

function Interface:_OnSaid(chanName, userName, message)
    self:_CallListeners("OnSaid", chanName, userName, message)
end
Interface.commands["SAID"] = Interface._OnSaid
Interface.commandPattern["SAID"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnSaidBattle(userName, message)
    self:_CallListeners("OnSaidBattle", userName, message)
end
Interface.commands["SAIDBATTLE"] = Interface._OnSaidBattle
Interface.commandPattern["SAIDBATTLE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidBattleEx(userName, message)
    self:_CallListeners("OnSaidBattleEx", userName, message)
end
Interface.commands["SAIDBATTLEEX"] = Interface._OnSaidBattleEx
Interface.commandPattern["SAIDBATTLEEX"] = "(%S+)%s+(.*)"

function Interface:_OnSaidData(chanName, userName, message)
    self:_CallListeners("OnSaidData", chanName, userName, message)
end
Interface.commands["SAIDDATA"] = Interface._OnSaidData
Interface.commandPattern["SAIDDATA"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnSaidDataBattle(userName, message)
    self:_CallListeners("OnSaidDataBattle", userName, message)
end
Interface.commands["SAIDDATABATTLE"] = Interface._OnSaidDataBattle
Interface.commandPattern["SAIDDATABATTLE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidDataPrivate(userName, message)
    self:_CallListeners("OnSaidDataPrivate", userName, message)
end
Interface.commands["SAIDDATAPRIVATE"] = Interface._OnSaidDataPrivate
Interface.commandPattern["SAIDDATAPRIVATE"] = "(%S+)%s+(.*)"

function Interface:_OnSaidEx(chanName, userName, message)
    self:_CallListeners("OnSaidEx", chanName, userName, message)
end
Interface.commands["SAIDEX"] = Interface._OnSaidEx
Interface.commandPattern["SAIDEX"] = "(%S+)%s+(%S+)%s+(.*)"

function Interface:_OnSaidPrivate(userName, message)
    self:_CallListeners("OnSaidPrivate", userName, message)
end
Interface.commands["SAIDPRIVATE"] = Interface._OnSaidPrivate
Interface.commandPattern["SAIDPRIVATE"] = "(%S+)%s+(.*)"

function Interface:_OnSayPrivate(userName, message)
    self:_CallListeners("OnSayPrivate", userName, message)
end
Interface.commands["SAYPRIVATE"] = Interface._OnSayPrivate
Interface.commandPattern["SAYPRIVATE"] = "(%S+)%s+(.*)"

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

function Interface:_OnScript(line)
    self:_CallListeners("OnScript", line)
end
Interface.commands["SCRIPT"] = Interface._OnScript
Interface.commandPattern["SCRIPT"] = "([^\t]+)"

function Interface:_OnScriptEnd()
    self:_CallListeners("OnScriptEnd")
end
Interface.commands["SCRIPTEND"] = Interface._OnScriptEnd

function Interface:_OnScriptStart()
    self:_CallListeners("OnScriptStart")
end
Interface.commands["SCRIPTSTART"] = Interface._OnScriptStart

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

function Interface:_OnSetScriptTags(pairs)
    pairs = explode(" ", pairs)
    self:_CallListeners("OnSetScriptTags", pairs)
end
Interface.commands["SETSCRIPTTAGS"] = Interface._OnSetScriptTags
Interface.commandPattern["SETSCRIPTTAGS"] = "([^\t]+)"

function Interface:_OnSetTeamLeader(obj)
    local userName = obj.userName
    self:_CallListeners("OnSetTeamLeader", userName)
end
Interface.jsonCommands["SETTEAMLEADER"] = Interface._OnSetTeamLeader

function Interface:_OnTASServer(protocolVersion, springVersion, udpPort, serverMode)
    self:_CallListeners("OnTASServer", protocolVersion, springVersion, udpPort, serverMode)
end
Interface.commands["TASServer"] = Interface._OnTASServer
Interface.commandPattern["TASServer"] = "(%S+)%s+(%S+)%s+(%S+)%s+(%S+)"

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

function Interface:_OnUpdateBattleInfo(battleID, spectatorCount, locked, mapHash, mapName)
    battleID = tonumber(battleID)
    self:_CallListeners("OnUpdateBattleInfo", battleID, spectatorCount, locked, mapHash, mapName)
end
Interface.commands["UPDATEBATTLEINFO"] = Interface._OnUpdateBattleInfo
Interface.commandPattern["UPDATEBATTLEINFO"] = "(%d+)%s+(%S+)%s+(%S+)%s+(%S+)%s+([^\t]+)"

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

function Interface:_OnFriendListParse(tags)
    local tags = parseTags(tags)
    local userName = getTag(tags, "userName", true)
    self:_OnFriendList(userName)
end

function Interface:_OnFriendList(userName)
    self:_CallListeners("OnFriendList", userName)
end
Interface.commands["FRIENDLIST"] = Interface._OnFriendListParse
Interface.commandPattern["FRIENDLIST"] = "(.+)"

function Interface:_OnFriendListBegin()
    self:_CallListeners("OnFriendListBegin")
end
Interface.commands["FRIENDLISTBEGIN"] = Interface._OnFriendListBegin

function Interface:_OnFriendListEnd()
    self:_CallListeners("OnFriendListEnd")
end
Interface.commands["FRIENDLISTEND"] = Interface._OnFriendListEnd

function Interface:_OnListQueues(queues)
    self:_CallListeners("OnListQueues", queues)
end
Interface.jsonCommands["LISTQUEUES"] = Interface._OnListQueues

function Interface:_Disconnected()
    self:_CallListeners("OnDisconnected")
end

function Interface:CommandReceived(command)
    local cmdId, cmdName, arguments
    if command:sub(1,1) == "#" then
        i = command:find(" ")
        cmdId = command:sub(2, i - 1)
        j = command:find(" ", i + 1)
        if j ~= nil then
            cmdName = command:sub(i + 1, j - 1)
            arguments = command:sub(j + 1)
        else
            cmdName = command:sub(i + 1)
        end
    else
        i = command:find(" ")
        if i ~= nil then
            cmdName = command:sub(1, i - 1)
            arguments = command:sub(i + 1)
        else
            cmdName = command
        end
    end

    self:_OnCommandReceived(cmdName, arguments, cmdId)
end

function Interface:_GetCommandPattern(cmdName)
    return Wrapper.commandPattern[cmdName]
end

function Interface:_GetCommandFunction(cmdName)
    return Interface.commands[cmdName], Interface.commandPattern[cmdName]
end

function Interface:_GetJsonCommandFunction(cmdName)
    return Interface.jsonCommands[cmdName]
end

-- status can be one of: "offline", "connected" and "disconnected"
function Interface:GetConnectionStatus()
	return self.status
end

function Interface:_OnCommandReceived(cmdName, arguments, cmdId)
    local commandFunction, pattern = self:_GetCommandFunction(cmdName)
    local fullCmd
    if arguments ~= nil then
        fullCmd = cmdName .. " " .. arguments
    else
        fullCmd = cmdName
    end

    if commandFunction ~= nil then
        local pattern = self:_GetCommandPattern(cmdName)
        if pattern then
            local funArgs = {arguments:match(pattern)}
            if #funArgs ~= 0 then
                commandFunction(self, unpack(funArgs))
            else
                Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to match command: ", cmdName, ", args: " .. tostring(arguments) .. " with pattern: ", pattern)
            end
        else
            --Spring.Echo("No pattern for command: " .. cmdName)
            commandFunction(self)
        end
    else
        local jsonCommandFunction = self:_GetJsonCommandFunction(cmdName)
        if jsonCommandFunction ~= nil then
            local success, obj = pcall(json.decode, arguments)
            if not success then
                Spring.Log(LOG_SECTION, LOG.ERROR, "Failed to parse JSON: " .. tostring(arguments))
            end
            jsonCommandFunction(self, obj)
        else
            Spring.Log(LOG_SECTION, LOG.ERROR, "No such function: " .. cmdName .. ", for command: " .. fullCmd)
        end
    end
    self:_CallListeners("OnCommandReceived", fullCmd)
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
        Spring.Log(LOG_SECTION, LOG.ERROR, "Error in select: " .. error)
    end
    for _, input in ipairs(readable) do
        local s, status, commandsStr = input:receive('*a') --try to read all data
        if (status == "timeout" or status == nil) and commandsStr ~= nil and commandsStr ~= "" then
            Spring.Log(LOG_SECTION, LOG.DEBUG, commandsStr)
            local commands = explode("\n", commandsStr)
            commands[1] = self.buffer .. commands[1]
            for i = 1, #commands-1 do
                local command = commands[i]
                if command ~= nil then
                    self:CommandReceived(command)
                end
            end
            self.buffer = commands[#commands]
        elseif status == "closed" then
            Spring.Log(LOG_SECTION, LOG.INFO, "Disconnected from server.")
            input:close()
			-- if status is "offline", user initiated the disconnection
			if self.status ~= "offline" then
				self.status = "disconnected"
			end
            self:_Disconnected()
        end
    end
end

function Interface:SafeUpdate()
    self:_SocketUpdate()
    -- prevent timeout with PING
    if self.status == "connected" then
        local nowSeconds = Spring.GetGameSeconds()
        if nowSeconds - self.lastSentSeconds > 30 then
            self:Ping()
        end
    end
end

function Interface:Update()
    xpcall(function() self:SafeUpdate() end, 
        function(err) self:_PrintError(err) end )
end

return Interface
