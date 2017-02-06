--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Planet Battle Handler",
		desc      = "Handles creating the battle for planet invasion as well as reporting results.",
		author    = "GoogleFrog",
		date      = "6 February 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function MaybeDownloadArchive(archiveName, archiveType)
	if not VFS.HasArchive(archiveName) then
		VFS.DownloadArchive(archiveName, archiveType)
	end
end

local function MaybeDownloadGame(gameName)
	MaybeDownloadArchive(gameName, "game")
end

local function MaybeDownloadMap(mapName)
	MaybeDownloadArchive(mapName, "map")
end

local function StartBattle(gameName, gameConfig, playerUnlocks)
	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local ais = {}
	local aiCount = 0
	
	local localLobby = WG.LibLobby.localLobby
	local Configuration = WG.Chobby.Configuration
	local playerName = Configuration.userName or Configuration.suggestedNameFromSteam or "Player"
	local bitExtension = (Configuration:GetIsRunning64Bit() and "64") or "32"

	-- Add the player, this is to make the player team 0.
	local playerCount = 1
	local players = {
		[0] = {
			Name = playerName,
			Team = teamCount,
			IsFromDemo = 0,
			rank = 0,
		},
	}
	
	teams[teamCount] = {
		TeamLeader = 0,
		AllyTeam = gameConfig.playerConfig.allyTeam,
		rgbcolor = '0 0 0',
	}
	teamCount = teamCount + 1
	
	-- Add the AIs
	for i = 1, #gameConfig.aiConfig do
		local aiData = gameConfig.aiConfig[i]
		local shortName = aiData.aiLib
		if aiData.bitDependant then
			shortName = shortName .. bitExtension
		end
		
		ais[aiCount] = {
			Name = aiData.humanName,
			Team = teamCount,
			IsFromDemo = 0,
			ShortName = shortName,
			Host = 0,
		}
		aiCount = aiCount + 1
		
		teams[teamCount] = {
			TeamLeader = 0,
			AllyTeam = aiData.allyTeam,
			rgbcolor = '0 0 0',
		}
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
	
	local script = {
		gametype = gameName,
		hostip = '127.0.0.1',
		hostport = 0,
		ishost = 1,
		mapname = gameConfig.mapName,
		myplayername = playerName,
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 2,
		modoptions = {},
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

	local scriptString = localLobby:MakeScriptTXT(script)
	localLobby:StartGameFromString(scriptString)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions
local PlanetBattleHandler = {}

function PlanetBattleHandler.StartBattle(planetData, playerUnlocks)
	local Configuration = WG.Chobby.Configuration
	local gameConfig = planetData.gameConfig

	if gameConfig.missionStartscript then
		Spring.Echo("PlanetBattleHandler implement missionStartscript.")
		return false
	end
	
	local gameName = Configuration:GetDefaultGameName()
	local haveGame = VFS.HasArchive(gameName)
	if not haveGame then
		WG.Chobby.InformationPopup("You do not have the game file required. It will now be downloaded.")
		MaybeDownloadGame(gameName)
		return
	end
	
	local haveMap = VFS.HasArchive(gameConfig.mapName)
	if not haveMap then
		WG.Chobby.InformationPopup("You do not have the map file required. It will now be downloaded.")
		MaybeDownloadMap(gameConfig.map)
		return
	end
	
	local function StartBattleFunc()
		if StartBattle(gameName, gameConfig, playerUnlocks) then
			Spring.Echo("Start battle success!")
		end
	end
	
	if Spring.GetGameName() == "" then
		StartBattleFunc()
	else
		WG.Chobby.ConfirmationPopup(StartBattleFunc, "Are you sure you want to leave your current game to attack this planet?", nil, 315, 200)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	WG.PlanetBattleHandler = PlanetBattleHandler
end
