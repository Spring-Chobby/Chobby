--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/terran03_damaged.png"
	
	local planetData = {
		predownloadMap = true, 
		name = "Zeta Aurigae B",
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 1.40,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 1.00,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP*1.2,
			hintText = "Keep taking planets until you conquer the galaxy.",
			hintSize = {402, 100},
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "12500 km",
			primary = "Zeta Aurigae",
			primaryType = "MV",
			milRating = 1,
--			feedbackLink = "http://zero-k.info/Forum/Thread/24417",
			text = [[Separatists are hiding here. Construct a base and destroy them!]]		},
		tips = {		},
		gameConfig = {
			mapName = "Ravaged_v2",
			missionStartscript = false,			
			playerConfig = {
				startX = 500,
				startZ = 500,
				allyTeam = 0,
				startMetal = 500,
				startEnergy = 500,
				commanderParameters = {	},
				extraUnlocks = {
					'euf_scoutdrone',
					'euf_marine',
					'euf_bazooka',
					'euf_plasmatower',
					'euf_radar_lvl1',					
					'euf_bunker',					
				},
				commander = false,
				startUnits = {
					{ name = "euf_sarge", x = 380, z = 1855, facing = 0, },	
				},
				midgameUnits = {
					{	name = "euf_transport_mis",	x = 650, z = 2150, facing = 1, spawnRadius = 25, delay = 3*30, orbitalDrop = false, },					
					{	name = "euf_transport_mis",	x = 670, z = 2130, facing = 1, spawnRadius = 25, delay = 20*30, orbitalDrop = false, },					
					{	name = "euf_transport_mis",	x = 1000, z = 730, facing = 1, spawnRadius = 25, delay = 8*30, orbitalDrop = false, },
					{	name = "euf_scout",	x = 1000, z = 780, facing = 1, spawnRadius = 25, delay = 5*30, orbitalDrop = true, },
					{	name = "euf_scout",	x = 1000, z = 680, facing = 1, spawnRadius = 25, delay = 7*30, orbitalDrop = true, },	
					{	name = "euf_scout",	x = 900, z = 730, facing = 1, spawnRadius = 25, delay = 7*30, orbitalDrop = true, },	
					{	name = "euf_scout",	x = 630, z = 2000, facing = 1, spawnRadius = 25, delay = 6*30, orbitalDrop = true, },
					{	name = "euf_scout",	x = 600, z = 2050, facing = 1, spawnRadius = 25, delay = 8*30, orbitalDrop = true, },	
					{	name = "euf_scout",	x = 700, z = 2120, facing = 1, spawnRadius = 25, delay = 8*30, orbitalDrop = true, },	
				},
			},
			modoptions = {
			},
			aiConfig = {
				{
					startX = 4000,
					startZ = 75,
					startMetal = 500,
					startEnergy = 500,					
					aiLib = "Skirmish AI",
					humanName = "Enemy",
					unlocks = {
						'euf_scoutdrone',	
					},
					difficultyDependantUnlocks = {
						[2] = {"euf_marine"},
						[3] = {"euf_bazooka"},
						[4] = {"euf_sniper_ai"},
						[4] = {"euf_pyro"},						
					},
					allyTeam = 1,
					commander = false,
					startUnits = {
						{ name = 'euf_aatower_survival', x = 4280, z = 984, facing = 0, difficultyAtLeast = 2, },
						{ name = 'euf_aatower_survival', x = 840, z = 4200, facing = 0, difficultyAtLeast = 2, },
						{ name = 'euf_artytower', x = 3896, z = 1352, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_barracks_ai', x = 4312, z = 624, facing = 0, },
						{ name = 'euf_barracks_ai', x = 1064, z = 4144, facing = 0, },
						{ name = 'euf_bazooka', x = 3851.86914, z = 1223.72168, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_bazooka', x = 4003.75781, z = 854.850098, facing = 0, difficultyAtLeast = 2, },
						{ name = 'euf_bunker_ai', x = 1312, z = 4096, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_bunker_ai', x = 1728, z = 2192, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_bunker_ai', x = 2416, z = 784, facing = 0, difficultyAtLeast = 4, },
						{ name = 'euf_bunker_ai', x = 3808, z = 960, facing = 0, difficultyAtLeast = 4, },
						{ name = 'euf_bunker_ai', x = 4544, z = 4080, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_constructor_ai', x = 4266.83887, z = 839.884766, facing = 0, selfPatrol = true, },
						{ name = 'euf_constructor_ai', x = 4360.38281, z = 848.979248, facing = 0, selfPatrol = true, },
						{ name = 'euf_constructor_ai', x = 933.265137, z = 4308.66211, facing = 0, selfPatrol = true, },
						{ name = 'euf_marine', x = 1021.21521, z = 3788.08862, facing = 0, },
						{ name = 'euf_marine', x = 1110.88257, z = 4385.64941, facing = 0, },
						{ name = 'euf_marine', x = 1174.88293, z = 3991.43701, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_marine', x = 1943.4696, z = 4614.86133, facing = 0, },
						{ name = 'euf_marine', x = 2251.35815, z = 4625.26563, facing = 0, },
						{ name = 'euf_marine', x = 3910.17529, z = 1156.16309, facing = 0, },
						{ name = 'euf_marine', x = 4012.48193, z = 1362.86853, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_marine', x = 4269.81689, z = 1152.71021, facing = 0, difficultyAtLeast = 3, },
						{ name = 'euf_sniper_ai', x = 4032, z = 1392, facing = 0, difficultyAtLeast = 4, },
						{ name = 'euf_sniper_ai', x = 4229, z = 1180, facing = 0, difficultyAtLeast = 4, },
						{ name = 'euf_marine', x = 4451.01172, z = 631.697754, facing = 0, },
						{ name = 'euf_marine', x = 4509.05322, z = 3236.17065, facing = 0, },
						{ name = 'euf_marine', x = 4571.95996, z = 2911.61475, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 1768, z = 4536, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2104, z = 4664, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 2456, z = 4568, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3192, z = 2536, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3208, z = 2008, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 3368, z = 2248, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4088, z = 1112, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4104, z = 648, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4408, z = 1176, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4504, z = 728, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4600, z = 2728, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 4776, z = 3032, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 600, z = 4376, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 616, z = 3976, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 952, z = 3944, facing = 0, },
						{ name = 'euf_metalextractor_lvl1', x = 984, z = 4488, facing = 0, },
						{ name = 'euf_metalextractor_lvl2', x = 4648, z = 3288, facing = 0, },
						{ name = 'euf_plasmatower', x = 1288, z = 4264, facing = 0, },
						{ name = 'euf_plasmatower', x = 1336, z = 3912, facing = 0, },
						{ name = 'euf_plasmatower', x = 3720, z = 1160, facing = 0, },
						{ name = 'euf_plasmatower', x = 3848, z = 728, facing = 0, },
						{ name = 'euf_powerplant', x = 4584, z = 864, facing = 0, },
						{ name = 'euf_powerplant', x = 4600, z = 1168, facing = 0, },
						{ name = 'euf_powerplant', x = 760, z = 4704, facing = 0, },
						{ name = 'euf_powerplant', x = 776, z = 4608, facing = 0, },
						{ name = 'euf_radar_lvl1', x = 4776, z = 2664, facing = 0, },
						{ name = 'euf_radar_lvl2', x = 936, z = 3752, facing = 0, },
						{ name = 'euf_raider', x = 3344.43628, z = 741.506836, facing = 0, },
						{ name = 'euf_scoutdrone', x = 2345.14673, z = 4494.58789, facing = 0, },
						{ name = 'euf_scoutdrone', x = 2481.80225, z = 3375.61523, facing = 0, },
						{ name = 'euf_scoutdrone', x = 3348.65332, z = 987.25415, facing = 0, },
						{ name = 'euf_solar', x = 4528, z = 1056, facing = 0, },
						{ name = 'euf_solar', x = 4528, z = 960, facing = 0, },
						{ name = 'euf_solar', x = 4624, z = 1056, facing = 0, },
						{ name = 'euf_solar', x = 4624, z = 960, facing = 0, },
						{ name = 'euf_start', x = 1008, z = 3920, facing = 0, },
						{ name = 'euf_start', x = 1424, z = 4352, facing = 0, },
						{ name = 'euf_start', x = 4016, z = 1136, facing = 0, },
						{ name = 'euf_start', x = 4336, z = 1328, facing = 0, },
						{ name = 'euf_start', x = 4640, z = 2800, facing = 0, },
						{ name = 'euf_storage', x = 4232, z = 1336, facing = 0, },
						{ name = 'euf_storage', x = 792, z = 3864, facing = 0, },
						{ name = 'euf_techcenter', x = 560, z = 4160, facing = 0, },
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = {},
				[1] = {
					ignoreUnitLossDefeat = true,
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
--				"factorycloak",
--				"cloakraid",
--				"staticmex",
--				"energysolar",
			},
			modules = {},
			abilities = {},
			codexEntries = {}
		},
	}
	
	return planetData
end

return GetPlanet
