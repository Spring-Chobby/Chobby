return {
	{
		name = "quick_start", 
		control = Control:New {},
	},
	{
		name = "campaign", 
		control = WG.CampaignHandler.GetWindow(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
}
