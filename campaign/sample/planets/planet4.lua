--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Sigil",
		startingPlanet = false,
		mapDisplay = {
			x = 0.02,
			y = 0.45,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Barren",
			radius = "4400 km",
			primary = "Cryptus",
			primaryType = "F2III",
			milRating = 1,
			text = [[...]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Barren 2",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"cloaksnipe",
				},
				startUnits = {
				}
			},
			aiConfig = {
			},
		},
		completionReward = {
			units = {
				"cloaksnipe",
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
