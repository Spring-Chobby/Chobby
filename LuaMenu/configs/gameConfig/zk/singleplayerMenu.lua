local planetWhitelist = {
	[69] = true,
	[1] = true,
	[2] = true,
	[3] = true,
	[4] = true,
	[5] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	[20] = true,
}

return {
	{
		name = "tutorials", 
		control = WG.MissionHandler.GetControl(),
	},
	{
		name = "campaign",
		entryCheck = WG.CampaignSaveWindow.PromptInitialSaveName,
		entryCheckBootMode = true,
		submenuData = {
			submenuControl = WG.CampaignHandler.GetControl(true, planetWhitelist, "http://zero-k.info/Forum/Thread/24429"),
			tabs = {
				{
					name = "technology", 
					control = WG.TechnologyHandler.GetControl(),
				},
				{
					name = "commander", 
					control = WG.CommanderHandler.GetControl(),
				},
				--{
				--	name = "codex", 
				--	control = WG.CodexHandler.GetControl(),
				--},
				{
					name = "options", 
					control = WG.CampaignOptionsWindow.GetControl(),
				},
			},
		},
	},
	{
		name = "skirmish", 
		control = WG.BattleRoomWindow.GetSingleplayerControl(VFS.Include(LUA_DIRNAME .. "configs/gameConfig/zk/singleplayerQuickSkirmish.lua")),
		entryCheck = WG.BattleRoomWindow.SetSingleplayerGame,
	},
}

