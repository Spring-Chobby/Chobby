--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Nashpvos",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.76,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.64,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6550 km",
			primary = "Blank",
			primaryType = "G8V",
			milRating = 1,
			text = [[All previous attempts to defeat the enemy's large clusters of Funnelweb support striders and Big Bertha static artillery have failed. It falls to you to deploy the nuclear option.]]
		},
		tips = {
			{
				image = "unitpics/staticnuke.png",
				text = [[The Trinity nuclear silo builds a nuclear missile every 3 minutes (assuming you provide it with metal). It can stockpile many missiles at once - save them until you are sure no anti-nukes will spoil the show.]]
			},
			{
				image = "unitpics/staticantinuke.png",
				text = [[The Antithesis Anti-Nukes are typically the best-defended thing your enemy possesses. If their anti-air defence is poor destroy the anti-nuke with bombers. Otherwise, a Shockley EMP missile will disable the anti-nuke for a while.]]
			},
			{
				image = "unitpics/striderfunnelweb.png",
				text = [[Funnelweb support striders are armed with a flock of drones and a strong area shield. A single Funnelweb is fairly easy to kill, but in large numbers they are almost impervious to conventional attacks.]]
			},
		},
		gameConfig = {
			mapName = "LowTideV3",
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
					"staticnuke",
					"staticantinuke",
					"staticmissilesilo",
					"empmissile",
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
						"striderfunnelweb",
						"staticnuke",
						"staticantinuke",
					},
					loseAfterSeconds = false,
					allyTeamLossObjectiveID = 1,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Destroy all enemy Funnelwebs, Strider Hubs, and Big Berthas",
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
				"staticnuke",
				"staticantinuke",
			},
			modules = {
				"module_dmg_booster_LIMIT_D_2",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
