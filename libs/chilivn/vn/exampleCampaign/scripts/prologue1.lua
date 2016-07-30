local scripts = {
	prologue1_intro = {
		--{"AddBackground", {file = "bg/rainbowbridge.jpg", animation = {startColor = {0,0,0,1}, endColor = {1,1,1,1}, time = 3}}},
		{"AddText", {textID = "prologue1_intro1", text = "This is placeholder text. Normally the intro (or first mission) would go here."}},
		{"AddText", {textID = "prologue1_intro2", text = "After this text is done, a mission will be launched."}},
		--{"AddText", {textID = "prologue1_intro3", text = "Well it should be, but we can't do that easily right now, so it'll just send you back to the intermission screen for now."}},
		{"AddText", {textID = "prologue1_intro3", text = "Skip the next mission?", wait = false}},
		{"ChoiceDialog", {
			{text = "Yes", action = function() scriptFunctions.JumpScript("prologue1_outro_win") end },
			{text = "No", action = function() scriptFunctions.JumpScript("prologue1_mission") end },
		}},
	},
	prologue1_mission = {
		{"CustomAction", function() WG.MissionLauncher.LaunchMission("scripts/testmission.txt",
			function(results)
				
				if (results.result == "victory") then
					WG.VisualNovel.StartScript("prologue1_outro_win")
				else
					WG.VisualNovel.StartScript("prologue1_outro_lose")
				end
			end)
		end},
		{"Exit"}
	},
	prologue1_outro_win = {
		{"CustomAction", function() WG.CampaignHandler.SetNextMissionScript("prologue2_intro") end},
		{"CustomAction", function() WG.CampaignHandler.SetChapterTitle("Chapter 2") end},
		{"AddText", {textID = "prologue1_outro1", text = "You've won the first mission. Congratulations!"}},
		{"Exit"}
	},
	prologue1_outro_lose = {
		{"CustomAction", function() WG.CampaignHandler.SetNextMissionScript("prologue2_intro") end},
		{"CustomAction", function() WG.CampaignHandler.SetChapterTitle("Chapter 2") end},
		{"AddText", {textID = "prologue1_outro1", text = "You've failed to win the first mission. Oh well..."}},
		{"Exit"}
	},
}

return scripts