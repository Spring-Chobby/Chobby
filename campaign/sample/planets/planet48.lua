--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = planetUtilities.planetImages[math.floor(math.random()*#planetUtilities.planetImages) + 1]
	
	local planetData = {
		name = "Blank",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.53,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.40,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Minimal",
			radius = "6550 km",
			primary = "Blank",
			primaryType = "G8V",
			milRating = 1,
			text = [[Your enemy's defences on this level are dependent on a few critical structures, but the rough terrain will make it very difficult to get close enough to destroy them. The Tactical Missile Silo provides a much more practical solution to this problem.]]
		},
		tips = {
			{
				image = "unitpics/tacnuke.png",
				text = [[The Eos tactical nuke doesn't cause a large explosion, but whatever it hits directly will take a lot of damage. It is quite expensive and should only be used against high-value stationary targets.]]
			},
			{
				image = "unitpics/empmissile.png",
				text = [[Shockley missiles deliver a massive amount of EMP damage in a small radius, and are not affected by shields. Use this to disable the most important part of your opponent's defences just before you attack.]]
			},
			{
				image = "unitpics/napalmmissile.png",
				text = [[Inferno missiles create fire in a large radius, which inflicts damage over time. This is very useful for destroying low-HP economic buildings like Wind Generators and Caretakers, or preventing production from a Factory.]]
			},
			{
				image = "unitpics/seismic.png",
				text = [[The Quake seismic missile's main purpose is reducing terraformed walls so that other missiles can strike their targets. It can also be used to smooth other difficult terrain.]]
			},
		},
		gameConfig = {
			mapName = "Xenolithic_v1",
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
					"staticmissilesilo",
					"tacnuke",
					"napalmmissile",
					"empmissile",
					"seismic",
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
					loseAfterSeconds = false,
				},
			},
			objectiveConfig = {
				-- This is just related to displaying objectives on the UI.
				[1] = {
					description = "Bring your Commander to the Artefact",
				},
				[2] = {
					description = "Protect your Commander",
				},
			},
			bonusObjectiveConfig = {
				[1] = { -- Win by 10:00
					victoryByTime = 600,
					image = planetUtilities.ICON_OVERLAY.CLOCK,
					description = "Win by 10:00",
					experience = planetUtilities.BONUS_EXP,
				},
			}
		},
		completionReward = {
			experience = planetUtilities.MAIN_EXP,
			units = {
				"staticmissilesilo",
				"tacnuke",
				"napalmmissile",
				"empmissile",
				"seismic",
			},
			modules = {
				"commweapon_slamrocket",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
