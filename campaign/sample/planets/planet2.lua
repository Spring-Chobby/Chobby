--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/arid01.png"
	
	local planetData = {
		predownloadMap = true,	
		name = "Zeta Aurigae C", 
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 1.20,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 1.00,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
			hintText = "Click this planet to begin.",
			hintSize = {402, 100},		
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "10200 km",
			primary = "Zeta Aurigae",
			primaryType = "MV",
			milRating = 1,
--			feedbackLink = "http://zero-k.info/Forum/Thread/24417",
			text = [[Construct solars, metal extractors and barracks, hire marines and hunt down all xenosects!]]		},
		tips = {
			{
				image = "unitpics/euf_constructor.png",
				text = [[This little robot is building all you tier 1 buildings.]]
			},		
			{
				image = "unitpics/euf_barracks.png",
				text = [[Your soldiers are trained here. Use the barracks to raise an army.]]
			},
			{
				image = "unitpics/euf_solar.png",
				text = [[Solar collectors are your basic energy supply to power your metal extractors and any production.]]
			},
			{
				image = "unitpics/euf_metalextractor_lvl1.png",
				text = [[Your metal extractors generate resources for production of units and buidlings. They needs sufficient energy to work efficiently.]]
			},			
		},
		gameConfig = {
			mapName = "Badlands 2.1",
			missionStartscript = false,			
			playerConfig = {
				startX = 500,
				startZ = 500,
				allyTeam = 0,
				startMetal = 1000,
				startEnergy = 1000,
				commanderParameters = {	},
				extraUnlocks = {
					'euf_scoutdrone',
					'euf_marine',
					'euf_radar_lvl1',
				},
				commander = false,
				startUnits = {
					{ name = 'euf_constructor', x = 388, z = 3604, facing = 0, },
					{ name = 'euf_sarge', x = 622, z = 3693, facing = 2, },
				}
			},
			modoptions = {	},
			aiConfig = {
				{
					startX = 4000,
					startZ = 75,
					aiLib = "NO AI",
					humanName = "Enemy",
					unlocks = {},
					allyTeam = 1,
					commander = false,
					startUnits = {
						{ name = 'bug_big', x = 2164.32642, z = 323.036194, facing = 0, },
						{ name = 'bug_big', x = 2205.52173, z = 1868.33545, facing = 1, },
						{ name = 'bug_big', x = 2480.21924, z = 2146.74902, facing = 2, },
						{ name = 'bug_big', x = 3410.6272, z = 2591.73169, facing = 3, },
						{ name = 'bug_larva', x = 1229.11816, z = 762.821289, facing = 0, },
						{ name = 'bug_larva', x = 1328.38171, z = 469.973755, facing = 2, },
						{ name = 'bug_larva', x = 1533.21765, z = 1081.11816, facing = 1, },
						{ name = 'bug_larva', x = 1534.24304, z = 573.374146, facing = 0, },
						{ name = 'bug_larva', x = 2136.75269, z = 1930.5564, facing = 0, },
						{ name = 'bug_larva', x = 2374.49487, z = 2960.31274, facing = 1, },
						{ name = 'bug_larva', x = 2774.81299, z = 956.010498, facing = 0, },
						{ name = 'bug_larva', x = 2991.02051, z = 581.429077, facing = 1, },
						{ name = 'bug_larva', x = 3190.40039, z = 848.625244, facing = 0, },
						{ name = 'bug_larva', x = 3240.5376, z = 1099.24463, facing = 0, },
						{ name = 'bug_larva', x = 3389.70386, z = 547.272705, facing = 1, },
						{ name = 'bug_larva', x = 3428.1853, z = 1392.87488, facing = 0, },
						{ name = 'bug_larva', x = 3510.61401, z = 1055.91101, facing = 1, },
						{ name = 'bug_larva', x = 3594.85596, z = 1291.42737, facing = 2, },
						{ name = 'bug_larva', x = 3710.73901, z = 369.391235, facing = 3, },
						{ name = 'bug_med', x = 1895.18726, z = 3882.18091, facing = 1, },
						{ name = 'bug_med', x = 1928.56567, z = 2268.16504, facing = 0, },
						{ name = 'bug_med', x = 2558.6001, z = 3624.72754, facing = 2, },
						{ name = 'bug_med', x = 2918.83008, z = 926.624023, facing = 3, },
						{ name = 'bug_med', x = 2981.69531, z = 1592.6344, facing = 0, },
						{ name = 'bug_med', x = 3223.28369, z = 96.0878296, facing = 1, },
						{ name = 'bug_med', x = 3242.14893, z = 1240.52551, facing = 3, },
						{ name = 'bug_med', x = 3908.04395, z = 917.452515, facing = 2, },
						{ name = 'bug_med', x = 463.322021, z = 1780.00317, facing = 0, },
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = {},
				[1] = {
					ignoreUnitLossDefeat = false,
				},
			},
			objectiveConfig = {
			},
			bonusObjectiveConfig = {
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {},
			modules = {},
			abilities = {},
			codexEntries = {}
		},
	}
	
	return planetData
end

return GetPlanet
