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

function Interface:OnJoin(chanName)
    self:CallListeners("OnJoin", chanName)
end
Interface.commands["JOIN"] = Interface.OnJoin
Interface.commandPattern["JOIN"] = "(%S+)"

function Interface:OnClients(chanName, clientsStr)
    local clients = explode(clients, " ")
    self:CallListeners("OnClients", chanName, clients)
end
Interface.commands["CLIENTS"] = Interface.OnClients
Interface.commandPattern["CLIENTS"] = "(%S+)%s+(.+)"

function Interface:OnSaid(chanName, userName, message)
    self:CallListeners("OnSaid", chanName, userName, message)
end
Interface.commands["SAID"] = Interface.OnSaid
Interface.commandPattern["SAID"] = "(%S+)%s+(%S+)%s+(.*)"

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

function Interface:OnChannel(chanName, userCount, topic)
    userCount = tonumber(userCount)
    self:CallListeners("OnChannel", chanName, userCount, topic)
end
Interface.commands["CHANNEL"] = Interface.OnChannel
Interface.commandPattern["CHANNEL"] = "(%S+)%s+(%d+)(.*)"

function Interface:OnPong()
    self:CallListeners("OnPong")
end
Interface.commands["PONG"] = Interface.OnPong

function Interface:OnEndOfChannels()
    self:CallListeners("OnEndOfChannels")
    self.awaitingChannelsList = false
end
Interface.commands["ENDOFCHANNELS"] = Interface.OnEndOfChannels

function Interface:OnDenied(reason)
    self:CallListeners("OnDenied", reason)
end
Interface.commands["DENIED"] = Interface.OnDenied
Interface.commandPattern["DENIED"] = "(.+)"

function Interface:OnAccepted(username)
    self:CallListeners("OnAccepted", username)
end
Interface.commands["ACCEPTED"] = Interface.OnAccepted
Interface.commandPattern["DENIED"] = "(%S+)%s+(%S+)"

function Interface:OnAgreement(line)
    self:CallListeners("OnAgreement", line)
end
Interface.commands["AGREEMENT"] = Interface.OnAgreement
Interface.commandPattern["DENIED"] = "(.+)"

function Interface:OnAgreementEnd()
    self:CallListeners("OnAgreementEnd")
end
Interface.commands["AGREEMENTEND"] = Interface.OnAgreementEnd

function Interface:OnLoginInfoEnd()
    self:CallListeners("OnLoginInfoEnd")
end
Interface.commands["LOGININFOEND"] = Interface.OnLoginInfoEnd

function Interface:OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)
    self:CallListeners("OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Interface.OnAddUser
Interface.commandPattern["ADDUSER"] = "(%S+)%s+(%S%S)%s+(%S+)(.*)"

function Interface:OnClientStatus(userName, status)
    self:CallListeners("OnClientStatus", userName, status)
end
Interface.commands["CLIENTSTATUS"] = Interface.OnClientStatus
Interface.commandPattern["CLIENTSTATUS"] = "(%S+)%s+(%S+)"

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
                Spring.Echo("Failed to match command: ", args[1], " with pattern: ", pattern)
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
        --Spring.Echo(commandsStr)
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
