local FEEDBACK_LINK = "http://zero-k.info/Forum/Thread/24469"

local planetWhitelist = {
	-- Tutorial Cloaky
	[69] = true,
	[1] = true,
	[2] = true,
	[3] = true,
	[5] = true,
	-- Adv. Cloaky
	[4] = true,
	[6] = true,
	[7] = true,
	[8] = true,
	[20] = true,
	-- Shield
	[13] = true,
	[14] = true,
	[15] = true,
	[16] = true,
	[17] = true,
	[19] = true,
	-- Rover
	[9] = true,
	[10] = true,
	[11] = true,
	[12] = true,
	[43] = true,
	[52] = true,
	-- Amph and Hover
	[22] = true,
	[23] = true,
	[24] = true,
	[25] = true,
	[26] = true,
	[27] = true,
	[28] = true,
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
			submenuControl = WG.CampaignHandler.GetControl(true, planetWhitelist, FEEDBACK_LINK),
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

