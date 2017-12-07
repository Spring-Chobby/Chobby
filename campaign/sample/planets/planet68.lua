--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/tundra01.png"
	
	local planetData = {
		name = "Kufihay",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.955,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.05,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP * 1.25,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Tundra",
			radius = "7650 km",
			primary = "Fili Enso",
			primaryType = "G1V",
			milRating = 1,
			text = [[Your opponent is already conducting a victory celebration with their Disco Rave Party. Hold off their assault until your Starlight orbital chisel is complete, then demonstrate that their revels are premature.]]
		},
		gameConfig = {
			mapName = "Lost_v2",
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
					"mahlazer"
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
				"mahlazer",
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
