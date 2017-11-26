--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	--local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	local image = LUA_DIRNAME .. "images/planets/terran03_damaged.png"
	
	local planetData = {
		name = "Onsally",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.77,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.13,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Igneous",
			radius = "6370 km",
			primary = "Easnor",
			primaryType = "A4IV",
			milRating = 1,
			text = [[Phoenix blah]]
		},
		gameConfig = {
			mapName = "LowTideV3",
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
					"factoryplane",
					"bomberriot",
					"planeheavyfighter",
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
				"bomberriot",
				"planeheavyfighter",
			},
			modules = {
				"module_high_power_servos_LIMIT_B_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
