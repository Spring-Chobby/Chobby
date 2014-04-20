Listener = LCS.class.abstract{}

function Listener:init()
end

function Listener:OnClients(chanName, clients)
end

function Listener:OnLoginInfoEnd()
end

function Listener:OnJoinReceived(chanName)
end

function Listener:OnSaid(chanName, userName, message)
end

function Listener:OnChannel(chanName, userCount, topic)
end

function Listener:OnPong()
end

function Listener:OnEndOfChannels()
end

function Listener:OnCommandReceived(command)
end

function Listener:OnCommandSent(command)
end

return Listener
