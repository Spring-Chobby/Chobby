return {
	{
		name = "quick_start", 
		control = Control:New {},
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
}