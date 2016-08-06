return {
	id = "exampleCampaign",
	name = "Example campaign",
	author = "KingRaptor",
	length = "",
	difficulty = "",
	description = "placeholder text",
	startFunction = function()
		WG.CampaignHandler.SetVNStory("exampleCampaign")
		WG.CampaignHandler.SetNextMissionScript("prologue1_intro")
		WG.CampaignHandler.SetChapterTitle("Chapter 1")
		--WG.VisualNovel.LoadStory("Sunrise")
		WG.VisualNovel.StartScript("prologue1_intro")
	end
}