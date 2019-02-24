--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/46.png"
	
	local planetData = {
		name = "Zeta Aurigae A",
		startingPlanet = true,
		predownloadMap = true, 
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 1.00,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 1.00,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP*0.8,
			hintText = "Click this planet to begin.",
			hintSize = {400, 100}, -- Size of the hint box
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Arid",
			radius = "8050 km",
			primary = "Zeta Aurigae",
			primaryType = "MV",
			milRating = 1,
--			feedbackLink = "http://zero-k.info/Forum/Thread/24417",
			text = [[The Xenosects are slowly becoming real trouble on this planet. We still do not know how these beast are able to infest new solar systems. It is time to eredicate the vermin, Exterminator!]]
		},
		tips = {
			{
				image = "unitpics/bug_med.png",
				text = [[The Xenosects - a space bug race are terrorizing the galaxy.]]
			},		
			{
				image = "unitpics/euf_sarge.png",
				text = [[Sarge - your commander that is in charge of your troops. He will encourage and heal nearby units. Protect him at all costs.]]
			},
			{
				image = "unitpics/euf_marine.png",
				text = [[Basic combat unit. It can shoot airborne targets.]]
			},
		},		
		gameConfig = {
--			gameName = "Quick Rocket Tutorial",
			mapName = "Wanderlust v03",
			missionStartscript = false,			
			playerConfig = {
				startX = 500,
				startZ = 500,
				allyTeam = 0,
				startMetal = 10,
				startEnergy = 10,
				commanderParameters = {	},
				extraUnlocks = { },
				commander = false,
				startUnits = {
					{
						name = "euf_sarge_lvl1",
						x = 500,
						z = 3500,
						facing = 3,
						defeatIfDestroyedObjectiveID = 1,				
					},					
				},
				midgameUnits = {
					{	name = "euf_transport_mis",	x = 800, z = 3600, facing = 0, spawnRadius = 25, delay = 4*30, orbitalDrop = false, },
					{	name = "euf_transport_mis",	x = 2880, z = 180, facing = 2, spawnRadius = 25, delay = 90*30, orbitalDrop = false, },						
				},
			},
			modoptions = { },
			aiConfig = {
				{
					startX = 2000,
					startZ = 200,
					aiLib = "NO AI",
					humanName = "Ally",
					allyTeam = 0,
					unlocks = {	},
					startUnits = {
						{ name = 'euf_metalextractor_lvl1', x = 136, z = 136, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 168, z = 1784, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 1848, z = 1912, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 1928, z = 3848, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2056, z = 328, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2264, z = 1032, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 232, z = 344, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2504, z = 3784, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2552, z = 2008, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2616, z = 312, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3112, z = 3752, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3224, z = 248, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 344, z = 1576, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3560, z = 3480, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 584, z = 2184, facing = 0, },
						{ name = 'euf_metalextractor_lvl2', x = 2856, z = 3064, facing = 0, },
						{ name = 'euf_metalextractor_lvl2', x = 872, z = 824, facing = 0, },
						{ name = 'euf_radar_lvl2', x = 2600, z = 504, facing = 0, },
						{ name = 'euf_solar', x = 2400, z = 80, facing = 0, },
						{ name = 'euf_solar', x = 2400, z = 160, facing = 0, },
						{ name = 'euf_solar', x = 2480, z = 80, facing = 0, },
						{ name = 'euf_solar', x = 2480, z = 160, facing = 0, },	
						{ name = 'euf_solar', x = 2560, z = 80, facing = 0, },
						{ name = 'euf_solar', x = 2560, z = 160, facing = 0, },
						{ name = 'euf_solar', x = 2640, z = 80, facing = 0, },
						{ name = 'euf_solar', x = 2640, z = 160, facing = 0, },
						{ name = 'euf_marine', x = 2150, z = 450, facing = 2, {cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {500, 3500}, options = {"shift"}}, },							
						{ name = 'euf_marine', x = 2200, z = 500, facing = 2, {cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {500, 3500}, options = {"shift"}}, },						
					}
				},
				{
					startX = 4000,
					startZ = 75,
					aiLib = "NO AI",
					humanName = "Enemy",
					unlocks = {},
					allyTeam = 1,
					commander = false,
					startUnits = {
						{ name = "bug_big", x = 4000,	z = 500, facing = 0, commands = { {cmdID = planetUtilities.COMMAND.PATROL, pos = {3900, 1200}},	}, },
						{ name = "bug_big", x = 4350,	z = 800, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {4000, 1000}}, }, difficultyAtLeast = 2, },						
						{ name = "bug_big", x = 4300,	z = 700, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {4200, 1200}}, }, difficultyAtLeast = 3, },
						{ name = "bug_big", x = 4700,	z = 350, facing = 0, commands = {{cmdID = planetUtilities.COMMAND.PATROL, pos = {4360, 1200}}, }, difficultyAtLeast = 4, },						
						{ name = "bug_med", x = 300, z = 3800, facing = 0, commands = {}, },	
						{ name = "bug_med", x = 1300, z = 1500, facing = 1, commands = {}, },	
						{ name = "bug_med", x = 1200, z = 1600, facing = 3, commands = {}, },	
						{ name = "bug_larva", x = 700, z = 3000, facing = 2, commands = {}, },	
						{ name = "bug_larva", x = 800, z = 3200, facing = 0, commands = {}, difficultyAtLeast = 3, },	
						{ name = "bug_larva", x = 850, z = 3250, facing = 1, commands = {}, difficultyAtLeast = 4, },
						{ name = 'bug_larva', x = 1247, z = 1130, facing = 0, difficultyAtLeast = 3, },
						{ name = 'bug_larva', x = 1362, z = 963, facing = 0, },
						{ name = 'bug_larva', x = 1429, z = 1190, facing = 0, },
						{ name = 'bug_larva', x = 1607, z = 2455, facing = 0, },
						{ name = 'bug_larva', x = 2709, z = 2692, facing = 0, difficultyAtLeast = 3, },
						{ name = 'bug_larva', x = 2805, z = 2537, facing = 0, },
						{ name = 'bug_larva', x = 2965, z = 2704, facing = 0, },
						{ name = 'bug_larva', x = 3286, z = 1863, facing = 0, },
						{ name = 'bug_larva', x = 4387, z = 2203, facing = 0, difficultyAtLeast = 3, },
						{ name = 'bug_larva', x = 4630, z = 2291, facing = 0, },
						{ name = 'bug_larva', x = 4719, z = 2100, facing = 0, },
						{ name = 'bug_med', x = 2343, z = 3021, facing = 0, },
						{ name = 'bug_med', x = 2406, z = 1398, facing = 0, },
						{ name = 'bug_med', x = 3502, z = 2114, facing = 0, },
						{ name = 'bug_med', x = 3535, z = 3629, facing = 0, },
						{ name = 'bug_med', x = 4586, z = 3456, facing = 0, },
						{ name = 'bug_med', x = 532, z = 1767, facing = 0, },
						{ name = 'bug_med', x = 543, z = 328, facing = 0, },						
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = {},
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 2,
				},				
			},
				objectiveConfig = {
				[1] = {
					description = "Protect the Sarge",
				},
				[2] = {
					description = "Hunt down all those Xenosects",
				},				
			},
			bonusObjectiveConfig = {
				[1] = { -- Win by 10:00
					victoryByTime = 600,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 20:00",
					experience = planetUtilities.BONUS_EXP,
				},
			},
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {	},
			modules = {},
			abilities = {},
			codexEntries = {}
		},
	}
	
	return planetData
end

return GetPlanet
