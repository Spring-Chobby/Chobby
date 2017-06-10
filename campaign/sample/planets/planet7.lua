--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Arodor",
		startingPlanet = false,
		mapDisplay = {
			x = 0.11,
			y = 0.42,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Desert",
			radius = "6600 km",
			primary = "Xar",
			primaryType = "B2Ia",
			milRating = 1,
			text = [[Besides the occasional strange hills dotting the landscape, this is a smooth and level battlefield. Your opponent has arrived before you and has begun expanding their economy. Use your Scorchers to punish their greed.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "AlienDesert",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"factoryveh",
					"vehcon",
					"vehscout",
					"vehraid",
					"vehriot",
					"vehassault",
				},
				startUnits = {
				},
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
		},
		completionReward = {
			units = {
				"factoryveh",
				"vehcon",
				"vehscout",
				"vehraid",
				"vehriot",
				"vehassault",
			},
			modules = {
			},
			codexEntries = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
