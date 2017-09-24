--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/terran03_damaged.png"
	
	local planetData = {
		name = "Hiasjulo",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.37,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.96,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Oceanic",
			radius = "6190 km",
			primary = "Royal",
			primaryType = "F9IV",
			milRating = 1,
			text = [[You have two starting bases on opposite sides of this island. Use Djinn teleporters to move your army where it is needed most.]]
		},
		tips = {
			{
				image = "unitpics/amphtele.png",
				text = [[To use the Djinn, first command it to place a lantern somewhere, then have your units use the lantern. After some time they will be relocated next to the Djinn. A more expensive unit will need longer to teleport.]]
			},
			{
				image = "unitpics/tele_beacon.png",
				text = [[The Djinn lantern can be placed anywhere on the map, and you don't need constructors to build it. Besides using the Djinn for defence, you can also use it to recover units deep inside enemy territory, or (if you can sneak the Djinn behind the enemy) to launch a sneak attack.]]
			},
		},
		gameConfig = {
			mapName = "Crubick Plains v1.2",
			playerConfig = {
				startX = 6880,
				startZ = 7100,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryamph",
					"amphcon",
					"amphaa",
					"amphtele",
				},
				startUnits = {
					{
						name = "amphtele",
						x = 1372,
						z = 1265,
						facing = 2,
						commands = {
							{cmdID = planetUtilities.COMMAND.PLACE_BEACON, pos = {6854, 6866}},
						},
					},
					{
						name = "staticmex",
						x = 1432,
						z = 1016,
						facing = 0,
					},
					{
						name = "amphtele",
						x = 6717,
						z = 6871,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PLACE_BEACON, pos = {1524, 1304}},
						},
					},
					{
						name = "staticmex",
						x = 1576,
						z = 872,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 1640,
						z = 1064,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1480,
						z = 920,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1640,
						z = 952,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1528,
						z = 1064,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 6424,
						z = 7032,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 6600,
						z = 6984,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 6552,
						z = 7192,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 6456,
						z = 7144,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 6488,
						z = 6952,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 6600,
						z = 7096,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1752,
						z = 1096,
						facing = 0,
					},
					{
						name = "staticheavyradar",
						x = 2224,
						z = 1632,
						facing = 0,
					},
					{
						name = "staticheavyradar",
						x = 6048,
						z = 6576,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 1152,
						z = 1632,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 1568,
						z = 1664,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 6688,
						z = 6512,
						facing = 2,
					},
					{
						name = "turretlaser",
						x = 7040,
						z = 6592,
						facing = 2,
					},
					{
						name = "staticcon",
						x = 1880,
						z = 1288,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {1720, 1288}},
						},
					},
					{
						name = "factoryamph",
						x = 1720,
						z = 1288,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 6296,
						z = 6904,
						facing = 0,
					},
					{
						name = "turretaalaser",
						x = 1928,
						z = 1112,
						facing = 0,
					},
					{
						name = "amphimpulse",
						x = 1312,
						z = 1498,
						facing = 0,
					},
					{
						name = "amphimpulse",
						x = 1408,
						z = 1497,
						facing = 0,
					},
					{
						name = "amphimpulse",
						x = 1509,
						z = 1504,
						facing = 0,
					},
					{
						name = "amphaa",
						x = 6724,
						z = 6702,
						facing = 0,
					},
					{
						name = "amphaa",
						x = 6820,
						z = 6713,
						facing = 0,
					},
					{
						name = "amphaa",
						x = 6914,
						z = 6727,
						facing = 0,
					},
					{
						name = "amphcon",
						x = 1409,
						z = 1402,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 824,
						z = 2552,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 936,
						z = 2760,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 7304,
						z = 5576,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 7176,
						z = 5368,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 7224,
						z = 5448,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 856,
						z = 2664,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 1784,
						z = 952,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 6296,
						z = 7048,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 6344,
						z = 7224,
						facing = 0,
					},
				}
			},
			aiConfig = {
				{
					startX = 4986,
					startZ = 1084,
					humanName = "Nohow",
					--aiLib = "Null AI",
					--==bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 3,
					},
					allyTeam = 1,
					unlocks = {
						"staticradar",
						"staticmex",
						"energysolar",
						"energygeo",
						"turretlaser",
						"turretmissile",
						"shieldcon",
						"shieldraid",
						"shieldskirm",
						"shieldriot",
						"shieldassault",
						"shieldfelon",
						"planecon",
						"bomberprec",
						"bomberriot",
						"bomberdisarm",
						"planefighter",
						"planescout",
					},
					commanderLevel = 3,
					commander = {
						name = "Tweedledum",
						chassis = "strike",
						decorations = {
						},
						modules = { 
							"commweapon_lparticlebeam",
							"commweapon_lparticlebeam",
							"module_dmg_booster",
							"module_dmg_booster",
							"module_heavy_armor",
						}
					},
					startUnits = {
						{
							name = "staticmex",
							x = 4632,
							z = 1048,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 4792,
							z = 824,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 4888,
							z = 1080,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 7384,
							z = 2232,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 7352,
							z = 2472,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 7384,
							z = 2696,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 4840,
							z = 920,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 4696,
							z = 936,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7400,
							z = 2344,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7384,
							z = 2584,
							facing = 0,
						},
						{
							name = "factoryshield",
							x = 4736,
							z = 1224,
							facing = 0,
						},
						{
							name = "factoryplane",
							x = 6608,
							z = 1600,
							facing = 0,
						},
						{
							name = "staticcon",
							x = 6472,
							z = 1432,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 4192,
							z = 1008,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 4560,
							z = 1296,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 5232,
							z = 1232,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6112,
							z = 1424,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6576,
							z = 1888,
							facing = 0,
						},
						{
							name = "turretaaflak",
							x = 5032,
							z = 904,
							facing = 0,
						},
						{
							name = "turretaaflak",
							x = 7144,
							z = 2392,
							facing = 0,
						},
						{
							name = "turretaaflak",
							x = 6776,
							z = 1640,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 6928,
							z = 2720,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 7264,
							z = 2960,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7256,
							z = 2216,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7384,
							z = 2088,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 4778,
							z = 1425,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 4963,
							z = 1364,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 6221,
							z = 1680,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 6346,
							z = 1773,
							facing = 0,
						},
					}
				},
				{
					startX = 3256,
					startZ = 6952,
					humanName = "Contrariwise",
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 3,
					},
					allyTeam = 1,
					unlocks = {
						"staticradar",
						"staticmex",
						"energysolar",
						"energygeo",
						"turretlaser",
						"turretmissile",
						"shieldcon",
						"shieldraid",
						"shieldskirm",
						"shieldriot",
						"shieldassault",
						"shieldfelon",
						"planecon",
						"bomberprec",
						"bomberriot",
						"bomberdisarm",
						"planefighter",
						"planescout",
					},
					commanderLevel = 3,
					commander = {
						name = "Tweedledee",
						chassis = "strike",
						decorations = {
						},
						modules = { 
							"commweapon_lparticlebeam",
							"commweapon_lparticlebeam",
							"module_dmg_booster",
							"module_dmg_booster",
							"module_heavy_armor",
						}
					},
					startUnits = {
						{
							name = "staticmex",
							x = 712,
							z = 5944,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 728,
							z = 6200,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 792,
							z = 6456,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 3304,
							z = 7144,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 3368,
							z = 7400,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 3544,
							z = 7192,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 712,
							z = 6056,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 760,
							z = 6328,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 3320,
							z = 7256,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 3464,
							z = 7288,
							facing = 0,
						},
						{
							name = "factoryplane",
							x = 1536,
							z = 6672,
							facing = 2,
						},
						{
							name = "staticcon",
							x = 1672,
							z = 6824,
							facing = 0,
						},
						{
							name = "factoryshield",
							x = 3456,
							z = 6952,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 800,
							z = 5504,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 1152,
							z = 5568,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 1648,
							z = 6432,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 2160,
							z = 6928,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 2912,
							z = 6944,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 3280,
							z = 6800,
							facing = 2,
						},
						{
							name = "turretlaser",
							x = 3952,
							z = 7088,
							facing = 2,
						},
						{
							name = "energysolar",
							x = 920,
							z = 6440,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 856,
							z = 6552,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 3466,
							z = 6622,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 3598,
							z = 6684,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 1855,
							z = 6606,
							facing = 0,
						},
						{
							name = "shieldraid",
							x = 2000,
							z = 6769,
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
					vitalCommanders = false,
					vitalUnitTypes = {
						"factoryshield",
						"factoryplane",
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
				[1] = { -- Protect all Djinns
					satisfyForever = true,
					failOnUnitLoss = true, -- Fails the objective if any units being used to satisfy the objective are lost.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 0,
					unitTypes = {
						"amphtele",
					},
					image = planetUtilities.ICON_DIR .. "amphtele.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					description = "Don't lose any Djinns",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have 20 Metal Extractors
					satisfyByTime = 900,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 20,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 20 Metal Extractors before 15:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Kill both enemy commanders in 15:00
					satisfyByTime = 900,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "strike.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Kill both enemy commanders before 15:00",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"amphaa",
				"amphtele",
			},
			modules = {
				"module_autorepair_LIMIT_B_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
