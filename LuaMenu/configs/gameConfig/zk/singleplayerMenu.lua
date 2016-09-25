
-- Only show reasonably complete things in ZK mode
if WG.Chobby.Configuration.singleplayer_mode == 2 then
	return {
		{
			name = "skirmish", 
			control = WG.BattleRoomWindow.GetSingleplayerControl(),
			entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
		},
	}
end

-- Show everything in ZK Dev mode.
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