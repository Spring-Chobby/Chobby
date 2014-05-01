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

Lobby = Observable:extends{}
-- register all lobby commands in a associative map
Lobby.commands = {}

function Lobby:Initialize()
   -- dumpConfig()
    self.messagesSentCount = 0
    self.messagesReceivedCount = 0
    self.lastSentSeconds = Spring.GetGameSeconds()
    self.connected = false
    self.listeners = {}
    self.awaitingChannelsList = false
end

function Lobby:Connect(host, port)
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
    -- use HASH command so we can send passwords in plain text
    self:_SendCommand("HASH")
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

-- has a listener, but isn't a command
function Lobby:OnConnect(args)
    self:CallListeners("OnConnect")
end

function Lobby:CommandReceived(command)
    -- if it's the first message received, then it's probably the server greeting
    if self.messagesReceivedCount == 1 then
        self:CallListeners("OnConnect")
    end

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
        Spring.Echo(commandsStr)
		if status == "timeout" or status == nil then
            local commands = explode("\n", commandsStr)
            for i = 1, #commands-1 do
                local command = commands[i]
                self.messagesReceivedCount = self.messagesReceivedCount + 1
                self:CommandReceived(command)
            end
		elseif status == "closed" then
            Spring.Echo("closed connection")
			input:close()
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
