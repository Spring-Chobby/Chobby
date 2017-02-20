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
			},
		},
		{
			humanName = "Select Map",
			name = "map",
			minimap = true,
			options = {
				"TitanDuel",
				"Onyx Cauldron 1.7",
				"Fairyland v1.0",
				"Calamity 1.1",
			},
		},
		{
			humanName = "Select Difficulty",
			name = "difficulty",
			options = {
				"Very Easy",
				"Easy",
				"Medium",
				"Hard",
			},
		},
	},
}

local chickenDifficulty = {
	"Chicken: Very Easy",
	"Chicken: Easy",
	"Chicken: Normal",
	"Chicken: Hard",
}

function skirmishSetupData.ApplyFunction(battleLobby, pageChoices)
	local pageConfig = skirmishSetupData.pages
	battleLobby:SelectMap(pageConfig[2].options[pageChoices.map])
	
	battleLobby:SetBattleStatus({
		allyNumber = 0,
		isSpectator = false,
	})
	
	-- Chickens
	if pageChoices.gameType == 4 then
		battleLobby:AddAi(chickenDifficulty[pageChoices.difficulty], chickenDifficulty[pageChoices.difficulty], 1)
		return
	end
	
	-- AI game
	local aiNumber = 1
	local allies = pageChoices.gameType - 1
	for i = 1, allies do
		battleLobby:AddAi("CAI (" .. aiNumber .. ")", "CAI", 0)
		aiNumber = aiNumber + 1
	end
	
	local enemies = pageChoices.gameType
	for i = 1, enemies do
		battleLobby:AddAi("CAI (" .. aiNumber .. ")", "CAI", 1)
		aiNumber = aiNumber + 1
	end
end

return {
	{
		name = "missions", 
		control = WG.MissionHandler.GetControl(),
	},
	{
		name = "campaign",
		submenuData = {
			submenuControl = WG.CampaignHandler.GetControl(),
			tabs = {
				{
					name = "technology", 
					control = Control:New {},
				},
				{
					name = "codex", 
					control = WG.CodexHandler.GetControl(),
				},
				{
					name = "options", 
					control = Control:New {},
				},
			},
		},
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(skirmishSetupData),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	{
		name = "load",
		control = WG.LoadGameWindow.GetControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	{
		name = "commanders",
		control = WG.CommConfig.GetControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	--{
	--	name = "quick_start", 
	--	control = Control:New {},
	--},
}
