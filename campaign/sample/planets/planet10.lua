--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Cadentem",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.17,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.28,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "6700 km",
			primary = "Sop",
			primaryType = "G2VI",
			milRating = 2,
			text = [[Help your ally to push across the map with Slasher trucks and Wolverine mine artillery. Grind your opponent into dust.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "TandemCraters",
			playerConfig = {
				startX = 400,
				startZ = 1500,
				allyTeam = 0,
				useUnlocks = true,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryveh",
					"vehcon",
					"vehsupport",
					"veharty",
				},
				startUnits = {
					{
						name = "factoryveh",
						x = 392,
						z = 1688,
						facing = 1,
					},
					{
						name = "vehsupport",
						x = 500,
						z = 1650,
						facing = 1,
					},
					{
						name = "vehsupport",
						x = 500,
						z = 1750,
						facing = 1,
					},
					{
						name = "vehsupport",
						x = 550,
						z = 1575,
						facing = 1,
					},
					{
						name = "vehsupport",
						x = 550,
						z = 1825,
						facing = 1,
					},
					{
						name = "vehassault",
						x = 590,
						z = 1665,
						facing = 1,
					},
					{
						name = "vehriot",
						x = 590,
						z = 1735,
						facing = 1,
					},
					
				}
			},
			aiConfig = {
				{
					startX = 500,
					startZ = 500,
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					humanName = "Arachnid",
					allyTeam = 0,
					unlocks = {
						"factoryspider",
						"spidercon",
						"spiderscout",
						"spiderassault",
						"spideremp",
						"spiderskirm",
						"spiderriot",
						"staticmex",
						"energysolar",
						"energygeo",
						"staticradar",
						"turretlaser",
						"turretmissile",
						"turretriot",
					},
					commander = false,
					startUnits = {
						{
							name = "factoryspider",
							x = 1224,
							z = 408,
							facing = 1,
						},
						{
							name = "staticmex",
							x = 1608,
							z = 488,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 1320,
							z = 744,
							facing = 0,
						},
						{
							name = "staticradar",
							x = 2064,
							z = 2384,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 1176,
							z = 776,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 1528,
							z = 568,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 1432,
							z = 680,
							facing = 0,
						},
						{
							name = "spidercon",
							x = 1586,
							z = 262,
							facing = 1,
						},
						{
							name = "spidercon",
							x = 1586,
							z = 344,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 2256,
							z = 1040,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 2080,
							z = 1520,
							facing = 1,
						},
						{
							name = "turretmissile",
							x = 2128,
							z = 2272,
							facing = 1,
						},
						{
							name = "staticmex",
							x = 1960,
							z = 2312,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 2184,
							z = 2424,
							facing = 1,
						},
					},
				},
				{
					startX = 7320,
					startZ = 600,
					--aiLib = "Null AI",
					--bitDependant = false,
					aiLib = "Circuit_difficulty_autofill",
					bitDependant = true,
					humanName = "Walkers",
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 2,
					},
					commanderLevel = 3,
					commander = {
						name = "Betty Botty",
						chassis = "strike",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = { 
							"commweapon_beamlaser", 
							"commweapon_beamlaser", 
							"module_ablative_armor",
							"module_autorepair",
							"module_adv_targeting",
						}
					},
					allyTeam = 1,
					unlocks = {
						"staticmex",
						"energysolar",
						"staticradar",
						"turretlaser",
						"factoryjump",
						"factorycloak",
						"jumpcon",
						"jumpscout",
						"jumpraid",
						"jumpblackhole",
						"jumpskirm",
						"cloakcon",
						"cloakraid",
						"cloakbomb",
						"cloakraid",
						"cloakskirm",
						"cloakassault",
						"cloakarty",
						"cloakaa",
						"turretlaser",
						"turretmissile",
						"turretriot",
					},
					difficultyDependantUnlocks = {
						[2] = {"turretheavylaser","jumpassault"},
						[3] = {"jumparty","cloakheavyraid"},
					},
					
					startUnits = {
						{
							name = "factorycloak",
							x = 7320,
							z = 344,
							facing = 3,
						},
						{
							name = "factoryjump",
							x = 7720,
							z = 1736,
							facing = 3,
						},
						{
							name = "staticmex",
							x = 7672,
							z = 1112,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 7416,
							z = 2184,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 6952,
							z = 584,
							facing = 0,
						},
						{
							name = "turretheavylaser",
							x = 7080,
							z = 488,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 6976,
							z = 336,
							facing = 3,
						},
						{
							name = "turretriot",
							x = 7448,
							z = 1592,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 7536,
							z = 1872,
							facing = 3,
						},
						{
							name = "turretmissile",
							x = 7664,
							z = 1472,
							facing = 3,
						},
						{
							name = "turretaaclose",
							x = 7144,
							z = 248,
							facing = 3,
						},
						{
							name = "turretaafar",
							x = 7664,
							z = 848,
							facing = 3,
						},
						{
							name = "turretlaser",
							x = 7536,
							z = 784,
							facing = 0,
						},
						{
							name = "turretlaser",
							x = 7584,
							z = 1008,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7752,
							z = 1000,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7784,
							z = 808,
							facing = 0,
						},
						{
							name = "energysolar",
							x = 7656,
							z = 696,
							facing = 0,
						},
						{
							name = "jumpcon",
							x = 7371,
							z = 982,
							facing = 0,
						},
						{
							name = "cloakraid",
							x = 7258,
							z = 1004,
							facing = 0,
						},
						{
							name = "cloakraid",
							x = 7374,
							z = 1121,
							facing = 0,
						},
						{
							name = "cloakassault",
							x = 6500,
							z = 900,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "jumpskirm",
							x = 6500,
							z = 1000,
							facing = 0,
							difficultyAtLeast = 2,
						},
						{
							name = "jumpassault",
							x = 6500,
							z = 1100,
							facing = 0,
							difficultyAtLeast = 3,
						},
						{
							name = "cloakriot",
							x = 6500,
							z = 1200,
							facing = 0,
							difficultyAtLeast = 3,
						},
					},
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"factoryjump",
						"factorycloak",
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
				[1] = { -- Have 20 Wolverines
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 20,
					unitTypes = {
						"veharty",
					},
					image = planetUtilities.ICON_DIR .. "veharty.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 20 Wolverines",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Kill the enemy commander by 10:00
					satisfyByTime = 600,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "strike.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Kill the enemy commander before 10:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Prevent the enemy having more than twelve mex
					satisfyForever = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 12,
					enemyUnitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Prevent the enemy from building more than twelve Metal Extractors",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"vehsupport",
				"veharty",
			},
			modules = {
				"commweapon_missilelauncher",
			},
			codexEntries = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
