local scripts = {
	prologue2_intro = {
		--{"AddBackground", {file = "bg/rainbowbridge.jpg", animation = {startColor = {0,0,0,1}, endColor = {1,1,1,1}, time = 3}}},
		{"AddText", {textID = "prologue2_intro1", text = "This would be the intro text for the second mission."}},
		{"AddText", {textID = "prologue2_intro2", text = "Nothing to see here, go away!"}},
		{"Exit"}
	},
	prologue2_outro = {
		
	},
}

return scripts