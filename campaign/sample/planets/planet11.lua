--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Blob",
		startingPlanet = false,
		mapDisplay = {
			x = 0.24,
			y = 0.19,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "4.1 km",
			primary = "None",
			primaryType = "N/A",
			milRating = 1,
			text = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
			Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
			Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
			Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Apophis v2_2",
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
					aiLib = "Circuit_difficulty_autofill",
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
					aiLib = "Circuit_difficulty_autofill",
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
					aiLib = "Circuit_difficulty_autofill",
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
			units = {
				"cafus",
			},
			modules = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
