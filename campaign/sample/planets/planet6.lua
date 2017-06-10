--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Hebat",
		startingPlanet = false,
		mapDisplay = {
			x = 0.205,
			y = 0.705,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Sylvan",
			radius = "3300 km",
			primary = "Voblaka",
			primaryType = "F9V",
			milRating = 1,
			text = [[This battlefield is at a high altitude, so deploy Wind Generators to provide cheap and efficient energy income. Tick EMP mines positioned at strategic locations will prevent your opponent from getting too close to your wind farming operation.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Fairyland v1.0",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"energywind",
					"cloakbomb",
				},
				startUnits = {
				}
			},
			aiConfig = {
			},
		},
		completionReward = {
			units = {
				"energywind",
				"cloakbomb",
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
