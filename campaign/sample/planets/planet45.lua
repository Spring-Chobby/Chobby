--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Blank",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.57,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.28,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Radiated",
			radius = "6550 km",
			primary = "Blank",
			primaryType = "G8V",
			milRating = 1,
			text = [[In this battle you start at a large numerical and economical disadvantage. However, the high plateaus on this map will give your Spiders an edge, especially the heavy Crab riot/skirmisher.]]
		},
		gameConfig = {
			mapName = "Aetherian Void 1.2",
			playerConfig = {
				startX = 7600,
				startZ = 3300,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryspider",
					"spidercon",
					"spidercrabe",
					"spiderassault",
					"spiderriot",
					"spideraa",
				},
				startUnits = {
				}
			},
			aiConfig = {
				{
					startX = 2600,
					startZ = 6800,
					humanName = "Mzabuagi",
					aiLib = "Null AI",
					bitDependant = false,
					--aiLib = "Circuit_difficulty_autofill",
					--bitDependant = true,
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
				"factoryspider",
				"spidercon",
				"spidercrabe",
				"spideraa",
			},
			modules = {
				"module_adv_nano_LIMIT_G_1",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
