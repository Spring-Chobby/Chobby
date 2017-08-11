--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Myror",
		startingPlanet = false,
		mapDisplay = {
			x = 0.06,
			y = 0.56,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Alpine",
			radius = "1995 km",
			primary = "Magus",
			primaryType = "K4VI",
			milRating = 1,
			text = [[Your opponent will use Scorcher vehicle raiders in this battle. Shut them down with Tick EMP bombs.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Adamantine_Mountian-V1",
			playerConfig = {
				startX = 3550,
				startZ = 1050,
				allyTeam = 0,
				useUnlocks = true,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"cloakbomb",
					"turretmissile"
				},
				startUnits = {
					{
						name = "factorycloak",
						x = 3550,
						z = 1300,
						facing = 3,
					}, 
					{
						name = "staticradar",
						x = 3820,
						z = 2880,
						facing = 3,
					}, 
					{
						name = "staticradar",
						x = 1050,
						z = 30,
						facing = 3,
					}, 
					{
						name = "staticmex",
						x = 3080,
						z = 980,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3280,
						z = 970,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3050,
						z = 1195,
						facing = 0,
					},
					{
						name = "staticmex",
						x = 3670,
						z = 1750,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3420,
						z = 850,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3420,
						z = 1010,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3600,
						z = 850,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3600,
						z = 1010,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3780,
						z = 850,
						facing = 0,
					},
					{
						name = "energysolar",
						x = 3780,
						z = 1020,
						facing = 0,
					},
					{
						name = "cloakbomb",
						x = 2050,
						z = 1700,
						facing = 0,
					},
					{
						name = "cloakbomb",
						x = 3000,
						z = 3000,
						facing = 3,
					},
					{
						name = "cloakbomb",
						x = 1200,
						z = 1200,
						facing = 3,
					},
					{
						name = "turretmissile",
						x = 3300,
						z = 2360,
						facing = 0,
					}, 
					{
						name = "turretmissile",
						x = 3380,
						z = 2340,
						facing = 0,
					}, 
					{
						name = "turretmissile",
						x = 2700,
						z = 1560,
						facing = 0,
					}, 
					{
						name = "turretmissile",
						x = 2400,
						z = 975,
						facing = 0,
					},
					{
						name = "turretmissile",
						x = 2375,
						z = 900,
						facing = 3,
					},
				}
			},
			aiConfig = {
				{
					startX = 500,
					startZ = 2500,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Clown Cars",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						"vehraid",
						"vehscout",
					},
					commanderLevel = 2,
					commander = {
						name = "BusDriver22",
						chassis = "recon",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = {
							"commweapon_shotgun",
						}
					},
					startUnits = {
						{
							name = "factoryveh",
							x = 500,
							z = 2700,
							facing = 1, 
						},
						{
							name = "staticradar",
							x = 256,
							z = 1551,
							facing = 2, 
						},
						{
							name = "staticradar",
							x = 2330,
							z = 4080,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 215,
							z = 2645,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 440,
							z = 3030,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 420,
							z = 3070,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 700,
							z = 3220,
							facing = 0, 
						},
						{
							name = "vehraid",
							x = 1660,
							z = 3100,
							facing = 0, 
						},
						{
							name = "vehraid",
							x = 262,
							z = 2220,
							facing = 0, 
						},
						{
							name = "vehscout",
							x = 262,
							z = 2420,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 550,
							z = 3160,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 400,
							z = 3150,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 250,
							z = 3160,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 600,
							z = 3330,
							facing = 0, 
						},
						{
							name = "energysolar",
							x = 620,
							z = 3480,
							facing = 0, 
						}, 
						{
							name = "vehheavyarty",
							x = 1600,
							z = 3330,
							facing = 0, 
							bonusObjectiveID = 2,
						}, 
						{
							name = "turretlaser",
							x = 2050,
							z = 3010,
							facing = 1, 
						}, 
						{
							name = "turretlaser",
							x = 2070,
							z = 3500,
							facing = 1, 
						}, 	
						{
							name = "turretlaser",
							x = 570,
							z = 2050,
							facing = 2, 
						}, 	
						{
							name = "turretlaser",
							x = 1315,
							z = 2410,
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
					vitalCommanders = true,
					vitalUnitTypes = {
						"factoryveh",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Commander and Vehicle Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
					-- Indexed by bonusObjectiveID
				[1] = { -- Build 4 Conjurors
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 4,
					unitTypes = {
						"cloakcon",
					},
					image = planetUtilities.ICON_DIR .. "cloakcon.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 4 Conjurers",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Destroy the Impaler
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "vehheavyarty.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy the enemy Impaler",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { 
					victoryByTime = 360,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 6:00",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"cloakbomb",
				"turretmissile"
			},
			modules = {
				"module_autorepair_LIMIT_A_2",
			},
			codexEntries = {
			},
		}
	}
	
	return planetData
end

return GetPlanet
