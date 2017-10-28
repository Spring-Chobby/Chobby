--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/radiated02.png"
	
	local planetData = {
		name = "Old Falsell",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.57,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.28,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Radiated",
			radius = "8390 km",
			primary = "Blank",
			primaryType = "K1VI",
			milRating = 1,
			text = [[In this battle you start at a large numerical and economical disadvantage. However, the high plateaus on this map will give your Spiders an edge, especially the heavy Crab riot/skirmisher.]]
		},
		tips = {
			{
				image = "unitpics/spidercrabe.png",
				text = [[The Crab curls up into a much more durable form when stationary. Do not move Crabs when they are attacked.]]
			},
			{
				image = "unitpics/terraunit.png",
				text = [[Use terraforming to build high hills for your Crabes to fire from, and to block the movement of your opponent's units.]]
			},
			{
				image = "unitpics/spidercon.png",
				text = [[The Spider factory's Weaver constructors are slow, but they have high buildpower, all-terrain movement (obviously), and a short-range radar.]]
			},
		},
		gameConfig = {
			mapName = "Aetherian Void 1.3",
			playerConfig = {
				startX = 7600,
				startZ = 3900,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryspider",
					"spidercon",
					"spidercrabe",
					"spiderassault",
					"spiderriot",
					"spideraa",
				},
				extraAbilities = {
					"terraform",
				},
				startUnits = {
					{
						name = "staticradar",
						x = 6592,
						z = 4144,
						facing = 3,
						terraformHeight = 680,
					},
 					{
						name = "spidercon",
						x = 7715,
						z = 3379,
						facing = 2,
					},
 					{
						name = "staticmex",
						x = 7816,
						z = 3048,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 7560,
						z = 2744,
						facing = 0,
					},
 					{
						name = "staticcon",
						x = 7870,
						z = 3620,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {7987, 3381}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {7962, 3406}, options = {"shift"}},
						},
					},
					{
						name = "turretaalaser",
						x = 6830,
						z = 4340,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 8216,
						z = 3624,
						facing = 0,
					},
 					{
						name = "spidercrabe",
						x = 7574,
						z = 3369,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 7912,
						z = 3896,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 8024,
						z = 3816,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 7736,
						z = 2952,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 8136,
						z = 3736,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 7640,
						z = 2824,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 8296,
						z = 3688,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 7640,
						z = 2680,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 7976,
						z = 3944,
						facing = 2,
					},
 					{
						name = "energysolar",
						x = 7880,
						z = 2984,
						facing = 2,
					},
 					{
						name = "factoryspider",
						x = 7880,
						z = 3384,
						facing = 3,
					},
 					{
						name = "spiderskirm",
						x = 7670,
						z = 3284,
						facing = 2,
					},
 					{
						name = "spiderskirm",
						x = 7457,
						z = 3279,
						facing = 2,
					},
 					{
						name = "spiderassault",
						x = 7484,
						z = 3452,
						facing = 3,
					},
 					{
						name = "spiderassault",
						x = 7674,
						z = 3466,
						facing = 1,
					},
 					{
						name = "spidercon",
						x = 7409,
						z = 3363,
						facing = 3,
					},
 					{
						name = "turretlaser",
						x = 7248,
						z = 3120,
						facing = 3,
					},
 					{
						name = "turretlaser",
						x = 7632,
						z = 4048,
						facing = 0,
					},
 					{
						name = "spideraa",
						x = 7597,
						z = 3509,
						facing = 3,
					},
 					{
						name = "spideraa",
						x = 7562,
						z = 3249,
						facing = 2,
					},
				}
			},
			aiConfig = {
				{
					startX = 2300,
					startZ = 6900,
					humanName = "Geode Hunters",
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticcon",
						"staticradar",
						"staticmex",
						"energysolar",
						"energywind",
						"turretmissile",
						"turretlaser",
						"turretaalaser",
						"turretaaclose",
						"turretriot",
						--"turretemp",
						--"factoryveh",
						"vehcon",
						"vehraid",
						"vehriot",
						"vehassault",
						"vehsupport",
						"veharty",
						"vehaa",
						--"factorygunship",
						"gunshipcon",
						"gunshipraid",
						"gunshipbomb",
						"gunshipemp",
						"gunshipskirm",
						"gunshipaa",
						"factoryamph", --leaving this in
						"amphcon",
						"amphraid",
						"amphriot",
						"amphimpulse",
						"amphfloater",
						"amphaa",
					},
					difficultyDependantUnlocks = {
						[2] = {"vehheavyarty"},
						[3] = {"gunshipassault","vehheavyarty"},
						[4] = {"gunshipassault","vehheavyarty","gunshipheavyskirm","gunshipheavytrans"}, --maybe someday circuit will learn to crabenap? lol
					},
					commanderLevel = 5,
					commander = {
						name = "Yarral",
						chassis = "engineer",
						decorations = {
						  "skin_support_zebra",
						},
						modules = { 
							"commweapon_missilelauncher",
							"module_ablative_armor",
							"module_ablative_armor",
							"module_high_power_servos",
							"module_high_power_servos",
							"module_battle_drone",
							"module_battle_drone",
							"module_adv_nano",
							"module_adv_nano",
							"module_adv_nano",
							"commweapon_personal_shield",
						}
					},
					startUnits = {
						{
							name = "droneheavyslow",
							x = 2459,
							z = 6915,
							facing = 1,
						},
 						{
							name = "droneheavyslow",
							x = 2469,
							z = 6908,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 2104,
							z = 6600,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 2664,
							z = 7528,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 2520,
							z = 7336,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 2040,
							z = 6712,
							facing = 1,
						},
 						{
							name = "factoryveh",
							x = 2600,
							z = 6824,
							facing = 1,
						},
 						{
							name = "staticcon",
							x = 2472,
							z = 6824,
							facing = 1,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {2472, 6824}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {2497, 6799}, options = {"shift"}},
							},
						},
 						{
							name = "staticmex",
							x = 6504,
							z = 7880,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 6760,
							z = 7864,
							facing = 0,
						},
 						{
							name = "factorygunship",
							x = 6648,
							z = 7608,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 2552,
							z = 7448,
							facing = 2,
						},
 						{
							name = "factoryamph",
							x = 3480,
							z = 2664,
							facing = 1,
						},
 						{
							name = "staticmex",
							x = 3432,
							z = 2408,
							facing = 1,
						},
 						{
							name = "staticmex",
							x = 3704,
							z = 2424,
							facing = 1,
						},
 						{
							name = "turretemp",
							x = 3968,
							z = 2576,
							facing = 1,
							difficultyAtLeast = 4,
						},
 						{
							name = "turretaalaser",
							x = 3432,
							z = 2920,
							facing = 1,
						},
 						{
							name = "turretemp",
							x = 3696,
							z = 3024,
							facing = 1,
							difficultyAtLeast = 3,
						},
 						{
							name = "turretlaser",
							x = 3768,
							z = 2776,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6552,
							z = 7928,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6648,
							z = 7896,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3512,
							z = 2392,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6744,
							z = 7928,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3624,
							z = 2408,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6472,
							z = 7944,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3352,
							z = 2376,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6840,
							z = 7912,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3448,
							z = 2312,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6568,
							z = 7832,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3560,
							z = 2328,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 6696,
							z = 7832,
							facing = 1,
						},
 						{
							name = "energywind",
							x = 3688,
							z = 2328,
							facing = 1,
						},
 						{
							name = "turretaaclose",
							x = 6824,
							z = 7672,
							facing = 0,
						},
 						{
							name = "energywind",
							x = 3768,
							z = 2376,
							facing = 1,
						},
 						{
							name = "turretaaclose",
							x = 6472,
							z = 7704,
							facing = 0,
						},
 						{
							name = "turretriot",
							x = 6792,
							z = 7272,
							facing = 2,
						},
 						{
							name = "turretriot",
							x = 6472,
							z = 7464,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 6288,
							z = 7680,
							facing = 3,
						},
 						{
							name = "turretmissile",
							x = 6576,
							z = 7232,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 7008,
							z = 7520,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 2744,
							z = 7512,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 2248,
							z = 6392,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 2152,
							z = 6472,
							facing = 2,
						},
 						{
							name = "amphfloater",
							x = 3595,
							z = 2800,
							facing = 3,
						},
 						{
							name = "amphriot",
							x = 3425,
							z = 2804,
							facing = 3,
						},
 						{
							name = "amphimpulse",
							x = 3516,
							z = 2796,
							facing = 3,
						},
 						{
							name = "vehsupport",
							x = 2883,
							z = 6837,
							facing = 1,
						},
 						{
							name = "vehriot",
							x = 2840,
							z = 7121,
							facing = 0,
						},
 						{
							name = "vehassault",
							x = 2858,
							z = 7043,
							facing = 0,
						},
 						{
							name = "vehcon",
							x = 2739,
							z = 6972,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 3152,
							z = 7248,
							facing = 1,
						},
 						{
							name = "turretlaser",
							x = 3152,
							z = 6912,
							facing = 1,
						},
 						{
							name = "turretlaser",
							x = 2368,
							z = 6224,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 2768,
							z = 6368,
							facing = 2,
						},
 						{
							name = "turretaalaser",
							x = 2184,
							z = 6824,
							facing = 2,
						},
 						{
							name = "turretaalaser",
							x = 2376,
							z = 7144,
							facing = 2,
						},
 						{
							name = "staticradar",
							x = 3696,
							z = 5984,
							facing = 0,
						},
 						{
							name = "staticradar",
							x = 3648,
							z = 3072,
							facing = 0,
						},
 						{
							name = "staticradar",
							x = 6656,
							z = 7216,
							facing = 0,
						},
 						{
							name = "gunshipskirm",
							x = 5078,
							z = 7519,
							facing = 1,
						},
 						{
							name = "gunshipraid",
							x = 5155,
							z = 7540,
							facing = 1,
						},
 						{
							name = "amphraid",
							x = 3328,
							z = 2794,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "amphraid",
							x = 3313,
							z = 2493,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "amphraid",
							x = 3311,
							z = 2652,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "amphraid",
							x = 3314,
							z = 2721,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "amphraid",
							x = 3304,
							z = 2567,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "vehraid",
							x = 2835,
							z = 5374,
							facing = 2,
							difficultyAtLeast = 3,
						},
 						{
							name = "vehraid",
							x = 2867,
							z = 5523,
							facing = 2,
							difficultyAtLeast = 3,
						},
 						{
							name = "vehassault",
							x = 2848,
							z = 5442,
							facing = 2,
							difficultyAtLeast = 3,
						},
 						{
							name = "vehassault",
							x = 2854,
							z = 5599,
							facing = 2,
							difficultyAtLeast = 3,
						},
 						{
							name = "gunshipheavyskirm",
							x = 6656,
							z = 8806,
							facing = 2,
							difficultyAtLeast = 4,
						},
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { 
				},
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"factoryamph",
						"factoryveh",
						"factorygunship",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy all enemy factories",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Own ten Crabs
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"spidercrabe",
					},
					image = planetUtilities.ICON_DIR .. "spidercrabe.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 10 Crabs",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Make the enemy lose a factory by 12:00
					onlyCountRemovedUnits = true,
					satisfyByTime = 720,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 1,
					enemyUnitTypes = {
						"factoryamph",
						"factoryveh",
						"factorygunship",
					},
					image = planetUtilities.ICON_DIR .. "factoryveh.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy an enemy factory before 12:00",
					experience = planetUtilities.BONUS_EXP,
				},
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"factoryspider",
				"spidercon",
				"spidercrabe",
				"spideraa",
			},
			modules = {
				"module_adv_nano_LIMIT_G_1",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
