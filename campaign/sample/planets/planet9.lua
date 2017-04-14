
-- TODO: Remove
local planetImages = {
	LUA_DIRNAME .. "images/planets/arid01.png",
	LUA_DIRNAME .. "images/planets/barren01.png",
	LUA_DIRNAME .. "images/planets/barren02.png",
	LUA_DIRNAME .. "images/planets/barren03.png",
	LUA_DIRNAME .. "images/planets/desert01.png",
	LUA_DIRNAME .. "images/planets/desert02.png",
	LUA_DIRNAME .. "images/planets/desert03.png",
	LUA_DIRNAME .. "images/planets/inferno01.png",
	LUA_DIRNAME .. "images/planets/inferno02.png",
	LUA_DIRNAME .. "images/planets/inferno03.png",
	LUA_DIRNAME .. "images/planets/inferno04.png",
	LUA_DIRNAME .. "images/planets/ocean01.png",
	LUA_DIRNAME .. "images/planets/ocean02.png",
	LUA_DIRNAME .. "images/planets/ocean03.png",
	LUA_DIRNAME .. "images/planets/radiated01.png",
	LUA_DIRNAME .. "images/planets/radiated02.png",
	LUA_DIRNAME .. "images/planets/radiated03.png",
	LUA_DIRNAME .. "images/planets/swamp01.png",
	LUA_DIRNAME .. "images/planets/swamp02.png",
	LUA_DIRNAME .. "images/planets/swamp03.png",
	LUA_DIRNAME .. "images/planets/terran01.png",
	LUA_DIRNAME .. "images/planets/terran02.png",
	LUA_DIRNAME .. "images/planets/terran03.png",
	LUA_DIRNAME .. "images/planets/terran03_damaged.png",
	LUA_DIRNAME .. "images/planets/terran04.png",
	LUA_DIRNAME .. "images/planets/tundra01.png",
	LUA_DIRNAME .. "images/planets/tundra02.png",
	LUA_DIRNAME .. "images/planets/tundra03.png",
}

local backgroundImages = {
	LUA_DIRNAME .. "images/starbackgrounds/1.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/2.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/3.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/4.jpg",
}

local PLANET_SIZE_MAP = 48
local PLANET_SIZE_INFO = 240

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local image = planetImages[math.floor(math.random()*#planetImages) + 1]

local planetData = {
	name = "Pong",
	startingPlanet = (planetID == 3),
	mapDisplay = {
		x = 0.27,
		y = 0.85,
		image = image,
		size = PLANET_SIZE_MAP,
	},
	infoDisplay = {
		image = image,
		size = PLANET_SIZE_INFO,
		backgroundImage = backgroundImages[math.floor(math.random()*#backgroundImages) + 1],
		terrainType = "Terran",
		radius = "6700 km",
		primary = "Tau Ceti",
		primaryType = "G8",
		milRating = 1,
		text = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
		Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
		Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
		Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
	},
	gameConfig = {
		missionStartscript = false,
		mapName = "TitanDuel",
		playerConfig = {
			startX = 400,
			startZ = 400,
			allyTeam = 0,
			useUnlocks = true,
			facplop = true,
			extraUnlocks = {
				"factoryshield",
				"shieldfelon",
				"armdeva",
				"armfus",
				"corllt",
			},
			startUnits = {
				{
					name = "corllt",
					x = 1000,
					z = 300,
					facing = 2,
				},
				{
					name = "armfus",
					x = 1000,
					z = 500,
					facing = 1,
				},
				{
					name = "armfus",
					x = 1200,
					z = 500,
					facing = 0,
				},
				{
					name = "armnanotc",
					x = 1000,
					z = 400,
					facing = 2,
				},
				{
					name = "armwar",
					x = 850,
					z = 850,
					facing = 0,
				},
				{
					name = "armwar",
					x = 900,
					z = 850,
					facing = 0,
				},
				{
					name = "armwar",
					x = 850,
					z = 900,
					facing = 0,
				},
				{
					name = "armwar",
					x = 900,
					z = 900,
					facing = 0,
				},
				{
					name = "corsktl",
					x = 4210,
					z = 4670,
					facing = 0,
				},
				{
					name = "corsktl",
					x = 300,
					z = 300,
					facing = 0,
				},
			}
		},
		aiConfig = {
			{
				startX = 200,
				startZ = 200,
				aiLib = "CircuitAIHard",
				humanName = "Ally",
				bitDependant = true,
				facplop = false,
				allyTeam = 0,
				unlocks = {
					"factorycloak",
					"corllt",
					"cormex",
					"armsolar",
					"armpw",
					"armrock",
					"armwar",
					"armham",
				},
				commanderLevel = 5,
				commander = {
					name = "Verminyan",
					chassis = "engineer",
					decorations = {},
					modules = {
					  {
						"commweapon_shotgun",
						"module_radarnet"
					  },
					  {
						"module_adv_nano",
						"commweapon_personal_shield"
					  },
					  {
						"",
						"",
						"commweapon_shotgun"
					  },
					  {
						"",
						"",
						""
					  },
					  {
						"",
						"",
						""
					  }
					}
				}
			},
			{
				startX = 1250,
				startZ = 250,
				aiLib = "CircuitAIHard",
				humanName = "Another Ally",
				bitDependant = true,
				facplop = false,
				allyTeam = 0,
				unlocks = {
					"factorycloak",
					"corllt",
					"cormex",
					"armsolar",
					"armpw",
					"dante",
				},
				startUnits = {
					{
						name = "striderhub",
						x = 1000,
						z = 1300,
						facing = 2,
					},
					{
						name = "dante",
						x = 800,
						z = 1300,
						facing = 2,
						buildProgress = 0.4,
					},
				}
			},
			{
				startX = 3200,
				startZ = 3200,
				aiLib = "CircuitAIHard",
				humanName = "Mortal Enemy",
				bitDependant = true,
				facplop = true,
				allyTeam = 1,
				unlocks = {
					"factorycloak",
					"corllt",
					"cormex",
					"armsolar",
					"armwar",
				},
				commanderLevel = 2,
				commander = {
					name = "You dig.",
					chassis = "engineer",
					decorations = {
					  "skin_support_dark",
					  icon_overhead = { image = "UW" }
					},
					modules = {
					  {
						"commweapon_beamlaser",
						"module_radarnet"
					  },
					  {
						"module_resurrect",
						"module_adv_nano"
					  },
					  {
						"module_adv_nano",
						"module_adv_nano",
						"commweapon_multistunner"
					  },
					  {
						"module_adv_nano",
						"module_adv_nano",
						"module_adv_nano"
					  },
					  {
						"module_adv_nano",
						"module_adv_nano",
						"module_cloak_field"
					  }
					}
				},
			},
		},
	},
	completionReward = {
		units = (planetID == 3 and startingUnits) or {
			"cafus",
		},
		modules = {
		},
	}
}

return planetData