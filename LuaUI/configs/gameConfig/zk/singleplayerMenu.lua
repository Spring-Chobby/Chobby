return {
	{
		name = "quick_start", 
		control = Control:New {},
	},
	{
		name = "custom", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
}