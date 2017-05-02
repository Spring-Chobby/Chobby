--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Beth XVII",
		startingPlanet = false,
		mapDisplay = {
			x = 0.04,
			y = 0.73,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "5950 km",
			primary = "Beth",
			primaryType = "G4",
			milRating = 1,
			text = [[Glaives served you well in the previous battle, but on this planet your opponent will construct Warrior riot bots and Stardust turrets to counter them. Retaliate with Rockos and your own Warriors to achieve victory.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Battle for Planet XVII-v01",
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
				"corrl",
				"corllt",
				"factoryjump",
				"armrock",
				"armkam",
				"tawf114",
				"nsaclash",
				"armestor",
				"shipscout",
				"subraider",
				"gunshipaa",
				"shipcon",
				"amphraider2",
				"amphraider3",
				"amphassault",
				"amphaa",
			},
			modules = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
