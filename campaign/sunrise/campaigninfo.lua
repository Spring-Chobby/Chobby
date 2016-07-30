return {
	id = "ZK_sunrise",
	name = "Sunrise",
	author = "KingRaptor",
	length = "Long",
	difficulty = "Medium",
	order = 1,
	description = [[The official campaign for Zero-K.
	
	Even after the collapse of the galaxy, the flames of war still blaze. Old causes, old plots linger. Now the Imperial auxiliary Ada Caedmon, flung into the future in the aftermath of her final battle, sets out to reclaim her past.]],
	startFunction = function()
		WG.CampaignHandler.SetVNStory("Sunrise")
		WG.CampaignHandler.SetNextMissionScript("prologue1_intro")
		WG.CampaignHandler.SetChapterTitle("Chapter 1")
		--WG.VisualNovel.LoadStory("Sunrise")
		WG.VisualNovel.StartScript("prologue1_intro")
	end
}