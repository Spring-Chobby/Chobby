WrapperSkirmish = Observable:extends()

function WrapperSkirmish:init(myUserName)
	self.listeners = {}
	-- don't use these fields directly, they are subject to change
	self:_Clean()
end

function WrapperSkirmish:_Clean()
	self.battle = {}
	self.battleID = nil
	
	self.loginData = nil
	self.myUserName = nil
	self.scriptPassword = nil
	
	self.AllyNumber = nil
	self.TeamNumber = nil
	self.IsSpectator = nil
	self.Sync = nil
end

local function ScriptTXT(script)
	local string = '[Game]\n{\n\n'

	-- First write Tables
	for key, value in pairs(script) do
		if type(value) == 'table' then
			string = string..'\t['..key..']\n\t{\n'
			for key, value in pairs(value) do
				string = string..'\t\t'..key..' = '..value..';\n'
			end
			string = string..'\t}\n\n'
		end
	end

	-- Then the rest (purely for aesthetics)
	for key, value in pairs(script) do
		if type(value) ~= 'table' then
			string = string..'\t'..key..' = '..value..';\n'
		end
	end
	string = string..'}'

	local txt = io.open('script.txt', 'w+')
	txt:write(string)
	txt:close()
	return string
end

function WrapperSkirmish:_StartScript(gameName, mapName, playerName)
	local script = {
		player0  =  {
			isfromdemo = 0,
			name = playerName,
			rank = 0,
			spectator = 1,
			team = 0,
		},

		team0  =  {
			allyteam = 0,
			rgbcolor = '0.99609375 0.546875 0',
			side = 'CORE',
			teamleader = 0,
		},

		allyteam0  =  {
			numallies = 0,
		},

		gametype = gameName,
		hostip = '127.0.0.1',
		hostport = 8458, -- probably should pick hosts better
		ishost = 1,
		mapname = mapName,
		myplayername = 'Local',
		nohelperais = 0,
		numplayers = 1,
		numusers = 2,
		startpostype = 2,
	}
	
	local scriptFileName = "scriptFile.txt"
	local scriptFile = io.open(scriptFileName, "w")
	local scriptTxt = ScriptTXT(script)
	scriptFile:write(scriptTxt)
	scriptFile:close()
	Spring.Start(scriptFileName, "")
end

------------------------------------------------------------------------
-- Listeners
------------------------------------------------------------------------
function WrapperSkirmish:_OnUpdateBattleInfo(spectatorCount, locked, mapHash, mapName)
	self.battle.spectatorCount = spectatorCount or self.battle.spectatorCount
	self.battle.locked = locked or self.battle.locked
	self.battle.mapHash = mapHash or self.battle.mapHash
	self.battle.mapName = mapName or self.battle.mapName
	self:_CallListeners("OnUpdateBattleInfo", self:GetMyBattleID(), spectatorCount, locked, mapHash, mapName)
end

function WrapperSkirmish:_OnLeftBattle()
	self:_CallListeners("OnLeftBattle", self:GetMyBattleID(), self:GetMyUserName())
end

function WrapperSkirmish:_OnJoinedBattle()
	self:_CallListeners("OnJoinedBattle", self:GetMyBattleID(), self:GetMyUserName())
end

function WrapperSkirmish:_UpdateUserBattleStatus(data)
	if data.Name then
		self.AllyNumber = data.AllyNumber or self.AllyNumber
		self.TeamNumber = data.TeamNumber or self.TeamNumber
		if data.IsSpectator ~= nil then
			self.IsSpectator = data.IsSpectator
		end
		self.Sync = data.Sync or self.Sync
		
		data.AllyNumber = self.AllyNumber
		data.TeamNumber = self.TeamNumber
		data.IsSpectator = self.IsSpectator
		data.Sync = self.Sync
	end
	self:_CallListeners("UpdateUserBattleStatus", data)
end

function WrapperSkirmish:_UpdateBotStatus(data)
	self:_UpdateUserBattleStatus(data) -- TODO, better implementation.
end

function WrapperSkirmish:_RemoveBot(data)
	self:_CallListeners("RemoveBot", data)
end

function WrapperSkirmish:_OnSaidBattle(userName, message)
	self:_CallListeners("OnSaidBattle", userName, message)
end

function WrapperSkirmish:_OnSaidBattleEx(userName, message)
	self:_CallListeners("OnSaidBattleEx", userName, message)
end

function WrapperSkirmish:_OnBattleClosed()
	self:_CallListeners("OnBattleClosed", self:GetMyBattleID())
end

------------------------------------------------------------------------
-- Getters
------------------------------------------------------------------------
function WrapperSkirmish:GetMyBattleID()
	return self.battleID
end

function WrapperSkirmish:GetMyUserName()
	return self.myUserName
end

function WrapperSkirmish:GetBattle()
	return self.battle
end

function WrapperSkirmish:GetMyIsSpectator()	
	return self.IsSpectator
end

------------------------------------------------------------------------
-- Setters
------------------------------------------------------------------------

function WrapperSkirmish:AddAi(aiName, allyNumber, Name)
	local botData = {
		AllyNumber = allyNumber or 0,
		AiLib = aiName or "NullAI",
		Name = Name or (aiName .. "_" .. math.floor(math.random()*100)),
		Owner = self:GetMyUserName()
	}
	self:_UpdateBotStatus(botData)
end

function WrapperSkirmish:SelectMap(mapName)
	self:_OnUpdateBattleInfo(0, false, 0, mapName)
end

function WrapperSkirmish:StartBattle()
	if self.battle.gameName and self.battle.mapName then
		self:_CallListeners("BattleAboutToStart")
		self:_OnSaidBattleEx("Battle", "about to start")
		WrapperSkirmish:_StartScript(self.battle.gameName, self.battle.mapName, self.myUserName or "noname")
	end
	return self
end

function WrapperSkirmish:SayBattle(message)
	self:_OnSaidBattle(self:GetMyUserName(), message)
	return self
end

function WrapperSkirmish:SetBattleStatus(battleData)
	battleData.Name = self:GetMyUserName()
	self:_UpdateUserBattleStatus(battleData)
	return self
end

function WrapperSkirmish:LeaveBattle()
	self:_OnLeftBattle()
	self:_OnBattleClosed()
	return self
end

function WrapperSkirmish:SetBattleState(myUserName, gameName, mapName, battleName)
	self.myUserName = myUserName
	self.battle.gameName = gameName
	self.battle.mapName = mapName
	self.battle.users = {myUserName}
	self.battle.title = battleName
	self.battleID = 1
	return self
end

return WrapperSkirmish
