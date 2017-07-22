--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Tremontane",
		startingPlanet = false,
		mapDisplay = {
			x = 0.02,
			y = 0.40,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Arctic",
			radius = "4400 km",
			primary = "Taoune",
			primaryType = "F2III",
			milRating = 1,
			text = [[Your opponent has taken to the air in this battle. Construct the anti-air Gremlin bot and Hacksaw defensive emplacements to bring them back to the ground. Remember the Defender is also effective as an anti-air defence.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Avalanche-v2",
			playerConfig = {
				startX = 580,
				startZ = 3500,
				allyTeam = 0,
				useUnlocks = true,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"cloakaa",
					"turretaaclose",
				},
				startUnits = {
					{
						name = "factorycloak",
						x = 150,
						z = 3660,
						facing = 1,
					},
					{
						name = "turretaaclose",
						x = 700,
						z = 3000,
						facing = 2,
					},
					{
						name = "turretaaclose",
						x = 1150,
						z = 3500,
						facing = 1,
					},
					{
						name = "cloakraid",
						x = 1000,
						z = 3200,
						facing = 1,
					},
					{
						name = "cloakraid",
						x = 1100,
						z = 3250,
						facing = 1,
					},
					{
						name = "cloakraid",
						x = 1050,
						z = 3290,
						facing = 1,
					},
					{
						name = "cloakraid",
						x = 1100,
						z = 3260,
						facing = 1,
					},
					{
						name = "cloakraid",
						x = 1050,
						z = 3340,
						facing = 1,
					},
					{
						name = "staticradar",
						x = 110,
						z = 3180,
						facing = 2,
					},
					{
						name = "staticmex",
						x = 370,
						z = 3750,
						facing = 2,
					},
					{
						name = "turretmissile",
						x = 260,
						z = 3000,
						facing = 1,
					},
					{
						name = "turretmissile",
						x = 1200,
						z = 3800,
						facing = 1,
					},
				}
			},
			aiConfig = {
				{
					startX = 3800,
					startZ = 200,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "_birdies_",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						"planecon",
						"planefighter",
						"bomberprec",
						"bomberriot",
						"staticmex",
						"planescout",
					},
					commanderParameters = {
						facplop = false,
						bonusObjectiveID = 3,
					},
					commanderLevel = 3,
					commander = {
						name = "Top_Gun",
						chassis = "strike",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = {
						  {
							"commweapon_heavymachinegun", "module_radarnet"
						  },
						  {
							--empty
						  },
						}
					},
					startUnits = {
						{
							name = "factoryplane",
							x = 3980,
							z = 110,
							facing = 0, 
						},
						{
							name = "bomberprec",
							x = 3000,
							z = 1000,
							facing = 0, 
						},
						{
							name = "bomberriot",
							x = 3000,
							z = 1200,
							facing = 0, 
						},
						{
							name = "planefighter",
							x = 3200,
							z = 1400,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 3110,
							z = 220,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 3910,
							z = 1030,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 3280,
							z = 100,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 4000,
							z = 900,
							facing = 0, 
						},
						{
							name = "turretriot",
							x = 3800,
							z = 2100,
							facing = 0, 
						},
						{
							name = "turretriot",
							x = 1900,
							z = 400,
							facing = 3, 
						},
						{
							name = "turretriot",
							x = 3500,
							z = 570,
							facing = 3, 
						},
						{
							name = "turretlaser",
							x = 3000,
							z = 300,
							facing = 3, 
						},
						{
							name = "turretemp",
							x = 3050,
							z = 400,
							facing = 3, 
						},
						{
							name = "turretlaser",
							x = 3880,
							z = 1200,
							facing = 0, 
						},
						{
							name = "turretemp",
							x = 3770,
							z = 1170,
							facing = 0, 
						},
						{
							name = "turretemp",
							x = 3770,
							z = 1170,
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
						"factoryplane",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Airplane Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Build 10 Gremlins
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"cloakaa",
					},
					image = planetUtilities.ICON_DIR .. "cloakaa.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 10 Gremlins.",
					experience = 10,
				},
				[2] = { -- Protect all Conjurers
					satisfyForever = true,
					failOnUnitLoss = true, -- Fails the objective if any units being used to satisfy the objective are lost.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 0,
					unitTypes = {
						"cloakcon",
					},
					image = planetUtilities.ICON_DIR .. "cloakcon.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					description = "Don't lose any Conjurors.",
					experience = 10,
				},
				[3] = { -- Kill enemy commander in 7:30
					satisfyByTime = 450,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "strike.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Kill the enemy commander before 7:30.",
					experience = 20,
				},
			},
		},
		completionReward = {
			units = {
				"cloakaa",
				"turretaaclose",
			},
			modules = {
			},
			codexEntries = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
