local skirmishSetupData = {
	pages = {
		{
			humanName = "Select Game Type",
			name = "gameType",
			options = {
				"1v1",
				"2v2",
				"3v3",
				"Survival",
				"Suffer",
--				"KOTH",
			},
		},
		{
			humanName = "Select Map",
			name = "map",
			minimap = true,
			options = {
				"Barren 2",
				"Onyx Cauldron 1.9",
				"ArcticPlainsV2.1",
				"Ravaged_v2",
				"Badlands 2.1",
				"Iceland_v1",
				"Mescaline_V2",
				"Wanderlust v03",
			},
		},
	},
}

local aiNames = {
	"Killer",
	"Seeker",
	"Undertaker",
	"Purger",
	"Alpha",
	"Beta",
	"Maneater",
	"GammaRay",
	"Omega",
	"Snake",
	"Your Mom",
	"Evil666",
	"Goliath",
	"Vega",
	"Blade",
	"Bunny",
	"Testament",
	"Hellgate",
	"Deadmoon",
	"Deadmeat",
	"Lil'Sister",
	"STFU&Play",
}

function skirmishSetupData.ApplyFunction(battleLobby, pageChoices)
	local gameType = pageChoices.gameType or 1
	local map = pageChoices.map or 1

	local Configuration = WG.Chobby.Configuration
	local pageConfig = skirmishSetupData.pages
	battleLobby:SelectMap(pageConfig[2].options[map])

	battleLobby:SetBattleStatus({
		allyNumber = 0,
		isSpectator = false,
	})

	-- Chickens
	if gameType == 4 then
		battleLobby:AddAi("Zombie Survival: Easy", "Zombie Survival: Easy", 1)
		return
	elseif gameType == 5 then
		battleLobby:AddAi("Zombie Survival: Hard", "Zombie Survival: Hard", 1)
		return
	end

	-- KOTH
--[[	if gameType == 6 then
		local currentModoptions = battleLobby:GetMyBattleModoptions() or {}
		localModoptions = {}
		for key,_ in pairs(currentModoptions) do
			if modoptionDefaults[key] then
				Spring.Echo(modoptionDefaults[key])
				if (modoptionDefaults[key] == "scoremode") then
					localModoptions[key] = "countdown"
				else
					localModoptions[key] = modoptionDefaults[key]
				end
			end
		end
		battleLobby:SetModOptions(localModoptions)
	end]]

	local aiName = "Skirmish AI"

	-- AI game
	local aiNumber = 1
	local allies = gameType - 1 -- needs cahnge
	for i = 1, allies do
		battleLobby:AddAi(aiNames[math.random(#aiNames)] .. " (" .. aiNumber .. ")", aiName, 0, Configuration.gameConfig.aiVersion)
		aiNumber = aiNumber + 1
	end

	local enemies = gameType -- needs cahnge
	for i = 1, enemies do
		battleLobby:AddAi(aiNames[math.random(#aiNames)] .. " (" .. aiNumber .. ")", aiName, 1, Configuration.gameConfig.aiVersion)
		aiNumber = aiNumber + 1
	end
end

return skirmishSetupData
