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

-- WARNING: Don't include this file if you won't use the Wrapper, it overrides the Interface functions
Wrapper = Interface:extends{}

function Wrapper:init()
--    self:super("init")
    -- don't use these fields directly, they are subject to change
    self.users = {}
    self.userCount = 0

    self.battles = {}
    self.battleCount = 0

    self.latency = 0 -- in ms
end

-- override
function Wrapper:_OnAddUser(userName, country, cpu, accountID)
    cpu = tonumber(cpu)
    accountID = tonumber(accountID)

    self.users[userName] = {userName=userName, country=country, cpu=cpu, accountID=accountID}
    self.userCount = self.userCount + 1

    self:super("_OnAddUser", userName, country, cpu, accountID)
end
Interface.commands["ADDUSER"] = Wrapper._OnAddUser

-- override
function Wrapper:_OnRemoveUser(userName)
    self.users[userName] = nil
    self.userCount = self.userCount - 1

    self:super("_OnRemoveUser", userName)
end
Interface.commands["REMOVEUSER"] = Wrapper._OnRemoveUser

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
Interface.commands["PONG"] = Wrapper._OnPong

-- override
function Wrapper:_OnBattleOpened(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
    battleID = tonumber(battleID)
    type = tonumber(type)
    natType = tonumber(natType)
    port = tonumber(port)
    maxPlayers = tonumber(maxPlayers)
    passworded = tonumber(passworded)
    
    local engineName, engineVersion, map, title, gameName = unpack(explode("\t", other))

    self.battles[battleID] = { 
		battleID=battleID, type=type, natType=natType, founder=founder, ip=ip, port=port, 
		maxPlayers=maxPlayers, passworded=passworded, rank=rank, mapHash=mapHash, 
		engineName=engineName, engineVersion=engineVersion, map=map, title=title, gameName=gameName, users={},
	}
    self.battleCount = self.battleCount + 1

    self:super("_OnBattleOpened", battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other)
end
Interface.commands["BATTLEOPENED"] = Wrapper._OnBattleOpened

-- override
function Wrapper:_OnBattleClosed(battleID)
    self.battles[battleID] = nil
    self.battleCount = self.battleCount - 1

    self:super("_OnBattleClosed", battleID)
end
Interface.commands["BATTLECLOSED"] = Wrapper._OnBattleClosed

-- override
function Wrapper:_OnJoinedBattle(battleID, userName, scriptPassword)
    battleID = tonumber(battleID)
    table.insert(self.battles[battleID].users, userName)

    self:super("_OnJoinedBattle", battleID, userName, scriptPassword)
end
Interface.commands["JOINEDBATTLE"] = Wrapper._OnJoinedBattle

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
Interface.commands["LEFTBATTLE"] = Wrapper._OnLeftBattle

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

-- battles
function Wrapper:GetBattleCount()
    return ShallowCopy(self.battleCount)
end
function Wrapper:GetBattle(battleName)
    return self.battles[battleName]
end
-- returns battles table (not necessarily an array)
function Wrapper:GetBattles()
    return self.battles
end


function Wrapper:GetLatency()
    return self.latency
end

return Wrapper
