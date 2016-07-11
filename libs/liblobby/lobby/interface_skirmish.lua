InterfaceSkirmish = Lobby:extends()

function InterfaceSkirmish:init()
	self.listeners = {}
	-- don't use these fields directly, they are subject to change
	self:_Clean()
end

function InterfaceSkirmish:_Clean()
	self.battle = {}
	self.battleID = nil
	
	self.loginData = nil
	self.myUserName = nil
	self.scriptPassword = nil
	
	self.battlePlayerData = {}

	self.isReady = nil
	self.teamNumber = nil
	self.teamColor = nil
	self.allyNumber = nil
	self.isSpectator = nil
	self.sync = nil
	self.side = nil
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

function InterfaceSkirmish:_StartScript(gameName, mapName, playerName)
	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local playerCount = 0
	local ais = {}
	local aiCount = 0
	
	local allyTeamMap = {}
	
	for userName, data in pairs(self.battlePlayerData) do
		if data.AllyNumber then
			if data.AiLib then
				ais[aiCount] = {
					Name = userName,
					Team = teamCount,
					IsFromDemo = 0,
					ShortName = data.AiLib,
					Host = 0,
				}
				aiCount = aiCount + 1
			else
				players[playerCount] = {
					Name = userName,
					Team = teamCount,
					IsFromDemo = 0,
					Spectator = (data.IsSpectator and 1) or nil,
					rank = 0,
				}
				playerCount = playerCount + 1
			end
			if not data.IsSpectator then
				teams[teamCount] = {
					TeamLeader = 0,
					AllyTeam = data.AllyNumber,
					rgbcolor = '0.99609375 0.546875 0',
				}
				teamCount = teamCount + 1
			end
		end
	end
	
	for i, teamData in pairs(teams) do
		if not allyTeamMap[teamData.AllyTeam] then
			allyTeamMap[teamData.AllyTeam] = allyTeamCount
			allyTeams[allyTeamCount] = {
				numallies = 0,
			}
			allyTeamCount = allyTeamCount + 1
		end
		teamData.AllyTeam = allyTeamMap[teamData.AllyTeam]
	end
	
	local script = {
		gametype = gameName,
		hostip = '127.0.0.1',
		hostport = 8458, -- probably should pick hosts better
		ishost = 1,
		mapname = mapName,
		myplayername = playerName,
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 2,
	}
	
	for i, ai in pairs(ais) do
		script["ai" .. i] = ai
	end
	for i, player in pairs(players) do
		script["player" .. i] = player
	end
	for i, team in pairs(teams) do
		script["team" .. i] = team
	end
	for i, allyTeam in pairs(allyTeams) do
		script["allyTeam" .. i] = allyTeam
	end
	
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
function InterfaceSkirmish:_OnUpdateBattleInfo(spectatorCount, locked, mapHash, mapName)
	self.battle.spectatorCount = spectatorCount or self.battle.spectatorCount
	self.battle.locked = locked or self.battle.locked
	self.battle.mapHash = mapHash or self.battle.mapHash
	self.battle.mapName = mapName or self.battle.mapName
	self:_CallListeners("OnUpdateBattleInfo", self:GetMyBattleID(), spectatorCount, locked, mapHash, mapName)
end

function InterfaceSkirmish:_OnLeftBattle()
	self:_CallListeners("OnLeftBattle", self:GetMyBattleID(), self:GetMyUserName())
end

function InterfaceSkirmish:_OnJoinedBattle()
	self:_CallListeners("OnJoinedBattle", self:GetMyBattleID(), self:GetMyUserName())
end

-- TODO: fix and just use lobby!
function InterfaceSkirmish:_UpdateUserBattleStatus(data)
	if data.userName then
		if not self.battlePlayerData[data.Name] then
			self.battlePlayerData[data.Name] = {}
		end
		local userData = self.battlePlayerData[data.Name]
		userData.AllyNumber = data.AllyNumber or userData.AllyNumber
		userData.TeamNumber = data.TeamNumber or userData.TeamNumber
		if data.IsSpectator ~= nil then
			userData.IsSpectator = data.IsSpectator
		end
		userData.AiLib = data.AiLib or userData.AiLib
		userData.Sync = data.Sync or userData.Sync
		
		data.allyNumber = self.allyNumber
		data.teamNumber = self.teamNumber
		data.isSpectator = self.isSpectator
		data.sync = self.sync
		data.aiLib = userData.aiLib
	end
	self:_CallListeners("UpdateUserBattleStatus", data)
end

function WrapperSkirmish:_UpdateBotStatus(data)
	self:_UpdateUserBattleStatus(data) -- TODO, better implementation.
end

function WrapperSkirmish:_RemoveBot(data)
	self:_CallListeners("RemoveBot", data)
end

function InterfaceSkirmish:_OnSaidBattle(userName, message)
	self:_CallListeners("OnSaidBattle", userName, message)
end

function InterfaceSkirmish:_OnSaidBattleEx(userName, message)
	self:_CallListeners("OnSaidBattleEx", userName, message)
end

function InterfaceSkirmish:_OnBattleClosed()
	self:_CallListeners("OnBattleClosed", self:GetMyBattleID())
end

------------------------------------------------------------------------
-- Getters
------------------------------------------------------------------------
function InterfaceSkirmish:GetMyBattleID()
	return self.battleID
end

function InterfaceSkirmish:GetMyUserName()
	return self.myUserName
end

function InterfaceSkirmish:GetBattle()
	return self.battle
end

function InterfaceSkirmish:GetMyIsSpectator()
	if self.battlePlayerData[self.myUserName] then		
		return self.battlePlayerData[self.myUserName].IsSpectator
	end
end

------------------------------------------------------------------------
-- Setters
------------------------------------------------------------------------

function InterfaceSkirmish:AddAi(aiName, allyNumber, Name)
	local botData = {
		AllyNumber = allyNumber or 0,
		AiLib = aiName or "NullAI",
		Name = Name or (aiName .. "_" .. math.floor(math.random()*100)),
		Owner = self:GetMyUserName()
	}
	self:_UpdateBotStatus(botData)
end

function InterfaceSkirmish:SelectMap(mapName)
	self:_OnUpdateBattleInfo(0, false, 0, mapName)
end

function InterfaceSkirmish:StartBattle()
	if self.battle.gameName and self.battle.mapName then
		self:_CallListeners("BattleAboutToStart")
		self:_OnSaidBattleEx("Battle", "about to start")
		self:_StartScript(self.battle.gameName, self.battle.mapName, self.myUserName or "noname")
	end
	return self
end

function InterfaceSkirmish:SayBattle(message)
	self:_OnSaidBattle(self:GetMyUserName(), message)
	return self
end

function InterfaceSkirmish:SetBattleStatus(battleData)
	battleData.userName = self:GetMyUserName()
	self:_UpdateUserBattleStatus(battleData)
	return self
end

function InterfaceSkirmish:LeaveBattle()
	self:_OnLeftBattle()
	self:_OnBattleClosed()
	return self
end

function InterfaceSkirmish:SetBattleState(myUserName, gameName, mapName, battleName)
	self.myUserName = myUserName
	self.battle.gameName = gameName
	self.battle.mapName = mapName
	self.battle.users = {myUserName}
	self.battle.title = battleName
	self.battleID = 1
	return self
end

return InterfaceSkirmish
