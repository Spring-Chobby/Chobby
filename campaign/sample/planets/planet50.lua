--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/barren02.png"
	
	local planetData = {
		name = "Ounlele",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.68,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.57,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Radiated",
			radius = "2545 km",
			primary = "Pollizoa",
			primaryType = "A2III",
			milRating = 1,
			text = [[...]]
		},
		gameConfig = {
			mapName = "Aetherian Void 1.5",
			playerConfig = {
				startX = 100,
				startZ = 100,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				-- Extra commander modules.
				extraModules = {
					{name = "module_jumpjet", count = 1, add = false},
					-- List of:
					--  * name - Module name. See commConfig.lua.
					--  * count - Number of copies of the module.
					--  * add - Boolean controlling whether count adds to the number of modules of 
					--          the type the player has equiped or overwrites the number.
				},
				extraUnlocks = {
					"factoryjump",
					"jumpcon",
					"jumpraid",
					"jumpskirm",
					"jumpaa",
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
				"factoryjump",
				"jumpcon",
				"jumpraid",
				"jumpskirm",
				"jumpaa",
			},
			modules = {
				"module_jumpjet",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
