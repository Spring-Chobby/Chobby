--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet config

local function GetPlanet(planetUtilities, planetID)
	
	local image = LUA_DIRNAME .. "images/planets/radiated02.png"
	
	local planetData = {
		name = "Old Falsell",
		startingPlanet = false,
		mapDisplay = {
			x = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][1]) or 0.57,
			y = (planetUtilities.planetPositions and planetUtilities.planetPositions[planetID][2]) or 0.28,
			image = image,
			size = planetUtilities.PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = planetUtilities.PLANET_SIZE_INFO,
			backgroundImage = planetUtilities.backgroundImages[math.floor(math.random()*#planetUtilities.backgroundImages) + 1],
			terrainType = "Radiated",
			radius = "8390 km",
			primary = "Blank",
			primaryType = "K1VI",
			milRating = 1,
			text = [[In this battle you start at a large numerical and economical disadvantage. However, the high plateaus on this map will give your Spiders an edge, especially the heavy Crab riot/skirmisher.]]
		},
		tips = {
			{
				image = "unitpics/spidercrabe.png",
				text = [[The Crab is armed with a heavy plasma cannon which is especially effective against clusters of lighter units. It also curls up into a heavily-armoured form when stationary.]]
			},
			{
				image = "unitpics/terraunit.png",
				text = [[Crabs benefit from high altitude; they are harder for the enemy to attack, and their plasma cannon gains extra range. If no hills are available in an important area, use Terraforming to create one.]]
			},
			{
				image = "unitpics/spidercon.png",
				text = [[The Spider factory's Weaver constructors are slow, but they have high buildpower, all-terrain movement (obviously), and a short-range radar.]]
			},
		},
		gameConfig = {
			mapName = "Aetherian Void 1.3",
			playerConfig = {
				startX = 7600,
				startZ = 3300,
				allyTeam = 0,
				facplop = false,
				commanderParameters = {
					facplop = false,
					defeatIfDestroyedObjectiveID = 2,
				},
				extraUnlocks = {
					"factoryspider",
					"spidercon",
					"spidercrabe",
					"spiderassault",
					"spiderriot",
					"spideraa",
				},
				extraAbilities = {
					"terraform",
				},
				startUnits = {
				}
			},
			aiConfig = {
				{
					startX = 2600,
					startZ = 6800,
					humanName = "Geode Hunters",
					aiLib = "Null AI",
					bitDependant = false,
					--aiLib = "Circuit_difficulty_autofill",
					--bitDependant = true,
					commanderParameters = {
						facplop = false,
					},
					allyTeam = 1,
					unlocks = {
						"staticcon",
						"staticradar",
						"staticmex",
						"energysolar",
						"energywind",
						"turretmissile",
						"turretlaser",
						"turretaalaser",
						"turretaaclose",
						"turretriot",
						"turretemp",
						"factoryveh",
						"vehcon",
						"vehraid",
						"vehriot",
						"vehassault",
						"vehsupport",
						"veharty",
						"vehaa",
						"factorygunship",
						"gunshipcon",
						"gunshipraid",
						"gunshipbomb",
						"gunshipemp",
						"gunshipskirm",
						"gunshipaa",
						"factoryamph",
						"amphraid",
						"amphriot",
						"amphimpulse",
						"amphfloater",
						"amphaa",
					},
					difficultyDependantUnlocks = {
						[2] = {"gunshipassault"},
						[3] = {"gunshipassault","vehheavyarty"},
						[4] = {"gunshipassault","vehheavyarty","gunshipheavyskirm","gunshipheavytrans"}, --maybe someday circuit will learn to crabenap? lol
					},
					commanderLevel = 5,
					commander = {
						name = "Yarral",
						chassis = "engineer",
						decorations = {
						  "skin_support_zebra",
						},
						modules = { 
							"commweapon_missilelauncher",
							"module_ablative_armor",
							"module_ablative_armor",
							"module_high_power_servos",
							"module_high_power_servos",
							"module_battle_drone",
							"module_battle_drone",
							"module_adv_nano",
							"module_adv_nano",
							"module_adv_nano",
							"commweapon_personal_shield",
						}
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
				"factoryspider",
				"spidercon",
				"spidercrabe",
				"spideraa",
			},
			modules = {
				"module_adv_nano_LIMIT_G_1",
			},
			abilities = {
			}
		},
	}
	
	return planetData
end

return GetPlanet
