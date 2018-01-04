--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/desert02.png"
	
	local planetData = {
		name = "Ulka Cadere",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.77,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.13,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP * 1.25,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "8400 km",
			primary = "Taolis",
			primaryType = "G4V",
			milRating = 1,
			text = [[Two duelling Zenith meteor controllers threaten to reduce this planet to space dust. If you can destroy the enemy Zenith, you'll at least have the satisfaction of being the owner of that space dust.]]
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
					"zenith"
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
				"zenith",
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
