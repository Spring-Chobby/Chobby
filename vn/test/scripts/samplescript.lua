local scripts = {
	intro = {
		{"AddBackground", {file = "bg/rainbowbridge.jpg", animation = {startColor = {0,0,0,1}, endColor = {1,1,1,1}, time = 3}}},
		{"AddText", {speakerID = "narrator", textID = "intro1", text = "It was a dark and stormy night... well, not really..."}},
		{"AddImage", {id = "eileen", defID = "eileen_happy", x = "0.6", y = "1", animation = {startAlpha = 0, endAlpha = 1, time = 0.25} }},
		{"AddText", {speakerID = "eileen", textID = "intro2", text = "Hey guys, what's up?", instant = true}},
		{"PlaySound", --[["../../"]] "sounds/explosion/ex_ultra8.wav"},
		--{"CustomAction", function() Spring.Echo("lol"); Spring.SendCommands('pause 1') end},
		{"ShakeScreen", {time = 2}},
		{"Wait", 3},
		{"JumpScript", "intro2"}
	},
	intro2 = {
		--{"PlayMusic", {track = "music/Butterfly_Tea_-_The_Last_Mission.ogg", loop = true}},
		{"SetVars", {["VN"] = "visual novel", ["moveFromSideToSide"] = "move from side to side"}},
		-- test really long strings
		{"AddText", {speakerID = "eileen", textID = "intro3", name = 'Eileen the Red', text = "Many of your fathers and brothers have perished valiantly in the face of a contemptible enemy. We must never forget what the Federation has done to our people! My brother, Garma Zabi, has shown us these virtues through our own valiant sacrifice. By focusing our anger and sorrow, we are finally in a position where victory is within our grasp, and once again, our most cherished nation will flourish. Victory is the greatest tribute we can pay those who sacrifice their lives for us! Rise, our people, rise! Take your sorrow and turn it into anger! Zeon thirsts for the strength of its people! SIEG ZEON!! SIEG ZEON!! SIEG ZEON!!!"}},
		{"AddText", {textID = "intro2", text = "...", size = 24}},
		{"ModifyImage", {id = "eileen", defID = "eileen_concerned", animation = {type = "dissolve", startAlpha = 0, endAlpha = 1, time = 0.5}}},
		{"AddText", {speakerID = "eileen", textID = "intro4", text = "Wait a minute... this isn't Ren'Py..."}},
		--{"SetPortrait", nil},
		--{"Wait"},
		{"AddText", {speakerID = "eileen", textID = "intro5", text = " *sigh*", append = true, setPortrait = false}},
		{"ModifyImage", {id = "eileen", animation = {endX = "0.2", time = 1} }},
		{"ModifyImage", {id = "eileen", animation = {endX = 700, time = 1, delay = 1} }},
		--{"UnsetVars", {"moveFromSideToSide"}},
		{"AddText", {speakerID = "eileen", textID = "intro6", text = "Look, just because I can {{moveFromSideToSide}} doesn't make this an adequate {{VN}} engine!", wait = false}},
		{"AddText", {speakerID = "eileen", textID = "intro6_1", text = " Seriously...", append = true}},
		--{"RemoveImage", "eileen"},
		{"ModifyImage", {id = "eileen", animation = {endAlpha = 0.2, time = 0.5, removeTargetOnDone = true} }},
		{"ClearText"},
		--{"StopMusic"},
		{"Wait"},
		{"AddText", {textID = "intro7", text = "CHOOSE YOUR FATE:", wait = false}},
		{"ChoiceDialog", {
			{text = [[Say "lololol"]], action = function() scriptFunctions.JumpScript("intro3_1") end },
			{text = [[Say "ahahahahaha"]], action = function() scriptFunctions.JumpScript("intro3_2") end },
		}},
	},
	
	intro3_1 = {
		{"AddText", {textID = "intro8_1", text = "lololol"}},
		{"JumpScript", "introEnd"},
	},
	
	intro3_2 = {
		{"AddText", {textID = "intro8_1", text = "ahahahahaha"}},
		{"JumpScript", "introEnd"},
	},
	
	introEnd = {
		{"AddText", {speakerID = "narrator", textID = "intro_end1", text = "Before we go, let's try NVL mode."}},
		{"SetNVLMode", true},
		{"AddText", {speakerID = "narrator", textID = "intro_end2", text = "Lalalalala..."}},
		{"AddText", {speakerID = "eileen", textID = "intro_end3", text = "Okay, this is pretty good."}},
		{"AddText", {speakerID = "eileen", textID = "intro_end4", text = "What happens if we wipe the slate?"}},
		{"ClearNVL"},
		{"AddText", {speakerID = "narrator", textID = "intro_end5", text = "Wowzers!"}},
		{"AddText", {speakerID = "eileen", textID = "intro_end4", text = "Badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger badger"}},
		{"ClearNVL"},
		{"SetNVLMode", false},
		{"AddText", {speakerID = "narrator", textID = "intro_end6", text = "T-T-That's all, folks!"}},
		{"Exit"}
	}
}

return scripts