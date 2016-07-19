InterfaceSkirmish = Lobby:extends()

function InterfaceSkirmish:init()
	self:super("init")
	self.name = "singleplayer"
	self.myUserName = "Player"
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
		hostport = 0,
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

-- TODO: Needs clean implementation in lobby.lua
function InterfaceSkirmish:StartBattle()
	local battle = self:GetBattle(self:GetMyBattleID())
	if battle.gameName and battle.mapName then
		self:_CallListeners("OnBattleAboutToStart")
		self:_OnSaidBattleEx("Battle", "about to start")
		self:_StartScript(battle.gameName, battle.mapName, self:GetMyUserName() or "noname")
	end
	return self
end

-- TODO: Needs clean implementation in lobby.lua
function InterfaceSkirmish:SelectMap(mapName)
	self:_OnUpdateBattleInfo(self:GetMyBattleID(), 0, false, 0, mapName)
end

-- Skirmish only
function InterfaceSkirmish:SetBattleState(myUserName, gameName, mapName, title)
	local myBattleID = 1

	self:_OnAddUser(myUserName)
	self.myUserName = myUserName
						--(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other, engineVersion, mapName, title, gameName, spectatorCount)
	self:_OnBattleOpened(myBattleID, nil,  nil,  myUserName, nil, nil, nil,         nil,       nil,       nil, nil,            nil, mapName, title, gameName, nil)
	self:_OnJoinedBattle(myBattleID, myUserName)

	return self
end

-------------------------------------------------
-- BEGIN Client commands
-------------------------------------------------

function InterfaceSkirmish:AddAi(aiName, aiLib, allyNumber)
	self:super("AddAi", aiName, aiLib, allyNumber)
	self:_OnAddAi(self:GetMyBattleID(), aiName, {
		aiLib = aiLib,
		allyNumber = allyNumber,
		owner = self:GetMyUserName(),
	})
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
	self:super("LeaveBattle")
	local myBattleID = self:GetMyBattleID()
	if myBattleID then
		self:_OnLeftBattle(myBattleID, self:GetMyUserName())
		self:_OnBattleClosed(myBattleID)
	end
	return self
end

function InterfaceSkirmish:RemoveAi(aiName)
	self:_OnRemoveAi(self:GetMyBattleID(), aiName)
	return self
end

-------------------------------------------------
-- END Client commands
-------------------------------------------------

-------------------------------------------------
-- BEGIN Server commands
-------------------------------------------------

-------------------------------------------------
-- END Server commands
-------------------------------------------------

return InterfaceSkirmish
