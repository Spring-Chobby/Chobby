--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Beth XVII",
		startingPlanet = false,
		mapDisplay = {
			x = 0.04,
			y = 0.73,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "5950 km",
			primary = "Beth",
			primaryType = "G4V",
			milRating = 1,
			text = [[Glaives served you well in the previous battle, but on this planet your opponent has prepared Warrior riot bots and Stardust turrets to counter them. Retaliate with Rockos and your own Warriors to achieve victory.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Battle for PlanetXVII-v01",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"cloakskirm",
					"cloakriot"
				},
				startUnits = {
				}
			},
			aiConfig = {
				{
					startX = 3200,
					startZ = 3200,
					aiLib = "Circuit_difficulty_autofill",
					humanName = "Wubrior Master",
					bitDependant = true,
					facplop = false,
					allyTeam = 1,
					unlocks = {
						"cloakcon",
						"cloakraid",
						"cloakriot",
					},
					commanderLevel = 2,
					commander = {
						name = "You dig.",
						chassis = "guardian",
						decorations = {
						  icon_overhead = { image = "UW" }
						},
						modules = {
						  {
							"commweapon_beamlaser",
						  }
						}
					},
				},
			},
		},
		completionReward = {
			units = {
				"cloakskirm",
				"cloakriot"
			},
			modules = {
				"module_ablative_armor_LIMIT_C_4",
			},
		},
	}
	
	return planetData
end

return GetPlanet
