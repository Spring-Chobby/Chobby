Wrapper = Interface:extends{}

function Wrapper:init()
--    self:super("init")
    -- don't use these fields directly, they are subject to change
    self.users = {}
    self.userCount = 0
end

function Wrapper:OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)

    self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}
    self.userCount = self.userCount + 1

    self:super("OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Wrapper.OnAddUser

function Wrapper:OnRemoveUser(userName)
    self.users[userName] = nil
    self.userCount = self.userCount - 1

    self:super("OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Wrapper.OnRemoveUser

function Wrapper:GetUserCount()
    return self.userCount
end

function Wrapper:GetUserDetails(userName)
    return self.users[userName]
end

return Wrapper
