--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Dirtbags",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.43,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.495,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6550 km",
			primary = "Dirtbags",
			primaryType = "G8V",
			milRating = 1,
			text = [[something something terraform something dirtbag something]]
		},
		gameConfig = {
			mapName = "IsisDelta_v02",
			modoptions = {
				waterlevel = -160
			},
			playerConfig = {
				startX = 1500,
				startZ = 180,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"shieldscout",
				},
				startUnits = {
				}
			},
			aiConfig = {
				{
					startX = 4000,
					startZ = 75,
					aiLib = "NullAI",
					humanName = "Ally",
					allyTeam = 0,
					unlocks = {
						"shieldscout",
					},
					startUnits = {
						{
							name = "factoryshield",
							x = 184,
							z = 208,
							facing = 1,
							commands = {
								{unitName = "shieldscout"},
								{cmdID = planetUtilities.COMMAND.REPEAT, params = {1}},
								{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1300, 180}},
								{cmdID = planetUtilities.COMMAND.WAIT, params = {planetUtilities.COMMAND.WAITCODE_SQUAD, 20}, options = {"shift"}},
								{cmdID = planetUtilities.COMMAND.TRANSFER_UNIT, params = {0}, options = {"shift"}},
							},
						},
						{
							name = "shieldcon",
							x = 286,
							z = 263,
							facing = 1,
						},
						{
							name = "staticmex",
							x = 328,
							z = 120,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 72,
							z = 136,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 168,
							z = 328,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 2104,
							z = 248,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 1448,
							z = 584,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 2136,
							z = 680,
							facing = 0,
						},
						{
							name = "staticmex",
							x = 1592,
							z = 1208,
							facing = 0,
						},
						{
							name = "energypylon",
							x = 1848,
							z = 232,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1720,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1656,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1592,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1528,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1464,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1400,
							z = 120,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1400,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1464,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1528,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1592,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1720,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 1656,
							z = 56,
							facing = 1,
						},
						{
							name = "energywind",
							x = 40,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 104,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 168,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 232,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 296,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 360,
							z = 40,
							facing = 1,
						},
						{
							name = "energywind",
							x = 40,
							z = 216,
							facing = 1,
						},
						{
							name = "energywind",
							x = 40,
							z = 280,
							facing = 1,
						},
						{
							name = "energywind",
							x = 40,
							z = 344,
							facing = 1,
						},
						{
							name = "energywind",
							x = 104,
							z = 344,
							facing = 1,
						},
					}
				},
				{
					startX = 4000,
					startZ = 75,
					aiLib = "NullAI",
					humanName = "Turrets",
					allyTeam = 1,
					startUnits = {
						{
							name = "energywind",
							x = 3656,
							z = 344,
							facing = 1,
						},
					},
				},
				{
					startX = 4000,
					startZ = 75,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Enemy",
					bitDependant = true,
					--commanderParameters = {
					--	facplop = false,
					--},
					allyTeam = 1,
					unlocks = {
						"cloakraid",
					},
					--commanderLevel = 2,
					--commander = {},
					startUnits = {
					}
				},
			},
			terraform = {
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {240, 240, 370, 370}, 
					height = 468,
				},
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RAMP,
					position = {260, 468, 204, 900, 468, 206},
					width = 100
				},
				{
					terraformShape = planetUtilities.TERRAFORM_SHAPE.RECTANGLE,
					terraformType = planetUtilities.TERRAFORM_TYPE.LEVEL,
					position = {608, 250, 772, 424}, 
					height = 330,
					volumeSelection = planetUtilities.TERRAFORM_VOLUME.LOWER_ONLY,
				},
			},
			defeatConditionConfig = {
				[0] = {
				},
				[1] = {
					ignoreUnitLossDefeat = true,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
			},
			bonusObjectiveConfig = {
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"shieldscout",
			},
			modules = {
				"module_ablative_armor_LIMIT_B_2",
			},
			abilities = {
				"terraform",
			}
		},
	}
	
	return planetData
end

return GetPlanet
