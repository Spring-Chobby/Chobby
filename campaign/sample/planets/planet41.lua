--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/radiated01.png"
	
	local planetData = {
		name = "Aspiris",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.435,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.19,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Barren",
			radius = "5350 km",
			primary = "Ahdas Las",
			primaryType = "K4III",
			milRating = 1,
			feedbackLink = "http://zero-k.info/Forum/Thread/24489",
			text = [[Among the heavy Tanks, even the constructors and raiders are tough - but they're also more expensive. You'll have less units than your Cloakbot opponent, so you'll need to be efficient. Retreat and repair damaged tanks to avoid losses.]]
		},
		tips = {
			{
				image = "unitpics/tankcon.png",
				text = [[Unlike all other constructors, the Welder is armed and sturdy. It is better able to weather raids until reinforcements arrive and can even beat a small number of Glaives in a fight.]]
			},
			{
				image = "unitpics/tankheavyraid.png",
				text = [[The Blitz heavy tank raider will go toe-to-toe with any other raider - its high HP and lightning weaponry give it a significant edge. However, it is fairly inefficient due to its comparatively high cost.]]
			},
			{
				image = "LuaUI/Images/commands/Bold/repair.png",
				text = [[To minimize losses, make sure to repair your Tanks when they are partially damaged.]]
			},
		},
		gameConfig = {
			mapName = "TitanDuel 2.2",
			playerConfig = {
				startX = 3600,
				startZ = 1000,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factorytank",
					"tankcon",
					"tankassault",
					"tankriot",
					"tankheavyraid",
				},
				startUnits = {
					{
						name = "factorytank",
						x = 4112,
						z = 544,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 3816,
						z = 504,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 3624,
						z = 632,
						facing = 0,
					},
 					{
						name = "staticmex",
						x = 4408,
						z = 920,
						facing = 0,
					},
 					{
						name = "staticradar",
						x = 3888,
						z = 896,
						facing = 0,
					},
 					{
						name = "energysolar",
						x = 3720,
						z = 568,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 4296,
						z = 952,
						facing = 1,
					},
 					{
						name = "energysolar",
						x = 4408,
						z = 1048,
						facing = 1,
					},
 					{
						name = "turretlaser",
						x = 4192,
						z = 1248,
						facing = 0,
					},
 					{
						name = "turretlaser",
						x = 3536,
						z = 928,
						facing = 0,
					},
 					{
						name = "tankcon",
						x = 4077,
						z = 795,
						facing = 0,
					},
 					{
						name = "tankheavyraid",
						x = 3984,
						z = 765,
						facing = 0,
					},
				}
			},
			aiConfig = {
				{
					startX = 1562,
					startZ = 4000,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					--aiLib = "Null AI",
					--bitDependant = false,
					humanName = "Spurs",
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 1,
					},
					allyTeam = 1,
					unlocks = {
						"staticcon",
						"staticradar",
						"staticmex",
						"energysolar",
						"energygeo",
						"factorycloak",
						"cloakcon",
						"cloakraid",
						"cloakriot",
						"cloakassault",
						"cloakskirm",
						"cloakarty",
						"cloakbomb",
						"factoryveh",
						"vehcon",
						"vehraid",
						"vehriot",
						"vehassault",
					},
					difficultyDependantUnlocks = {
						[3] = {"cloakheavyraid"},
						[4] = {"cloakheavyraid"},
					},
					commanderLevel = 5,
					commander = {
						name = "Hawker",
						chassis = "strike",
						decorations = {
						},
						modules = { 
							"commweapon_shotgun",
							"commweapon_multistunner",
							"module_heavy_armor",
							"module_high_power_servos",
							"module_high_power_servos",
							"module_adv_nano",
							"module_adv_nano",
							"module_jammer",
							"module_adv_targeting",
							"module_autorepair",
							"module_autorepair",
						}
					},
					startUnits = {
						{
							name = "pw_warpgate",
							x = 1280,
							z = 3992,
							facing = 0,
							terraformHeight = 121,
							mapMarker = {
								text = "Warp Gate",
								color = "red_small"
							},
						},
						{
							name = "staticmex",
							x = 1606,
							z = 3250,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "turretriot",
							x = 1606,
							z = 3100,
							facing = 2,
							difficultyAtLeast = 2,
						},
						{
							name = "energygeo",
							x = 195,
							z = 4940,
							facing = 0,
							difficultyAtLeast = 3,
							difficultyAtMost = 3,
						},
						{
							name = "energypylon",
							x = 550,
							z = 4600,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "energypylon",
							x = 1421,
							z = 4421,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "turretriot",
							x = 195,
							z = 4740,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "turretriot",
							x = 416,
							z = 4942,
							facing = 2,
							difficultyAtLeast = 3,
						},
						{
							name = "energyheavygeo",
							x = 195,
							z = 4940,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 2820,
							z = 3700,
							facing = 2,
							difficultyAtLeast = 4,
						},
						{
							name = "turretriot",
							x = 770,
							z = 3900,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 770,
							z = 2720,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "turretriot",
							x = 890,
							z = 2720,
							facing = 1,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 770,
							z = 2720,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "cloakassault",
							x = 2170,
							z = 3800,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "cloakassault",
							x = 2270,
							z = 3800,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "cloakassault",
							x = 2370,
							z = 3800,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "cloakcon",
							x = 2470,
							z = 3800,
							facing = 0,
							difficultyAtLeast = 4,
						},
						{
							name = "staticmex",
							x = 808,
							z = 4456,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 1656,
							z = 4152,
							facing = 0,
						},
 						{
							name = "staticmex",
							x = 1816,
							z = 4280,
							facing = 0,
						},
 						{
							name = "factorycloak",
							x = 768,
							z = 4136,
							facing = 1,
						},
 						{
							name = "turretriot",
							x = 776,
							z = 3560,
							facing = 1,
						},
 						{
							name = "turretlaser",
							x = 1280,
							z = 3648,
							facing = 2,
						},
 						{
							name = "turretlaser",
							x = 1904,
							z = 3968,
							facing = 1,
						},
 						{
							name = "cloakcon",
							x = 1075,
							z = 4248,
							facing = 2,
						},
 						{
							name = "cloakriot",
							x = 923,
							z = 3874,
							facing = 2,
						},
 						{
							name = "cloakraid",
							x = 1111,
							z = 3868,
							facing = 2,
						},
 						{
							name = "cloakraid",
							x = 1017,
							z = 3870,
							facing = 2,
						},
 						{
							name = "cloakraid",
							x = 845,
							z = 3826,
							facing = 2,
						},
 						{
							name = "energysolar",
							x = 1784,
							z = 4184,
							facing = 0,
						},
 						{
							name = "turretaalaser",
							x = 1032,
							z = 3944,
							facing = 0,
						},
 						{
							name = "turretaalaser",
							x = 1496,
							z = 4280,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 712,
							z = 4408,
							facing = 0,
						},
 						{
							name = "energysolar",
							x = 904,
							z = 4408,
							facing = 0,
						},
 						{
							name = "cloakcon",
							x = 1004,
							z = 4066,
							facing = 1,
						},
 						{
							name = "cloakraid",
							x = 942,
							z = 3946,
							facing = 2,
						},
 						{
							name = "cloakraid",
							x = 896,
							z = 3924,
							facing = 2,
						},
 						{
							name = "cloakassault",
							x = 802,
							z = 4013,
							facing = 2,
						},
 						{
							name = "turretriot",
							x = 1528,
							z = 3880,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 928,
							z = 4224,
							facing = 2,
						},
 						{
							name = "turretmissile",
							x = 1184,
							z = 4592,
							facing = 2,
						},
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"pw_warpgate",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Warp Gate",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = {
					victoryByTime = 600,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 10:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Lose no more than 5 tanks
					onlyCountRemovedUnits = true,
					satisfyForever = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 5,
					unitTypes = {
						"tankcon",
						"tankraid",
						"tankheavyraid",
						"tankriot",
						"tankassault",
						"tankheavyassault",
						"tankarty",
						"tankheavyarty",
						"tankaa",
					},
					image = planetUtilities.ICON_DIR .. "tankriot.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					description = "Do not lose more than 5 Tanks",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Complete all bonus objectives
					completeAllBonusObjectives = true,
					image = planetUtilities.ICON_OVERLAY.ALL,
					description = "Complete all bonus objectives (in one battle)",
					experience = planetUtilities.BONUS_EXP,
				},
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"factorytank",
				"tankcon",
				"tankriot",
				"tankheavyraid",
			},
			modules = {
				"module_adv_nano_LIMIT_F_1",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
