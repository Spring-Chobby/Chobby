InterfaceSkirmish = Lobby:extends()

function InterfaceSkirmish:init()
	self:super("init")
	self.name = "singleplayer"
	self.myUserName = "Player"
end

function InterfaceSkirmish:WriteTable(key, value)
	local str = '\t['..key..']\n\t{\n'
	for k, v in pairs(value) do
		if type(v) == 'table' then
			str = str .. self:WriteTable(k, v)
		else
			str = str..'\t\t'..k..' = '..v..';\n'
		end
	end
	return str .. '\t}\n\n'
end

function InterfaceSkirmish:MakeScriptTXT(script)
	local str = '[Game]\n{\n\n'

	-- First write Tables
	for key, value in pairs(script) do
		if type(value) == 'table' then
			str = str .. self:WriteTable(key, value)
		end
	end

	-- Then the rest (purely for aesthetics)
	for key, value in pairs(script) do
		if type(value) ~= 'table' then
			str = str..'\t'..key..' = '..value..';\n'
		end
	end
	str = str..'}'
	return str
end

function InterfaceSkirmish:_StartScript(gameName, mapName, playerName, extraFriends, friendsReplaceAI, hostPort)
	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local playerCount = 0
	local maxAllyTeamID = -1
	local ais = {}
	local aiCount = 0

	extraFriends = extraFriends or {}

	-- Add the player, this is to make the player team 0.
	for userName, data in pairs(self.userBattleStatus) do
		if data.allyNumber and not data.aiLib then
			players[playerCount] = {
				Name = userName,
				Team = teamCount,
				IsFromDemo = 0,
				Spectator = (data.isSpectator and 1) or nil,
				rank = 0,
			}
			playerCount = playerCount + 1

			for i = 1, #extraFriends do
				local friendName = extraFriends[i]
				players[playerCount] = {
					Name = friendName,
					Team = teamCount,
					IsFromDemo = 0,
					Spectator = (data.isSpectator and 1) or nil,
					rank = 0,
				}
				playerCount = playerCount + 1
			end

			if not data.isSpectator then
				teams[teamCount] = {
					TeamLeader = 0,
					AllyTeam = data.allyNumber,
					rgbcolor = '0.99609375 0.546875 0',
				}
				maxAllyTeamID = math.max(maxAllyTeamID, data.allyNumber)
				teamCount = teamCount + 1
			end
		end
	end

	-- Check for chicken difficutly modoption. Possibly add an AI due to it.
	local chickenName
	if self.modoptions and self.modoptions.chickenailevel and self.modoptions.chickenailevel ~= "none" then
		chickenName = self.modoptions.chickenailevel
	end

	-- Add the AIs
	local chickenAdded = false
	for userName, data in pairs(self.userBattleStatus) do
		if data.allyNumber and data.aiLib then
			if chickenName and string.find(data.aiLib, "Chicken") then
				-- Override chicken AI if difficulty modoption is present
				ais[aiCount] = {
					Name = chickenName,
					Team = teamCount,
					IsFromDemo = 0,
					ShortName = chickenName,
					Host = 0,
				}
				chickenAdded = true
			else
				ais[aiCount] = {
					Name = userName,
					Team = teamCount,
					IsFromDemo = 0,
					ShortName = data.aiLib,
					Version = data.aiVersion,
					Host = 0,
				}
			end
			aiCount = aiCount + 1

			if not data.IsSpectator then
				teams[teamCount] = {
					TeamLeader = 0,
					AllyTeam = data.allyNumber,
					rgbcolor = '0.99609375 0.546875 0',
				}
				maxAllyTeamID = math.max(maxAllyTeamID, data.allyNumber)
				teamCount = teamCount + 1
			end
		end
	end

	-- Add chicken from the modoption if no chicken is present
	if chickenName and not chickenAdded then
		ais[aiCount] = {
			Name = chickenName,
			Team = teamCount,
			IsFromDemo = 0,
			ShortName = chickenName,
			Host = 0,
		}
		aiCount = aiCount + 1

		teams[teamCount] = {
			TeamLeader = 0,
			AllyTeam = maxAllyTeamID + 1,
			rgbcolor = '0.99609375 0.546875 0',
		}
		maxAllyTeamID = maxAllyTeamID + 1
		teamCount = teamCount + 1
	end

	-- Add allyTeams
	for i, teamData in pairs(teams) do
		if not allyTeams[teamData.AllyTeam] then
			allyTeams[teamData.AllyTeam] = {
				numallies = 0,
			}
		end
	end

	-- This kind of thing would prevent holes in allyTeams
	--local allyTeamMap = {}
	--for i, teamData in pairs(teams) do
	--	if not allyTeamMap[teamData.AllyTeam] then
	--		allyTeamMap[teamData.AllyTeam] = allyTeamCount
	--		allyTeams[allyTeamCount] = {
	--			numallies = 0,
	--		}
	--		allyTeamCount = allyTeamCount + 1
	--	end
	--	teamData.AllyTeam = allyTeamMap[teamData.AllyTeam]
	--end

	-- FIXME: I dislike treating rapid tags like this.
	-- We shouldn't give special treatment for rapid tags, and just use them interchangabily with normal archives.
	-- So we could just pass "rapid://tag:version" as gameName, while "tag:version" should be invalid.
	-- The engine treats rapid dependencies just like normal archives and I see no reason we do otherwise.
	if string.find(gameName, ":") and not string.find(gameName, "rapid://") then
		gameName = "rapid://" .. gameName
	end

	local script = {
		gametype = gameName,
		hostip = '127.0.0.1',
		hostport = hostPort or 0,
		ishost = 1,
		mapname = mapName,
		myplayername = playerName,
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 2,
		modoptions = self.modoptions,
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

	-- local scriptFileName = "scriptFile.txt"
	-- local scriptFile = io.open(scriptFileName, "w")
	local scriptTxt = self:MakeScriptTXT(script)
	--Spring.Echo(scriptTxt)
	Spring.Reload(scriptTxt)
	-- scriptFile:write(scriptTxt)
	-- scriptFile:close()
	-- if self.useSpringRestart then
		-- Spring.Restart(scriptFileName, "")
	-- else
		-- Spring.Start(scriptFileName, "")
	-- end
end

function InterfaceSkirmish:StartReplay(replayFilename)
	local scriptTxt =
[[
[GAME]
{
	DemoFile=__FILE__;
}
]]

	scriptTxt = scriptTxt:gsub("__FILE__", replayFilename)
	self:_CallListeners("OnBattleAboutToStart")

	Spring.Echo("starting game", scriptTxt)
	Spring.Reload(scriptTxt)
	return false
end

function InterfaceSkirmish:StartGameFromString(scriptString)
	self:_CallListeners("OnBattleAboutToStart")
	Spring.Reload(scriptString)
	return false
end

function InterfaceSkirmish:StartGameFromFile(scriptFileName)
	self:_CallListeners("OnBattleAboutToStart")
	if self.useSpringRestart then
		Spring.Restart(scriptFileName, "")
	else
		Spring.Start(scriptFileName, "")
	end
	return false
end

-- TODO: Needs clean implementation in lobby.lua
function InterfaceSkirmish:StartBattle(extraFriends, friendsReplaceAI, hostPort)
	local battle = self:GetBattle(self:GetMyBattleID())
	if not battle.gameName then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Missing battle.gameName. Game cannot start")
		return self
	end
	if not battle.mapName then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Missing battle.mapName. Game cannot start")
		return self
	end

	self:_CallListeners("OnBattleAboutToStart")
	self:_OnSaidBattleEx("Battle", "about to start", battle.gameName, battle.mapName, self:GetMyUserName() or "noname")
	self:_StartScript(battle.gameName, battle.mapName, self:GetMyUserName() or "noname", extraFriends, friendsReplaceAI, hostPort)
	return self
end

function InterfaceSkirmish:SelectMap(mapName)
	self:_OnUpdateBattleInfo(self:GetMyBattleID(), {
		mapName = mapName,
	})
end

-- Skirmish only
function InterfaceSkirmish:SetBattleState(myUserName, gameName, mapName, title)
	local myBattleID = 1

	-- Clear all data when a new battle is created
	self:_Clean()

	self.battleAis = {}
	self.userBattleStatus = {}

	self:_OnAddUser(myUserName)
	self.myUserName = myUserName
	--(battleID, type, natType, founder, ip, port, maxPlayers, passworded, rank, mapHash, other, engineVersion, mapName, title, gameName, spectatorCount)
	self:_OnBattleOpened(myBattleID, {
		founder = myUserName,
		users = {},
		gameName = gameName,
		mapName = mapName,
		title = title,
	})
	self:_OnJoinBattle(myBattleID, myUserName)
	self:_OnJoinedBattle(myBattleID, myUserName)
	local modoptions = {}
	if VFS.FileExists(LUA_DIRNAME .. "configs/testingModoptions.lua") then
		modoptions = VFS.Include(LUA_DIRNAME .. "configs/testingModoptions.lua")
	end
	self:_OnSetModOptions(modoptions)

	return self
end

-------------------------------------------------
-- BEGIN Client commands
-------------------------------------------------

function InterfaceSkirmish:AddAi(aiName, aiLib, allyNumber, version)
	self:super("AddAi", aiName, aiLib, allyNumber, version)
	self:_OnAddAi(self:GetMyBattleID(), aiName, {
		aiLib = aiLib,
		allyNumber = allyNumber,
		owner = self:GetMyUserName(),
		aiVersion = version,
	})
end

function InterfaceSkirmish:SayBattle(message)
	self:super("SayBattle", message)
	self:_OnSaidBattle(self:GetMyUserName(), message)
	return self
end

function InterfaceSkirmish:SayBattleEx(message)
	self:super("SayBattleEx", message)
	self:_OnSaidBattleEx(self:GetMyUserName(), message)
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

function InterfaceSkirmish:SetModOptions(data)
	self:_OnSetModOptions(data)
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
