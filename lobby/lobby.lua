if not Spring.GetConfigInt("LuaSocketEnabled", 0) == 1 then
    Spring.Echo("LuaSocketEnabled is disabled")
    return false
end

local socket = socket

local client
local set

local host = "localhost"
local port = 8005

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

local function newset()
    local reverse = {}
    local set = {}
    return setmetatable(set, {__index = {
        insert = function(set, value)
            if not reverse[value] then
                table.insert(set, value)
                reverse[value] = table.getn(set)
            end
        end,
        remove = function(set, value)
            local index = reverse[value]
            if index then
                reverse[value] = nil
                local top = table.remove(set)
                if top ~= value then
                    reverse[top] = index
                    set[index] = top
                end
            end
        end
    }})
end

local function concat(...)
    return table.concat({...}, " ")
end

Lobby = Observable:extends{}
-- register all lobby commands in a associative map
Lobby.commands = {}

function Lobby:Initialize()
   -- dumpConfig()
    self.messagesSentCount = 0
    self.lastSentSeconds = Spring.GetGameSeconds()
    self.connected = false
    self.listeners = {}
    self.awaitingChannelsList = false
end

function Lobby:Connect(host, port)
    client = socket.tcp()
	client:settimeout(0)
	res, err = client:connect(host, port)
	if not res and not res == "timeout" then
		Spring.Echo("Error in connect: " .. err)
		return false
	end
	set = newset()
	set:insert(client)
    self.client = client
    self.connected = true
	return true
end

function Lobby:_SendCommand(command, sendMessageCount)
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

function Lobby:SendCustomCommand(command)
    self:_SendCommand(command, false)
end

function Lobby:Login(user, password, cpu, localIP)
    if localIP == nil then
        localIP = "*"
    end
    self:_SendCommand(concat("LOGIN", user, password, cpu, localIP, "LuaLobby"))
end

function Lobby:Ping()
    self:_SendCommand("PING", true)
end

function Lobby:Join(chanName, key)
    local command = concat("JOIN", chanName)
    if key ~= nil then
        command = concat(command, key)
    end
    self:_SendCommand(command, true)
end

function Lobby:OnJoinReceived(args)
    local chanName = args[2]
    self:CallListeners("OnJoinReceived", chanName)
end
Lobby.commands["JOIN"] = Lobby.OnJoinReceived 

function Lobby:OnClients(args)
    local chanName = args[2]
    local clients = {}
    for i = 3, #args do
        table.insert(clients, args[i])
    end
    self:CallListeners("OnClients", chanName, clients)
end
Lobby.commands["CLIENTS"] = Lobby.OnClients

function Lobby:OnSaid(args)
    local chanName = args[2]
    local userName = args[3]
    local message = table.concat(args, " ", 4, #args)
    self:CallListeners("OnSaid", chanName, userName, message)
end
Lobby.commands["SAID"] = Lobby.OnSaid

function Lobby:Say(chanName, message)
    self:_SendCommand(concat("SAY", chanName, message), true)
end

function Lobby:Channels()
    self:_SendCommand("CHANNELS", true)
    self.awaitingChannelsList = true
end

function Lobby:OnChannel(args)
    local chanName = args[2]
    local userCount = args[3]
    local topic = args[4]
    self:CallListeners("OnChannel", chanName, userCount, topic)
end
Lobby.commands["CHANNEL"] = Lobby.OnChannel

function Lobby:OnPong(args)
    self:CallListeners("OnPong")
end
Lobby.commands["PONG"] = Lobby.OnPong

function Lobby:OnEndOfChannels(args)
    self:CallListeners("OnEndOfChannels")
    self.awaitingChannelsList = false
end
Lobby.commands["ENDOFCHANNELS"] = Lobby.OnEndOfChannels

function Lobby:CommandReceived(command)
    local args = explode(" ", command)
    if string.starts(args[1], "#") then
        table.remove(args, 1)
    end
    
    commandFunction = Lobby.commands[args[1]]
    if commandFunction ~= nil then
        commandFunction(self, args)
    else
        print("No such function" .. args[1] .. ", for command: " .. command)
    end
    self:CallListeners("OnCommandReceived", command)
end

function Lobby:_SocketUpdate()
	if set==nil or #set<=0 then
		return
	end
	-- get sockets ready for read
	local readable, writeable, err = socket.select(set, set, 0)
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
		if status == "timeout" or status == nil then
            commands = explode("\n", commandsStr)
            for i, command in pairs(commands) do
                self:CommandReceived(command)
            end
		elseif status == "closed" then
            Spring.Echo("closed connection")
			input:close()
			set:remove(input)
            self.connected = false
		end
	end
end

function Lobby:Update()
    self:_SocketUpdate()
    -- prevent timeout with PING
    if self.connected then
        local nowSeconds = Spring.GetGameSeconds()
        if nowSeconds - self.lastSentSeconds > 30 then
            self:Ping()
        end
    end
end

return Lobby
