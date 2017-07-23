--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Cygnet",
		startingPlanet = false,
		mapDisplay = {
			x = 0.13,
			y = 0.63,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "5500 km",
			primary = "Adimasi",
			primaryType = "G7V",
			milRating = 1,
			text = [[Use the Hammer artillery bots to weaken your opponent's defences and shields before you commit to an assault.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Wanderlust v03",
			playerConfig = {
				startX = 2600,
				startZ = 550,
				allyTeam = 0,
				useUnlocks = true,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"cloakarty",
					"turretmissile",
				},
				startUnits = {
					{
						name = "staticradar",
						x = 2620,
						z = 630,
						facing = 0, 
					},
					{
						name = "factorycloak",
						x = 2560,
						z = 800,
						facing = 0, 
						commands = {
							{unitName = "cloakarty", options = {"shift", "ctrl"}},
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {2560, 1200}},
							{cmdID = planetUtilities.COMMAND.PATROL, pos = {2160, 1200}, options = {"shift"}},
						},
					},
					{
						name = "cloakcon",
						x = 2760,
						z = 800,
						facing = 0,
						commands = {
							{cmdID = planetUtilities.COMMAND.GUARD, atPosition = {2560, 800}},
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {1560, 800}, options = {"shift"}},
							{unitName = "turretmissile", pos = {64, 64}, facing = 3, options = {"shift"}},
						},
					},
					{
						name = "cloakcon",
						x = 2360,
						z = 800,
						facing = 0, 
						commands = {
							{cmdID = planetUtilities.COMMAND.GUARD, atPosition = {2560, 800}},
						},
					},
					{
						name = "turretlaser",
						x = 1300,
						z = 1350,
						facing = 0, 
					},
					{
						name = "turretmissile",
						x =3000,
						z =1200,
						facing = 0, 
					},
					{
						name = "turretmissile",
						x =3150,
						z =1150,
						facing = 0, 
					},
					{
						name = "cloakarty",
						x =2400,
						z =1100,
						facing = 0, 
					},
					{
						name = "cloakarty",
						x =2440,
						z =1080,
						facing = 0, 
					},
					{
						name = "cloakarty",
						x =2480,
						z =1060,
						facing = 0, 
					},
					{
						name = "cloakarty",
						x =2520,
						z =1040,
						facing = 0, 
					},
					{
						name = "cloakarty",
						x =2560,
						z =1020,
						facing = 0, 
					},
					{
						name = "cloakriot",
						x =2700,
						z =1100,
						facing = 0, 
						commands = {
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {2700, 900}},
							{cmdID = planetUtilities.COMMAND.RAW_MOVE, pos = {2500, 1100}, options = {"shift"}},
							{cmdID = planetUtilities.COMMAND.REPEAT, params = {1}}, -- Watch out, start state widget may override this?
						},
					},
					{
						name = "cloakriot",
						x =2650,
						z =1150,
						facing = 1, 
					},
					{
						name = "staticmex",
						x = 2060,
						z = 330,
						facing = 0, 
					},
					{
						name = "staticmex",
						x = 2620,
						z = 330,
						facing = 0, 
					},
					{
						name = "staticmex",
						x = 3220,
						z = 250,
						facing = 0, 
					},
					{
						name = "staticmex",
						x =2270,
						z =1040,
						facing = 0, 
					},
					{
						name = "staticmex",
						x =1550,
						z =635,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2190,
						z =300,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2350,
						z =310,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2510,
						z =305,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2730,
						z =320,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2890,
						z =330,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =3050,
						z =330,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2180,
						z =970,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2400,
						z =1040,
						facing = 0, 
					},
					{
						name = "energysolar",
						x =2250,
						z =1190,
						facing = 0, 
					},
				}
			},
			aiConfig = {
				{
					startX = 500,
					startZ = 2500,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Sentinels",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						"shieldcon",
						"shieldraid",
						"shieldassault",
						"shieldriot",
						"turretmissile",
						"turretlaser",
					},
					difficultyDependantUnlocks = {
						[1] = {"shieldscout"},
						[2] = {},
						[3] = {"shieldriot"},
					},
					commanderLevel = 1,
					commander = {
						name = "Porcupine",
						chassis = "engineer",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = {
							"commweapon_shotgun",
						}
					},
					startUnits = {
						{
							name = "factoryshield",
							x = 2860,
							z = 3960,
							facing = 2, 
						},
						{
							name = "turretheavylaser",
							x = 2750,
							z = 2750,
							facing = 2, 
						},
						{
							name = "turretheavylaser",
							x =950,
							z =3040,
							facing = 2, 
						},
						{
							name = "turretriot",
							x =2280,
							z =3000,
							facing = 2, 
						},
						{
							name = "turretriot",
							x =4750,
							z =2280,
							facing = 2, 
						},
						{
							name = "energygeo",
							x = 3070,
							z = 3980,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 1920,
							z = 3840,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 2520,
							z = 3780,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 3130,
							z = 3750,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 2870,
							z = 3080,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 770,
							z =3180,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 4970,
							z = 2330,
							facing = 2, 
						},
						{
							name = "staticradar",
							x = 3420,
							z = 2860,
							facing = 2, 
						},
						{
							name = "staticradar",
							x = 1020,
							z = 2180,
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
						"factoryshield",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Commander and Shield Bot Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				-- Indexed by bonusObjectiveID
				[1] = { -- Build 12 Hammers
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 12,
					unitTypes = {
						"cloakarty",
					},
					image = planetUtilities.ICON_DIR .. "cloakarty.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 12 Hammers.",
					experience = 10,
				},
				[3] = { -- Win in 10 minutes
					victoryByTime = 600,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 10:00",
					experience = 10,
				},
				[2] = { -- Protect all mex
					satisfyForever = true,
					failOnUnitLoss = true, -- Fails the objective if any units being used to satisfy the objective are lost.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 0,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.GUARD,
					description = "Don't lose any Metal Extractors.",
					experience = 20,
				},
			},
		},
		completionReward = {
			units = {
				"cloakarty",
				"turretmissile",
			},
			modules = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
