--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/radiated03.png"
	
	local planetData = {
		name = "Fel Diacia",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.57,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.61,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Igneous",
			radius = "6370 km",
			primary = "Easnor",
			primaryType = "A4IV",
			milRating = 1,
			text = [[Assist your ally from the air with Phoenix and Thunderbird bombers. Your opponents have airplane support as well; use Swifts to intercept their bombing runs and control the skies.]]
		},
		tips = {
			{
				image = "unitpics/staticrearm.png",
				text = [[After firing their payload, bombers must retreat to base and rearm. The Airplane Plant has one rearm pad. If you have a large number of bombers, build an Airpad so your bombers can get back into the fight sooner. ]]
			},
			{
				image = "unitpics/bomberdisarm.png",
				text = [[The Thunderbird can disarm a large army in a single bombing pass, if it approaches from the right direction. Use the manual fire (default hotkey D) to begin bombing immediately. Be careful not to disarm your own team's units.]]
			},
			{
				image = "unitpics/planefighter.png",
				text = [[Use Swifts to protect your own bombers from enemy fighters, or to intercept enemy bombers. Swifts have a manual fire speed boost (default hotkey D) to catch enemies or to retreat from a bad situation.]]
			},
			{
				image = "unitpics/bomberriot.png",
				text = [[The Phoenix drops napalm bombs which are very effective against lighter-weight units. It is comparatively flimsy so keep it away from enemy anti-air and fighters. Hold Ctrl when giving an area-attack command to have a group of Phoenixes attack different targets.]]
			},
		},
		gameConfig = {
			mapName = "Obsidian_1.5",
			playerConfig = {
				startX = 1630,
				startZ = 1288,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryplane",
					"planecon",
					"planefighter",
					"bomberriot",
					"bomberdisarm",
					"staticrearm",
				},
				startUnits = {
					{
						name = "staticrearm",
						x = 1096,
						z = 1384,
						facing = 1,
					},
 					{
						name = "factoryplane",
						x = 976,
						z = 1528,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 1256,
						z = 1352,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 1480,
						z = 1096,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 1320,
						z = 1288,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 1384,
						z = 1224,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 1448,
						z = 1160,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 264,
						z = 744,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 296,
						z = 824,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 184,
						z = 776,
						facing = 0,
					},
 					{
						name = "energywind",
						x = 328,
						z = 696,
						facing = 0,
					},
 					{
						name = "planecon",
						x = 1440,
						z = 1675,
						facing = 2,
					},
 					{
						name = "staticheavyradar",
						x = 1728,
						z = 1744,
						facing = 0,
						terraformHeight = 1022,
					},
 					{
						name = "bomberdisarm",
						x = 1300,
						z = 1675,
						facing = 2,
					},
 					{
						name = "turretlaser",
						x = 448,
						z = 1584,
						facing = 0,
					},
 					{
						name = "turretlaser",
						x = 1024,
						z = 1856,
						facing = 0,
					},
 					{
						name = "turretlaser",
						x = 1568,
						z = 1824,
						facing = 0,
					},
 					{
						name = "turretlaser",
						x = 2016,
						z = 1456,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 2016,
						z = 848,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 1456,
						z = 448,
						facing = 2,
					},
				}
			},
			aiConfig = {
				{
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Mollies",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 0,
					unlocks = {
						"staticcon",
						--"turretlaser",
						--"turretmissile",
						"staticradar",
						"staticmex",
						"energysolar",
						"energywind",
						"factorycloak",
						"cloakcon",
						"cloakraid",
						"cloakriot",
						"cloakassualt",
						"cloakskirm",
						"cloakarty",
						"cloakbomb",
						"factoryspider",
						"spidercon",
						"spiderscout",
						"spideremp",
						"spiderriot",
						"spiderassault",
						"spiderskirm",
					},
					commander = false,
					startUnits = {
						{
							name = "factorycloak",
							x = 3240,
							z = 2016,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 3352,
							z = 696,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 2856,
							z = 2104,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 3096,
							z = 1400,
							facing = 0,
						},
 						{
							name = "cloakcon",
							x = 2994,
							z = 2024,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 2920,
							z = 2120,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 2840,
							z = 2168,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 2792,
							z = 2088,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 2872,
							z = 2040,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 3160,
							z = 1416,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 3080,
							z = 1464,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 3032,
							z = 1384,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3112,
							z = 1336,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 3416,
							z = 712,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 3336,
							z = 760,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 3288,
							z = 680,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3368,
							z = 632,
							facing = 0,
						},
 						{
							name = "staticcon",
							x = 3144,
							z = 1960,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 3312,
							z = 624,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 3056,
							z = 1328,
							facing = 0,
						},
 						{
							name = "turretlaser",
							x = 2816,
							z = 2032,
							facing = 0,
						},
 						{
							name = "cloakcon",
							x = 3074,
							z = 2053,
							facing = 1,
						},
 						{
							name = "cloakraid",
							x = 3137,
							z = 2191,
							facing = 3,
						},
 						{
							name = "cloakraid",
							x = 3193,
							z = 2183,
							facing = 1,
						},
 						{
							name = "cloakraid",
							x = 3266,
							z = 2181,
							facing = 1,
						},
					}
				},
				{
					startX = 5600,
					startZ = 6000,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Blue Angels",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticcon",
						--"turretlaser",
						--"turretmissile",
						"staticradar",
						"staticmex",
						"energysolar",
						"energywind",
						"factoryplane",
						"planecon",
						"planefighter",
						"bomberprec",
						"bomberriot",
					},
					difficultyDependantUnlocks = {
						[3] = {"bomberdisarm"},
						[4] = {"bomberdisarm"},
						--[4] = {"planeheavyfighter","bomberdisarm"},
					},
					commanderLevel = 5,
					commander = {
						name = "Rammia",
						chassis = "recon",
						decorations = {
							"skin_recon_leopard",
						},
						modules = { 
							"commweapon_heavymachinegun",
							"commweapon_concussion",
							"module_autorepair",
							"module_autorepair",
							"module_ablative_armor",
							"module_ablative_armor",
							"module_adv_targeting",
							"module_high_power_servos",
							"module_high_power_servos",
							"module_adv_nano",
						}
					},
					startUnits = {
						{
							name = "staticmex",
							x = 7000,
							z = 4968,
							facing = 0,
							difficultyAtLeast = 2,
						},
 						{
							name = "energysolar",
							x = 6968,
							z = 4872,
							facing = 3,
							difficultyAtLeast = 2,
						},
 						{
							name = "staticmex",
							x = 5912,
							z = 4360,
							facing = 0,
							difficultyAtLeast = 3,
						},
 						{
							name = "energysolar",
							x = 5864,
							z = 4280,
							facing = 3,
							difficultyAtLeast = 3,
						},
 						{
							name = "turretmissile",
							x = 6144,
							z = 4096,
							facing = 2,
							difficultyAtLeast = 3,
						},
 						{
							name = "staticmex",
							x = 6584,
							z = 3896,
							facing = 2,
							difficultyAtLeast = 4,
						},
 						{
							name = "energysolar",
							x = 6504,
							z = 3848,
							facing = 2,
							difficultyAtLeast = 4,
						},
 						{
							name = "turretmissile",
							x = 6272,
							z = 4016,
							facing = 2,
							difficultyAtLeast = 4,
						},
						{
							name = "factoryplane",
							x = 5496,
							z = 6176,
							facing = 3,
						},
 						{
							name = "staticrearm",
							x = 5624,
							z = 6216,
							facing = 3,
						},
 						{
							name = "staticmex",
							x = 5688,
							z = 6072,
							facing = 3,
						},
 						{
							name = "staticmex",
							x = 5912,
							z = 5816,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 5752,
							z = 6008,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 5800,
							z = 5944,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 5848,
							z = 5880,
							facing = 3,
						},
 						{
							name = "staticmex",
							x = 6904,
							z = 6424,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 6840,
							z = 6392,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 6968,
							z = 6376,
							facing = 3,
						},
 						{
							name = "energywind",
							x = 6936,
							z = 6504,
							facing = 3,
						},
 						{
							name = "planecon",
							x = 5997,
							z = 4301,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 6784,
							z = 5632,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 5792,
							z = 5328,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 6304,
							z = 5360,
							facing = 2,
						},
 						{
							name = "staticheavyradar",
							x = 5488,
							z = 5392,
							facing = 2,
							terraformHeight = 1025,
						},
 						{
							name = "turretlaser",
							x = 5152,
							z = 5712,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 5120,
							z = 6256,
							facing = 3,
						},
 						{
							name = "turretlaser",
							x = 5632,
							z = 6704,
							facing = 0,
						},
 						{
							name = "turretaaclose",
							x = 5544,
							z = 5944,
							facing = 0,
						},
					}
				},
				{
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Zulcrew",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticcon",
						--"turretlaser",
						--"turretmissile",
						"staticradar",
						"staticmex",
						"energysolar",
						"energywind",
						"factoryshield",
						"shieldcon",
						"shieldraid",
						"shieldriot",
						"shieldassualt",
						"shieldskirm",
						"shieldfelon",
						"shieldbomb",
						"factoryspider",
						"spidercon",
						"spiderscout",
						"spideremp",
						"spiderriot",
						"spiderassault",
						"spiderskirm",
					},
					commander = false,
					startUnits = {
						{
							name = "factoryshield",
							x = 4544,
							z = 5224,
							facing = 2,
						},
 						{
							name = "shieldcon",
							x = 4499,
							z = 5065,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 4312,
							z = 5064,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 4376,
							z = 5080,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 4296,
							z = 5128,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 4248,
							z = 5048,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 4328,
							z = 5000,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 4072,
							z = 5768,
							facing = 2,
						},
 						{
							name = "staticmex",
							x = 3816,
							z = 6472,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 3880,
							z = 6488,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 3800,
							z = 6536,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 3752,
							z = 6456,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 3832,
							z = 6408,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 4136,
							z = 5784,
							facing = 1,
						},
 						{
							name = "energysolar",
							x = 4056,
							z = 5832,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 4008,
							z = 5752,
							facing = 3,
						},
 						{
							name = "energysolar",
							x = 4088,
							z = 5704,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 4352,
							z = 5136,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 4112,
							z = 5840,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 3856,
							z = 6544,
							facing = 2,
						},
 						{
							name = "staticcon",
							x = 4568,
							z = 5352,
							facing = 0,
							commands = {
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {4568, 5352}},
								{cmdID = planetUtilities.COMMAND.PATROL, pos = {4543, 5327}, options = {"shift"}},
							},
						},
 						{
							name = "shieldraid",
							x = 5888,
							z = 3148,
							facing = 2,
						},
 						{
							name = "shieldraid",
							x = 6034,
							z = 3107,
							facing = 2,
						},
 						{
							name = "shieldraid",
							x = 5964,
							z = 3051,
							facing = 2,
						},
 						{
							name = "shieldraid",
							x = 5977,
							z = 3225,
							facing = 2,
						},
 						{
							name = "shieldassault",
							x = 4639,
							z = 5009,
							facing = 2,
						},
 						{
							name = "shieldassault",
							x = 4596,
							z = 4996,
							facing = 3,
						},
 						{
							name = "shieldriot",
							x = 4527,
							z = 5005,
							facing = 2,
						},
 						{
							name = "shieldfelon",
							x = 4579,
							z = 5046,
							facing = 3,
						},
 						{
							name = "turretaalaser",
							x = 4376,
							z = 5384,
							facing = 0,
						},
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = true,
					vitalUnitTypes = {
						"factoryshield",
						"factoryplane",
						"factoryspider"
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Commander and Factories",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Build 10 Phoenixes
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"bomberriot",
					},
					image = planetUtilities.ICON_DIR .. "bomberriot.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build at least 10 Phoenixes",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = {
					victoryByTime = 15*60,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 15:00",
					experience = planetUtilities.BONUS_EXP,
				},
				-- [3] = { -- Don't lose any Thunderbirds
					-- satisfyForever = true,
					-- failOnUnitLoss = true, -- Fails the objective if any units being used to satisfy the objective are lost.
					-- comparisionType = planetUtilities.COMPARE.AT_LEAST,
					-- targetNumber = 0,
					-- unitTypes = {
						-- "bomberdisarm",
					-- },
					-- image = planetUtilities.ICON_DIR .. "bomberdisarm.png",
					-- imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					-- description = "Don't lose any Thunderbirds",
					-- experience = planetUtilities.BONUS_EXP,
				-- },
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"factoryplane",
				"planecon",
				"planefighter",
				"bomberriot",
				"bomberdisarm",
				"staticrearm",
			},
			modules = {
				"module_high_power_servos_LIMIT_B_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
