--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/radiated03.png"
	
	local planetData = {
		predownloadMap = true, 
		name = "Zeta Aurigae G",
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 1.60,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 1.00,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP*0.7,
			hintText = "Keep taking planets until you conquer the galaxy.",
			hintSize = {402, 100},
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "7250 km",
			primary = "Zeta Aurigae",
			primaryType = "MV",
			milRating = 1,
--			feedbackLink = "http://zero-k.info/Forum/Thread/24417",
			text = [[Find the stolen Walker and destroy it. Take care. This metal monster eats heroes for breakfast.]]		},
		tips = {		},
		gameConfig = {
			mapName = "Onyx Cauldron 1.9",
			missionStartscript = false,			
			playerConfig = {
				startX = 2000,
				startZ = 3000,
				allyTeam = 0,
				startMetal = 500,
				startEnergy = 500,
				commanderParameters = {	},
				extraUnlocks = {
				},
				commander = false,
				startUnits = {
					{
						name = "euf_sarge",
						x = 7300,
						z = 2100,
						facing = 0,
					},
					{
						name = "euf_priest",
						x = 7330,
						z = 2050,
						facing = 0,
					},
				}
			},
			modoptions = {
--				integral_disable_defence = 1,
--				integral_disable_special = 1,
			},
			aiConfig = {
				{
					startX = 1900,
					startZ = 6200,
					startMetal = 1000,
					startEnergy = 1000,					
					aiLib = "NO AI",
					humanName = "Enemy",
					unlocks = {},
					allyTeam = 1,
					commander = false,
					startUnits = {
						{ name = "euf_walker", x = 1900, z = 6200, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {3300, 5600}}, }, },
						{ name = "euf_marine", x = 1930, z = 6220, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {7300, 2100}}, }, },
						{ name = "euf_marine", x = 1950, z = 6240, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {7300, 2100}}, }, },			
						{ name = "euf_scout", x = 1930, z = 6220, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {7300, 2100}}, }, },
						{ name = "euf_scout", x = 1950, z = 6240, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {7300, 2100}}, }, },
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = {},
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalUnitTypes = {
						"euf_walker",
					},
				},
			},
			objectiveConfig = {
			},
			bonusObjectiveConfig = {
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"euf_church",
				"euf_priest",
				"euf_paladin",
			},
			modules = {	},
			abilities = {},
			codexEntries = {}
		},
	}
	
	return planetData
end

return GetPlanet
