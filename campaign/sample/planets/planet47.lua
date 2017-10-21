--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/swamp02.png"
	
	local planetData = {
		name = "Romolis",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.615,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.375,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6880 km",
			primary = "Kaoloria",
			primaryType = "G4V",
			milRating = 1,
			text = [[You're up against a vicious strider combo - the cloaked Scorpions stun your units, then the Merlin artillery walkers rain rockets on them. Find the enemy striders with the ultra-cheap Flea scout, then disable them in turn with the Widow's anti-heavy stungun.]]
		},
		gameConfig = {
			mapName = "Sierra-v2",
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
					"factoryspider",
					"spidercon",
					"spiderriot",
					"spiderassault",
					"spiderscout",
					"spiderantiheavy",
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
				-- Indexed by allyTeam.
				[0] = { },
				[1] = {
					ignoreUnitLossDefeat = false,
					vitalCommanders = false,
					vitalUnitTypes = {
						"striderhub",
						"striderscorpion",
						"stridercatapult",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy all enemy Scorpions, Catapults and Strider Hubs",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"spiderscout",
				"spiderantiheavy",
			},
			modules = {
				"module_autorepair_LIMIT_D_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
