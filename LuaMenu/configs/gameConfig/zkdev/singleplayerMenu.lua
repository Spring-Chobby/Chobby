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
		control = WG.LoadGameWindow.GetControl(),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
	--{
	--	name = "quick_start", 
	--	control = Control:New {},
	--},
	{
		name = "campaign",
		submenuData = {
			submenuControl = Window:New {x = 0, y = 0, right = 0, bottom = 0, resizable = false, draggable = false,},
			tabs = {
				{
					name = "technology", 
					control = Control:New {},
				},
				{
					name = "options", 
					control = Control:New {},
				},
				{
					name = "codex", 
					control = Control:New {},
				},
				{
					name = "bla", 
					control = Control:New {},
				},
			},
		},
	},
}
