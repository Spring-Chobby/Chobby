--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Blank",
		startingPlanet = false,
		mapDisplay = {
			x = 0.26,
			y = 0.07,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6550 km",
			primary = "Blank",
			primaryType = "G8V",
			milRating = 1,
			text = [[gunships]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Crubick Plains v1.2",
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
					"factorygunship",
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
				"factorygunship",
			},
			modules = {
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
