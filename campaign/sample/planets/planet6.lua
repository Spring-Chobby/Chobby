--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Hebat",
		startingPlanet = false,
		mapDisplay = {
			x = 0.22,
			y = 0.68,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Sylvan",
			radius = "3300 km",
			primary = "Voblaka",
			primaryType = "F9V",
			milRating = 1,
			text = [[This battlefield is at a high altitude, so deploy Wind Generators to provide cheap and efficient energy income. Zeus assault bots will crush any opposition you will face here.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Fairyland v1.0",
			playerConfig = {
				startX = 370,
				startZ = 3500,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				commanderParameters = {
					facplop = true,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"energywind",
					"cloakassault",
				},
				startUnits = {
					{
						name = "cloakcon",
						x = 200,
						z = 3550,
						facing = 1, 
					}, 
					{
						name = "cloakassault",
						x = 800,
						z = 3400,
						facing = 1, 
					}, 
					{
						name = "cloakassault",
						x = 800,
						z = 3600,
						facing = 1, 
					}, 
					{
						name = "cloakraid",
						x = 950,
						z = 3500,
						facing = 1, 
					}, 
					{
						name = "cloakraid",
						x = 910,
						z = 3350,
						facing = 1, 
					}, 
					{
						name = "cloakraid",
						x = 990,
						z = 3650,
						facing = 1, 
					}, 
					
				}
			},
			aiConfig = {
				{
					startX = 4800,
					startZ = 1600,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "BurnForever",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						"staticmex",
						"energywind",
						"jumpscout",
						"jumpraid",
					},
					commanderLevel = 2,
					commander = {
						name = "Firelord",
						chassis = "recon",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = {
						  {
							"commweapon_flamethrower",
						  }
						}
					},
					startUnits = {
						{
							name = "jumpcon",
							x = 5000,
							z = 2000,
							facing = 0, 
						},
						{
							name = "factoryjump",
							x = 4200,
							z = 1400,
							facing = 0, 
						},
						{
							name = "jumpblackhole",
							x = 4200,
							z = 2000,
							facing = 0, 
							bonusObjectiveID = 2,
						}, 
						{
							name = "jumpblackhole",
							x = 4700,
							z = 400,
							facing = 0, 
							bonusObjectiveID = 2,
						}, 
						{
							name = "jumpblackhole",
							x = 2620,
							z = 500,
							facing = 0, 
							bonusObjectiveID = 2,
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
						"factoryjump",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy the enemy Commander and Jumpbot Factory",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
					-- Indexed by bonusObjectiveID
				[1] = { -- Build 25 Windgens
					satisfyOnce = true,
					countRemovedUnits = true, -- count units that previously died.
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 25,
					unitTypes = {
						"energywind",
					},
					image = planetUtilities.ICON_DIR .. "energywind.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Build 25 Wind Turbines.",
					experience = 10,
				},
				[2] = { -- Destroy the Placeholders
					comparisionType = planetUtilities.COMPARE.AT_MOST,
					targetNumber = 0,
					-- See bonusObjectiveID in units table
					image = planetUtilities.ICON_DIR .. "jumpblackhole.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.ATTACK,
					description = "Destroy all three enemy Placeholders.",
					experience = 10,
				},
				[3] = { -- Have 12 mex by 7:30.
					satisfyByTime = 450,
					comparisionType = planetUtilities.COMPARE.AT_LEAST,
					targetNumber = 12,
					unitTypes = {
						"staticmex",
					},
					image = planetUtilities.ICON_DIR .. "staticmex.png",
					imageOverlay = planetUtilities.ICON_OVERLAY.REPAIR,
					description = "Have 12 Metal Extractors by 7:30.",
					experience = 20,
				},
			},
		},
		completionReward = {
			units = {
				"energywind",
				"cloakassault",
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
