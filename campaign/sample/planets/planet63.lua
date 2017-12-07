--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/ocean03.png"
	
	local planetData = {
		name = "Larunina",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.74,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.32,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Crystalline",
			radius = "6700 km",
			primary = "Malnoa",
			primaryType = "B5II",
			milRating = 1,
			text = [[...]]
		},
		gameConfig = {
			mapName = "SapphireShores_Dry_V2.1",
			playerConfig = {
				startX = 100,
				startZ = 100,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"turretheavy",
					"turretantiheavy",
					"energysingu",
				},
				startUnits = {
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
					commanderLevel = 2,
					commander = {
						name = "Most Loyal Opposition",
						chassis = "engineer",
						decorations = {
						  "skin_support_dark",
						  icon_overhead = { image = "UW" }
						},
						modules = { }
					},
					startUnits = {
					}
				},
			},
			defeatConditionConfig = {

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
				"turretheavy",
				"turretantiheavy",
				"energysingu",
			},
			modules = {
				"module_battle_drone_LIMIT_C_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
