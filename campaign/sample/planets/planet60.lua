--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/terran02.png"
	
	local planetData = {
		name = "Pen-Yilat",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.86,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.64,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Coastal",
			radius = "7300 km",
			primary = "Narlapa",
			primaryType = "G7V",
			milRating = 1,
			text = [[...]]
		},
		gameConfig = {
			mapName = "Downs_of_Destruction_Fix",
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
					"shipheavyarty",
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
				"striderhub",
				"shipheavyarty",
			},
			modules = {
				"commweapon_concussion",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
