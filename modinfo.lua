-- Chobby - an in-game lobby project
-- Authors: gajop

local modinfo = {
	name            = "Chobby",
	shortName       = "IGL",
	version         = "$VERSION",
	game            = "Chobby",
	shortGame       = "IGL",
	mutator         = "Official",
	description     = "An in-game lobby",
	modtype         = "5",
	url             = "https://github.com/Spring-Chobby/Chobby",
	depend = {
		"Spring Cursors",
		"Spring content v1",
	},
	onlyLocal       = true,
	-- Note, this is the last working engine version due to:
	-- https://github.com/spring/spring/commit/7bdceb667c30ccea56362a0af7d835ef1604d813
	engine          = "103.0.1-98-ge5905db",
}

return modinfo
