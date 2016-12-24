return {
	{
		name = "missions", 
		control = WG.MissionHandler.GetControl(),
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	{
		name = "load",
		control = 	WG.LoadWindow.GetWindow(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	--{
	--	name = "quick_start", 
	--	control = Control:New {},
	--},
	--{
	--	name = "campaign", 
	--	control = WG.CampaignHandler.GetWindow(),
	--	entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	--},
}
