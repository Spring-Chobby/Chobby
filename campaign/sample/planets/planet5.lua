--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Cygnet",
		startingPlanet = false,
		mapDisplay = {
			x = 0.13,
			y = 0.63,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "5500 km",
			primary = "Adimasi",
			primaryType = "G7V",
			milRating = 1,
			text = [[In some circumstances it is ill-advised to approach your enemy too closely... until you've softened them up, that is. Use Hammer artillery bots to weaken your opponent's defences before you commit to an assault. You can construct Lotus laser turrets to protect your Hammers while they work.]]
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "Wanderlust v03",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"cloakarty",
					"turretlaser",
				},
				startUnits = {
				}
			},
			aiConfig = {
			},
		},
		completionReward = {
			units = {
				"cloakarty",
				"turretlaser",
			},
			modules = {
			},
		},
	}
	
	return planetData
end

return GetPlanet
