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

-- WARNING: Don't include this file if you won't use the Wrapper, it overrides the Wrapper functions
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

    self.battles = {}
    self.battleCount = 0

    self.queues = {}
    self.queueCount = 0

    self.team = nil

    self.latency = 0 -- in ms

    self.loginData = nil
    self.myUserName = nil
	
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

-- override
function Wrapper:Connect(host, port)
    self.host = host
    self.port = port
    self:super("Connect", host, port)
end

-- override
function Wrapper:Login(user, password, cpu, localIP) 
    self.myUserName = user
    self.loginData = { user, password, cpu, localIP }
    self:super("Login", user, password, cpu, localIP)
end

-- override
function Wrapper:_OnTASServer(...)
    if self.disconnectTime then -- in the process of reconnecting
        self.disconnectTime = nil
        self:Login(unpack(self._oldData.loginData))
    end
    self:super("_OnTASServer", ...)
    --self:super("_OnTASServer")
end
Wrapper.commands["TASServer"] = Wrapper._OnTASServer

-- override
function Wrapper:_OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)

    self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}
    self.userCount = self.userCount + 1

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
function Wrapper:Ping()
    self.pingTimer = Spring.GetTimer()
    return self:super("Ping")
end

-- override
function Wrapper:_OnPong()
    self.pongTimer = Spring.GetTimer()
    self.latency = Spring.DiffTimers(self.pongTimer, self.pingTimer, true)
    self:super("_OnPong")
end
Wrapper.commands["PONG"] = Wrapper._OnPong

-- override
function Wrapper:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
    battleID = tonumber(battleID)
    type = tonumber(type)
    natType = tonumber(natType)
    port = tonumber(port)
    maxPlayers = tonumber(maxPlayers)
    passworded = tonumber(passworded) ~= 0
    
    local engineName, engineVersion, map, title, gameName = unpack(explode("\t", other))

    self.battles[battleID] = { 
        battleID=battleID, type=type, natType=natType, founder=founder, ip=ip, port=port, 
        maxPlayers=maxPlayers, passworded=passworded, rank=rank, mapHash=mapHash, 
        engineName=engineName, engineVersion=engineVersion, map=map, title=title, gameName=gameName, users={founder},
    }
    self.battleCount = self.battleCount + 1

    self:super("_OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
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

    self:super("_OnJoinedBattle", battleID, userName, scriptPassword)
end
Wrapper.commands["JOINEDBATTLE"] = Wrapper._OnJoinedBattle

-- override
function Wrapper:_OnLeftBattle(battleID, userName)
    battleID = tonumber(battleID)

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
function Wrapper:_OnClients(chanName, clientsStr)
    local channel = self:_GetChannel(chanName)
    local users = explode(" ", clientsStr)

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
function Wrapper:_Disconnected(...)
    if self.disconnectTime == nil then
        self:_PreserveData()
        self:_Clean()
    end
    self.disconnectTime = Spring.GetGameSeconds()
    self:super("_Disconnected", ...)
end

function Wrapper:Reconnect()
    self.lastReconnectionAttempt = Spring.GetGameSeconds()
    self:Connect(self._oldData.host, self._oldData.port)
end

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

function ShallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- users
function Wrapper:GetUserCount()
    return self.userCount
end
function Wrapper:GetUser(userName)
    return self.users[userName]
end
-- returns users table (not necessarily an array)
function Wrapper:GetUsers()
    return ShallowCopy(self.users)
end

-- friends
function Wrapper:GetFriendCount()
    return self.friendCount
end
-- returns friends table (not necessarily an array)
function Wrapper:GetFriends()
    return ShallowCopy(self.friends)
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

-- channels
function Wrapper:GetChannelCount()
    return self.channelCount
end
function Wrapper:GetChannel(channelName)
    return self.channels[channelName]
end
-- returns channels table (not necessarily an array)
function Wrapper:GetChannels()
    return ShallowCopy(self.channels)
end

function Wrapper:GetLatency()
    return self.latency
end

-- My data
-- My user
function Wrapper:GetMyUserName()
    return self.myUserName
end

return Wrapper
