--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Cadentem",
		startingPlanet = false,
		mapDisplay = {
			x = 0.17,
			y = 0.28,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Tundra",
			radius = "6700 km",
			primary = "Sop",
			primaryType = "G2VI",
			milRating = 2,
			text = [[Use Slasher missile trucks and Wolverine mine-laying artillery to push across this battlefield and destroy your enemy. Be sure to expand into the valley in the south-west as well - it is rich in metal deposits.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Avalanche",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"factoryveh",
					"vehcon",
					"vehsupport",
					"veharty",
				},
				startUnits = {
				}
			},
			aiConfig = {
			},
				
		},
		completionReward = {
			units = {
				"vehsupport",
				"veharty",
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
