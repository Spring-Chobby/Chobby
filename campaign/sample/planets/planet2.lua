--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Beth XVII",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.04,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.73,
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
			primaryType = "G4V",
			milRating = 1,
			text = [[Glaives served you well in the previous battle, but on this planet your opponent has prepared Warrior riot bots and Stardust turrets to counter them. Retaliate with Rockos and your own Warriors to achieve victory.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Battle for PlanetXVII-v01",
			playerConfig = {
				startX = 3700,
				startZ = 3700,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				commanderParameters = {
					facplop = true,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"cloakskirm",
				},
				startUnits = {
					{
						name = "staticradar",
						x = 3730,
						z = 3625,
						facing = 3, 
					},
					{
						name = "turretriot",
						x = 2540,
						z = 3580,
						facing = 2, 
					},
					{
						name = "turretriot",
						x = 3210,
						z = 3060,
						facing = 2, 
					},
					{
						name = "turretriot",
						x = 3840,
						z = 2575,
						facing = 3, 
					},
					{
						name = "cloakskirm",
						x = 3340,
						z = 3200,
						facing = 0, 
					},
					{
						name = "cloakskirm",
						x = 3400,
						z = 3190,
						facing = 0, 
					},
					{
						name = "cloakskirm",
						x = 3460,
						z = 3180,
						facing = 0, 
					},
					{
						name = "cloakskirm",
						x = 3520,
						z = 3190,
						facing = 0, 
					},
					{
						name = "cloakskirm",
						x = 3580,
						z = 3200,
						facing = 0, 
					},
					{
						name = "cloakriot",
						x = 3380,
						z = 3280,
						facing = 0, 
					},
					{
						name = "cloakriot",
						x = 3460,
						z = 3260,
						facing = 0, 
					},
					{
						name = "cloakriot",
						x = 3540,
						z = 3280,
						facing = 0, 
					},
					{
						name = "staticmex",
						x = 3960,
						z = 3640,
						facing = 0, 
					},
					{
						name = "energysolar",
						x = 3967,
						z = 3800,
						facing = 0, 
					},
					{
						name = "staticmex",
						x = 3975,
						z = 4025,
						facing = 0, 
					},
					{
						name = "energysolar",
						x = 3700,
						z = 4000,
						facing = 0, 
					},
					{
						name = "staticmex",
						x = 3575,
						z = 3960,
						facing = 0, 
					},
				},
			},
			aiConfig = {
				{
					startX = 400,
					startZ = 400,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Wubrior Master",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						--"cloakcon", --add this back in if the mission is too easy
						"cloakraid", --maybe remove or (if possible) deprioritise this?
						"cloakriot",
					},
					-- difficultyDependantUnlocks = {
						-- [3] = {"staticmex"}, -- test this sometime
					-- },
					commanderLevel = 2,
					commander = {
						name = "Wub Wub Wub",
						chassis = "guardian",
						decorations = {
						},
						modules = {
						  {
							"commweapon_beamlaser",
						  }
						}
					},
					startUnits = {
						{
							name = "turretriot",
							x = 540,
							z = 3270,
							facing = 1, 
							bonusObjectiveID = 4,
						},
						{
							name = "turretriot",
							x = 2000,
							z = 2300,
							facing = 0, 
							bonusObjectiveID = 4,
						},
						{
							name = "turretriot",
							x = 670,
							z = 1540,
							facing = 0, 
							bonusObjectiveID = 4,
						},
						{
							name = "turretriot",
							x = 3560,
							z = 800,
							facing = 0, 
							bonusObjectiveID = 4,
						},
						{
							name = "turretriot",
							x = 1975,
							z = 475,
							facing = 1, 
							bonusObjectiveID = 4,
						},
						{
							name = "factorycloak",
							x = 660,
							z = 770,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 100,
							z = 135,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 610,
							z = 500,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 1300,
							z = 135,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 1510,
							z = 350,
							facing = 0, 
						},
						{
							name = "staticmex",
							x = 1800,
							z = 90,
							facing = 0, 
						},
						{
							name = "energywind",
							x = 2700,
							z = 580,
							facing = 2, 
						},
						{
							name = "energywind",
							x = 2675,
							z = 700,
							facing = 2, 
						},
						{
							name = "energywind",
							x = 2700,
							z = 830,
							facing = 2, 
						},
						{
							name = "energywind",
							x = 2650,
							z = 950,
							facing = 2, 
						},
						{
							name = "energywind",
							x = 2600,
							z = 1070,
							facing = 2, 
						},
						{
							name = "energysolar",
							x = 1450,
							z = 200,
							facing = 2, 
						},
						{
							name = "energywind",
							x = 220,
							z = 130,
							facing = 2, 
						},
					}
				},
			},
			terraform = {
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {3808, 2544, 3808 + 48, 2544 + 48}, 
					height = 130,
					volumeSelection = planetUtilities.TERRAFORM_VOLUME.RAISE_ONLY,
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = true,
					vitalUnitTypes = {
						"factorycloak",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Commander and Cloaky Bot Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
					-- Indexed by bonusObjectiveID
				[1] = { -- plop your factory
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 1,
					unitTypes = {
						"factorycloak",
					},
					image = planetUtilities.ICON_DIR .. "factorycloak.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build a Cloaky Factory",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have 10 mex
					satisfyOnce = true,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 10 Metal Extractors",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Build 10 Rockos
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 10,
					unitTypes = {
						"cloakskirm",
					},
					image = planetUtilities.ICON_DIR .. "cloakskirm.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 10 Rockos",
					experience = planetUtilities.BONUS_EXP,
				},
				[4] = { -- Kill enemy Stardusts in 8 minutes.
					satisfyByTime = 480,
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "turretriot.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Kill all five enemy Stardust turrets before 8:00",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"cloakskirm",
			},
			modules = {
				"commweapon_heavymachinegun",
				"module_dmg_booster_LIMIT_A_2",
				"module_high_power_servos_LIMIT_A_2",
			},
		},
	}
	
	return planetData
end

return GetPlanet
