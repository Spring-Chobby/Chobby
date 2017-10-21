--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/swamp03.png"
	
	local planetData = {
		name = "Im Jaleth",
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.05,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.87,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6550 km",
			primary = "Privni",
			primaryType = "G8V",
			milRating = 1,
			text = [[This battle will be straightforward. Construct an army of Glaive raider and Reaver riot bots to overwhelm your enemy.]]
		},
		tips = {
			{
				image = "unitpics/staticmex.png",
				text = [[Metal Extractors gather the metal required to build an army and crush your opponent. Take metal spots and build as many as you can.]]
			},
			{
				image = "unitpics/energysolar.png",
				text = [[Metal is useless without energy as everything costs both metal and energy. Build Solar Collectors to gather energy.]]
			},
			{
				image = "unitpics/cloakriot.png",
				text = [[Reavers are slower than Glaives, but their heavy machine guns allow them to fight Glaives efficiently even when outnumbered.]]
			},
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Living Lands v2.03",
			playerConfig = {
				startX = 300,
				startZ = 3800,
				allyTeam = 0,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"cloakriot",
					"cloakcon",
					"turretlaser",
					"staticradar",
				},
				startUnits = {
					{
						name = "turretlaser",
						x = 300,
						z = 3450,
						facing = 2,
						difficultyAtMost = 2,
					},
					{
						name = "turretlaser",
						x = 1000,
						z = 3750,
						facing = 1,
					},
					{
						name = "staticmex",
						x = 170,
						z = 3900,
						facing = 2, 
					},
					{
						name = "energysolar",
						x = 100,
						z = 3800,
						facing = 2, 
					},
					{
						name = "cloakraid",
						x = 760,
						z = 3500,
						facing = planetUtilities.FACING.NORTH, 
					},
					{
						name = "cloakraid",
						x = 840,
						z = 3500,
						facing = planetUtilities.FACING.NORTH,
					},
					{
						name = "factorycloak",
						x = 800,
						z = 3750,
						facing = 2,
					}, 
				}
			},
			aiConfig = {
				{
					startX = 4000,
					startZ = 75,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Enemy",
					bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"cloakraid",
					},
					-- difficultyDependantUnlocks = {
						-- [3] = {"staticmex"}, -- test this sometime
					-- },
					commanderLevel = 2,
					commander = {
						name = "Most Loyal Opposition",
						chassis = "engineer",
						decorations = {
						  "skin_support_dark",
						},
						modules = {}
					},
					startUnits = {
						{
							name = "staticmex",
							x = 3630,
							z = 220,
							facing = 2, 
						},
						{
							name = "staticmex",
							x = 3880,
							z = 200,
							facing = 2, 
						},
						{
							name = "turretlaser",
							x = 3300,
							z = 300,
							facing = 1,
							difficultyAtLeast = 3,
						},
						{
							name = "staticmex",
							x = 3880,
							z = 520,
							facing = 2, 
						},
						{
							name = "energysolar",
							x = 3745,
							z = 185,
							facing = 2, 
						},
						{
							name = "energysolar",
							x = 3960,
							z = 600,
							facing = 2, 
						},
						{
							name = "factorycloak",
							x = 3750,
							z = 340,
							facing = 4,
							mapMarker = {
								text = "Destroy",
								color = "red"
							}
						},
					
					}
				},
			},
			defeatConditionConfig = {
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					-- The default behaviour, if no parameters are set, is the defeat condition of an
					-- ordinary game. 
					-- If ignoreUnitLossDefeat is true then unit loss does not cause defeat.
					-- If at least one of vitalCommanders or vitalUnitTypes is set then losing all 
					-- commanders (if vitalCommanders is true) as well as all the unit types in 
					-- vitalUnitTypes (if there are any in the list) causes defeat.
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
					description = "Destroy the enemy Commander and Cloakybot Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				-- Indexed by bonusObjectiveID
				[1] = { -- Have 3 mex by 1 minute.
					satisfyByTime = 60,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 3,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 3 Metal Extractors by 1:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[2] = { -- Have 3 solar by 2 minute.
					satisfyByTime = 120,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 3,
					unitTypes = {
						"energysolar",
					},
					image = planetUtilities.ICON_DIR .. "energysolar.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 3 Solar Generators by 2:00",
					experience = planetUtilities.BONUS_EXP,
				},
				[3] = { -- Build a radar
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 1,
					unitTypes = {
						"staticradar",
					},
					image = planetUtilities.ICON_DIR .. "staticradar.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build a Radar Tower",
					experience = planetUtilities.BONUS_EXP,
				},
				[4] = { -- Build 3 Warriors
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 3,
					unitTypes = {
						"cloakriot",
					},
					image = planetUtilities.ICON_DIR .. "cloakriot.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build at least 3 Brutes",
					experience = planetUtilities.BONUS_EXP,
				},
				--[5] = { -- Kill all enemy mexes
				--	satisfyOnce = true,
				--	comparisionType = planetUtilities.COMPARE.AT_MOST,
				--	targetNumber = 0,
				--	enemyUnitTypes = {
				--		"staticmex",
				--	},
				--	image = planetUtilities.ICON_DIR .. "staticmex.png",
				--	imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
				--	description = "Destroy all enemy Metal Extractors",
				--	experience = planetUtilities.BONUS_EXP,
				--},
				[5] = {
					victoryByTime = 480,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 8:00",
					experience = planetUtilities.BONUS_EXP,
				},
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"cloakriot",
				"cloakcon",
				"turretlaser",
				"staticradar",
			},
			modules = {
				"module_dmg_booster_LIMIT_A_2",
			},
			abilities = {
			},
			codexEntries = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
