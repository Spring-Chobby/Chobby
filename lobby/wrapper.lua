-- WARNING: Don't include this file if you won't use the Wrapper, it overrides the Interface functions
Wrapper = Interface:extends{}

function Wrapper:init()
--    self:super("init")
    -- don't use these fields directly, they are subject to change
    self.users = {}
    self.userCount = 0
    self.latency = 0 -- in ms
end

-- override
function Wrapper:OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)

    self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}
    self.userCount = self.userCount + 1

    self:super("OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Wrapper.OnAddUser

-- override
function Wrapper:OnRemoveUser(userName)
    self.users[userName] = nil
    self.userCount = self.userCount - 1

    self:super("OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Wrapper.OnRemoveUser

-- override
function Wrapper:Ping()
    self.pingTimer = Spring.GetTimer()
    self:super("Ping")
end

-- override
function Wrapper:OnPong()
    self.pongTimer = Spring.GetTimer()
    self.latency = Spring.DiffTimers(self.pongTimer, self.pingTimer, true)
    self:super("OnPong")
end
Interface.commands["PONG"] = Wrapper.OnPong

function Wrapper:GetUserCount()
    return self.userCount
end

function Wrapper:GetUserDetails(userName)
    return self.users[userName]
end

function Wrapper:GetLatency()
    return self.latency
end

return Wrapper
