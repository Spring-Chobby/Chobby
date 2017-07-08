local menuItems = {
	{
		name = "tutorials", 
		control = WG.MissionHandler.GetControl(),
	},
	{
		name = "campaign",
		submenuData = {
			submenuControl = WG.CampaignHandler.GetControl(),
			tabs = {
				{
					name = "technology", 
					control = WG.TechnologyHandler.GetControl(),
				},
				{
					name = "codex", 
					control = WG.CodexHandler.GetControl(),
				},
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

if VFS.HasArchive("SpringBoard ZK $VERSION") then
	menuItems[#menuItems + 1] = {
		name = "editor",
		control = WG.SpringBoardWindow.GetControl(),
	}
end

return menuItems
