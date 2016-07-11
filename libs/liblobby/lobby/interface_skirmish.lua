InterfaceSkirmish = Lobby:extends()

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
	
	for userName, data in pairs(self.userBattleStatus) do
		if data.allyNumber then
			if data.aiLib then
				ais[aiCount] = {
					Name = userName,
					Team = teamCount,
					IsFromDemo = 0,
					ShortName = data.aiLib,
					Host = 0,
				}
				aiCount = aiCount + 1
			else
				players[playerCount] = {
					Name = userName,
					Team = teamCount,
					IsFromDemo = 0,
					Spectator = (data.isSpectator and 1) or nil,
					rank = 0,
				}
				playerCount = playerCount + 1
			end
			if not data.IsSpectator then
				teams[teamCount] = {
					TeamLeader = 0,
					AllyTeam = data.allyNumber,
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

-- TODO: These two functions don't have uber/ZK server equivalent functions
function InterfaceSkirmish:StartBattle()
	local battle = self:GetBattle(self:GetMyBattleID())
	if battle.gameName and battle.mapName then
		self:_CallListeners("OnBattleAboutToStart")
		self:_OnSaidBattleEx("Battle", "about to start")
		self:_StartScript(battle.gameName, battle.mapName, self:GetMyUserName() or "noname")
	end
	return self
end

function InterfaceSkirmish:SelectMap(mapName)
	self:_OnUpdateBattleInfo(self:GetMyBattleID(), 0, false, 0, mapName)
end

-------------------------------------------------
-- BEGIN Client commands
-------------------------------------------------

function InterfaceSkirmish:AddAi(aiName, aiLib, allyNumber)
	self:_OnAddAi(self:GetMyBattleID(), aiName, aiLib, allyNumber, self:GetMyUserName())
end

function InterfaceSkirmish:SayBattle(message)
	self:super("SayBattle", message)
	self:_OnSaidBattle(self:GetMyUserName(), message)
	return self
end

function InterfaceSkirmish:SetBattleStatus(status)
	self:super("SetBattleStatus", status)
	self:_OnUpdateUserBattleStatus(self:GetMyUserName(), status)
	return self
end

function InterfaceSkirmish:LeaveBattle()
	self:_OnLeftBattle()
	self:_OnBattleClosed()
	return self
end

-- TODO: seems like it's a custom skirmish function, rework into the lobby API
function InterfaceSkirmish:SetBattleState(myUserName, gameName, mapName, battleName)
	self.myUserName  = myUserName
	self.myBattleID  = 1

	-- TODO: Use this instead
	--self:_OnBattleOpened(self.myBattleID, ...)
	self.battles[self.myBattleID] = {}
	local battle = self:GetBattle(self.myBattleID)

	battle.gameName  = gameName
	battle.mapName   = mapName
	battle.users     = {myUserName}
	battle.title     = battleName
	return self
end

-------------------------------------------------
-- END Client commands
-------------------------------------------------

-------------------------------------------------
-- BEGIN Server commands
-------------------------------------------------

function InterfaceSkirmish:_UpdateBotStatus(data)
	self:_OnUpdateUserBattleStatus(data) -- TODO, better implementation.
end

function InterfaceSkirmish:_RemoveBot(data)
	self:_CallListeners("RemoveBot", data)
end

-------------------------------------------------
-- END Server commands
-------------------------------------------------

return InterfaceSkirmish
