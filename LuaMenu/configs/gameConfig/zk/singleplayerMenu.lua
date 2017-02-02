local skirmishSetupData = {
	pages = {
		{
			humanName = "Select Game Size",
			name = "gameSize",
			options = {
				"1v1",
				"2v2",
				"3v3",
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
				"Easy",
				"Medium",
				"Hard",
			},
		},
	},
}

function skirmishSetupData.ApplyFunction(battleLobby, pageChoices)
	local pageConfig = skirmishSetupData.pages
	battleLobby:SelectMap(pageConfig[2].options[pageChoices.map])
	
	local aiNumber = 1
	local allies = pageChoices.gameSize - 1
	for i = 1, allies do
		battleLobby:AddAi("CAI (" .. aiNumber .. ")", "CAI", 0)
		aiNumber = aiNumber + 1
	end
	
	local enemies = pageChoices.gameSize
	for i = 1, enemies do
		battleLobby:AddAi("CAI (" .. aiNumber .. ")", "CAI", 1)
		aiNumber = aiNumber + 1
	end
	
	battleLobby:SetBattleStatus({
		allyNumber = 0,
		isSpectator = false,
	})
end

return {
	{
		name = "missions", 
		control = WG.MissionHandler.GetControl(),
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(skirmishSetupData),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
}
