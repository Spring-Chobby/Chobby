--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Borzalon",
		startingPlanet = false,
		mapDisplay = {
			x = 0.24,
			y = 0.22,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Rock",
			radius = "540 km",
			primary = "Purlie",
			primaryType = "G8V",
			milRating = 1,
			text = [[The enemy Tanks will be difficult to defeat in direct combat. Instead, build Dominatrix vehicles to turn your opponent's units against each other.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Red Comet v1.3",
			playerConfig = {
				startX = 5319,
				startZ = 1504,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryveh",
					"vehcon",
					"vehscout",
					"vehcapture",
				},
				startUnits = {
					{
						name = "factoryveh",
						x = 5512,
						z = 1256,
						facing = 3,
					},
					{
						name = "staticradar",
						x = 4848,
						z = 992,
						facing = 0,
					},
					{
						name = "turretlaser",
						x = 4736,
						z = 1056,
						facing = 3,
					},
					{
						name = "turretlaser",
						x = 5168,
						z = 1760,
						facing = 3,
					},
					{
						name = "staticmex",
						x = 5544,
						z = 904,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 5880,
						z = 1192,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 5800,
						z = 1096,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 5656,
						z = 968,
						facing = 0,
					},
					{
						name = "energywind",
						x = 5736,
						z = 1032,
						facing = 0,
					},
					{
						name = "vehcapture",
						x = 5319,
						z = 1374,
						facing = 0,
					},
					{
						name = "vehscout",
						x = 5240,
						z = 1364,
						facing = 0,
					},
					{
						name = "vehscout",
						x = 5396,
						z = 1359,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 5192,
						z = 632,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 5304,
						z = 696,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 5432,
						z = 808,
						facing = 0,
					},
				}
			},
			aiConfig = {
				{
					startX = 100,
					startZ = 100,
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					humanName = "Benefactor",
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticmex",
						"energysolar",
						"staticradar",
						"tankcon",
						"tankassault",
						"tankheavyraid",
						"tankarty",
						"tankaa",
						"tankheavyassault",
						"tankriot",
						"turretlaser",
						"turretriot",
						"turretmissile",
						"turretheavylaser"
					},
					difficultyDependantUnlocks = {
						[2] = {"factoryveh","vehraid","vehsupport","vehassault","vehriot"},
						[3] = {"veharty","vehscout"}, --kek 
					},
					commanderLevel = 2,
					commander = {
						name = "Schmuck",
						chassis = "engineer",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = { 
							"commweapon_lparticlebeam", 
							"module_radarnet",
							"module_ablative_armor",
							"module_autorepair",
						}
					},
					startUnits = {
						{
							name = "tankheavyraid",
							x = 1900,
							z = 1000,
							facing = 0,
						},
						{
							name = "tankheavyraid",
							x = 1900,
							z = 800,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "tankheavyraid",
							x = 1900,
							z = 900,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "tankriot",
							x = 2000,
							z = 100,
							facing = 0,
						},
						{
							name = "tankriot",
							x = 1950,
							z = 800,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "factorytank",
							x = 1584,
							z = 1120,
							facing = 1,
						},
						{
							name = "staticradar",
							x = 3200,
							z = 800,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 872,
							z = 216,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 216,
							z = 184,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 184,
							z = 1096,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 1376,
							z = 400,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 288,
							z = 1536,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1240,
							z = 920,
							facing = 0,
						},
						{
							name = "energywind",
							x = 1304,
							z = 1016,
							facing = 0,
						},
						{
							name = "energywind",
							x = 1336,
							z = 1112,
							facing = 0,
						},
						{
							name = "energywind",
							x = 1336,
							z = 1224,
							facing = 0,
						},
						{
							name = "energywind",
							x = 1352,
							z = 1304,
							facing = 0,
						},
						{
							name = "energywind",
							x = 1144,
							z = 856,
							facing = 0,
						},
						{
							name = "energywind",
							x = 760,
							z = 952,
							facing = 0,
						},
						{
							name = "energywind",
							x = 696,
							z = 1064,
							facing = 0,
						},
						{
							name = "energywind",
							x = 696,
							z = 1192,
							facing = 0,
						},
						{
							name = "energywind",
							x = 728,
							z = 1304,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 2448,
							z = 736,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 2464,
							z = 512,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 2352,
							z = 1536,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 2272,
							z = 1712,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 1312,
							z = 3056,
							facing = 1,
						},
						{
							name = "turretlaser",
							x = 1408,
							z = 2960,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 2192,
							z = 1104,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 1664,
							z = 2192,
							facing = 1,
						},
						{
							name = "turretriot",
							x = 1848,
							z = 1368,
							facing = 1,
						},
						{
							name = "turretemp",
							x = 1712,
							z = 880,
							facing = 1,
						},
						{
							name = "turretemp",
							x = 1712,
							z = 880,
							facing = 1,
						},
						{
							name = "energypylon",
							x = 6000,
							z = 1700,
							facing = 3,
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
						"factorytank",
						"factoryveh",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Make your enemy control no Commanders or Factories",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Build 10 Dominatrices
					satisfyOnce = true,
					countRemovedUnits = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"vehcapture",
					},
					image = planetUtilities.ICON_DIR .. "vehcapture.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 10 Dominatrices",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have three Reapers
					satisfyOnce = true,
					capturedUnitsSatisfy = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 3,
					unitTypes = {
						"tankassault",
					},
					image = planetUtilities.ICON_DIR .. "tankassault.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Control 3 Reapers",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Have a Tank Factory
					satisfyOnce = true,
					capturedUnitsSatisfy = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 1,
					unitTypes = {
						"factorytank",
					},
					image = planetUtilities.ICON_DIR .. "factorytank.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Control a Tank Factory",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"vehscout",
				"vehcapture",
			},
			modules = {
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
