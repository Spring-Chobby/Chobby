--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/terran04.png"
	
	local planetData = {
		name = "Karuwal",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.685,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.42,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Alpine",
			radius = "6310 km",
			primary = "Ilvasia",
			primaryType = "G7V",
			milRating = 1,
			text = [[...]]
		},
		gameConfig = {
			mapName = "Craterv01",
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
					"striderhub",
					"striderscorpion",
					
				},
				startUnits = {
				}
			},
			aiConfig = {
				{
					startX = 4000,
					startZ = 75,
					humanName = "Enemy",
					--aiLib = "Circuit_difficulty_autofill",
					--bitDependant = true,
					aiLib = "Null AI",
					bitDependant = false,
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
				"striderhub",
				"striderscorpion",
			},
			modules = {
				"commweapon_multistunner",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
