local nameList = {
		"amgeo",
	"amphaa",
	"amphartillery",
	"amphassault",
	"amphbomb",
	"amphcon",
	"amphfloater",
	"amphraider",
	"amphraider2",
	"amphraider3",
	"amphriot",
	"amphtele",
	"arm_spider",
	"arm_venom",
	"armaak",
	"armamd",
	"armanni",
	"armarad",
	"armartic",
	"armasp",
	"armbanth",
	"armbrawl",
	"armbrtha",
	"armca",
	"armcarry",
	"armcir",
	"armcomdgun",
	"armcrabe",
	"armcsa",
	"armcybr",
	"armdeva",
	"armestor",
	"armflea",
	"armfus",
	"armham",
	"armjamt",
	"armjeth",
	"armkam",
	"armmanni",
	"armmerl",
	"armmstor",
	"armnanotc",
	"armorco",
	"armpb",
	"armpw",
	"armraven",
	"armraz",
	"armrectr",
	"armrock",
	"armsnipe",
	"armsolar",
	"armsonar",
	"armsptk",
	"armspy",
	"armstiletto_laser",
	"armtick",
	"armwar",
	"armwin",
	"armzeus",
	"assaultcruiser",
	"asteroid",
	"blackdawn",
	"bladew",
	"blastwing",
	"bomberassault",
	"bomberdive",
	"bomberlaser",
	"bomberstrike",
	"cafus",
	"capturecar",
	"cobtransport",
	"coracv",
	"corak",
	"corawac",
	"corbhmth",
	"corbtrans",
	"corcan",
	"corch",
	"corclog",
	"corcrash",
	"corcrw",
	"cordoom",
	"core_spectre",
	"corfast",
	"corfav",
	"corflak",
	"corgarp",
	"corgator",
	"corgol",
	"corgrav",
	"corhlt",
	"corhurc2",
	"corjamt",
	"corlevlr",
	"corllt",
	"cormak",
	"cormart",
	"cormex",
	"cormist",
	"cornecro",
	"corned",
	"corpyro",
	"corpyro2",
	"corrad",
	"corraid",
	"corrazor",
	"correap",
	"corrl",
	"corroach",
	"corsent",
	"corsh",
	"corshad",
	"corsilo",
	"corsktl",
	"corstorm",
	"corsumo",
	"corthud",
	"corvalk",
	"corvamp",
	"damagesink",
	"dante",
	"destroyer",
	"dynfancy_recon_base",
	"dynfancy_strike_base",
	"dynfancy_support_base",
	"dynhub_assault_base",
	"dynhub_recon_base",
	"dynhub_strike_base",
	"dynhub_support_base",
	"empiricaldpser",
	"empmissile",
	"factoryamph",
	"factorycloak",
	"factorygunship",
	"factoryhover",
	"factoryjump",
	"factoryplane",
	"factoryshield",
	"factoryship",
	"factoryspider",
	"factorytank",
	"factoryveh",
	"fakeunit",
	"fakeunit_aatarget",
	"fakeunit_los",
	"fighter",
	"fighterdrone",
	"firewalker",
	"funnelweb",
	"geo",
	"gunshipaa",
	"gunshipcon",
	"gunshipsupport",
	"heavyturret",
	"hoveraa",
	"hoverassault",
	"hoverdepthcharge",
	"hoverminer",
	"hoverriot",
	"hoverscout",
	"hovershotgun",
	"hoverskirm",
	"hoversonic",
	"jumpblackhole",
	"jumpblackhole2",
	"jumpimpulse",
	"jumpriot",
	"logkoda",
	"mahlazer",
	"missilesilo",
	"missiletower",
	"napalmmissile",
	"nebula",
	"neebcomm",
	"nest",
	"nsaclash",
	"panther",
	"puppy",
	"pw_artefact",
	"pw_dropfac",
	"pw_estorage",
	"pw_estorage2",
	"pw_garrison",
	"pw_gaspowerstation",
	"pw_generic",
	"pw_grid",
	"pw_guerilla",
	"pw_inhibitor",
	"pw_interception",
	"pw_mine",
	"pw_mine2",
	"pw_mine3",
	"pw_mstorage2",
	"pw_warpgate",
	"pw_warpgatealt",
	"pw_warpjammer",
	"pw_wormhole",
	"pw_wormhole2",
	"raveparty",
	"rocksink",
	"roost",
	"roostfac",
	"scorpion",
	"screamer",
	"seismic",
	"shieldarty",
	"shieldfelon",
	"shipaa",
	"shiparty",
	"shipassault",
	"shipcarrier",
	"shipcon",
	"shipheavyarty",
	"shipriot",
	"shipscout",
	"shipskirm",
	"shiptorpraider",
	"shiptransport",
	"slowmort",
	"spherecloaker",
	"spherepole",
	"spideraa",
	"spideranarchid",
	"spiderassault",
	"spiderriot",
	"starlight_satellite",
	"striderhub",
	"subraider",
	"subscout",
	"subtacmissile",
	"tacnuke",
	"tankriotraider",
	"tawf114",
	"tele_beacon",
	"terraunit",
	"thicket",
	"tiptest",
	"trem",
	"turrettorp",
	"vehaa",
	"wolverine_mine",
	"zenith",
}

--local humanData = {}
--local newNamesList = {}
--for i = 1, #nameList do
--	if UnitDefNames[nameList[i]] then
--		newNamesList[#newNamesList + 1] = nameList[i]
--		humanData[nameList[i]] = {
--			name = UnitDefNames[nameList[i]].humanName,
--			description = UnitDefNames[nameList[i]].tooltip,
--		}
--	end
--end
--Spring.Echo(Spring.Utilities.TableToString(newNamesList, "newNamesList"))
--Spring.Echo(Spring.Utilities.TableToString(humanData, "humanData"))

local humanNames = {
	spherecloaker = {
		name = "Eraser",
		description = "Area Cloaker/Jammer Walker",
	},
	gunshipsupport = {
		name = "Rapier",
		description = "Multi-Role Support Gunship",
	},
	dynhub_strike_base = {
		name = "Strike Support",
		description = "Mobile Assault Commander",
	},
	amphartillery = {
		name = "Kraken",
		description = "Amphibious Skirmisher/Artillery Bot",
	},
	cormart = {
		name = "Pillager",
		description = "General-Purpose Artillery",
	},
	corcrw = {
		name = "Krow",
		description = "Flying Fortress",
	},
	missilesilo = {
		name = "Missile Silo",
		description = "Produces Tactical Missiles, Builds at 10 m/s",
	},
	jumpriot = {
		name = "Infernal",
		description = "Riot Jumper",
	},
	armflea = {
		name = "Flea",
		description = "Ultralight Scout Spider (Burrows)",
	},
	armfus = {
		name = "Fusion Reactor",
		description = "Medium Powerplant (+35)",
	},
	blastwing = {
		name = "Blastwing",
		description = "Flying Bomb (Burrows)",
	},
	pw_mine2 = {
		name = "Orbital Solar Array",
		description = "Produces 100 energy/turn",
	},
	zenith = {
		name = "Zenith",
		description = "Meteor Controller",
	},
	correap = {
		name = "Reaper",
		description = "Assault Tank",
	},
	starlight_satellite = {
		name = "Owl",
		description = "Starlight relay satellite",
	},
	screamer = {
		name = "Screamer",
		description = "Very Long-Range Anti-Air Missile Tower",
	},
	vehaa = {
		name = "Crasher",
		description = "Fast Anti-Air Vehicle",
	},
	pw_generic = {
		name = "Generic Neutral Structure",
		description = "Blank",
	},
	napalmmissile = {
		name = "Inferno",
		description = "Napalm Missile",
	},
	turrettorp = {
		name = "Urchin",
		description = "Torpedo Launcher",
	},
	factoryamph = {
		name = "Amphibious Bot Plant",
		description = "Produces Amphibious Bots, Builds at 10 m/s",
	},
	cordoom = {
		name = "Doomsday Machine",
		description = "Medium Range Defense Fortress - Requires 50 Power",
	},
	trem = {
		name = "Tremor",
		description = "Heavy Saturation Artillery Tank",
	},
	destroyer = {
		name = "Daimyo",
		description = "Destroyer (Riot/Antisub)",
	},
	armtick = {
		name = "Tick",
		description = "All Terrain EMP Bomb (Burrows)",
	},
	cormak = {
		name = "Outlaw",
		description = "Riot Bot",
	},
	pw_mine3 = {
		name = "Planetary Geothermal Tap",
		description = "Produces 250 energy/turn",
	},
	subraider = {
		name = "Seawolf",
		description = "Attack Submarine (Stealth Raider)",
	},
	thicket = {
		name = "Thicket",
		description = "Barricade",
	},
	corsh = {
		name = "Dagger",
		description = "Fast Attack Hovercraft",
	},
	corllt = {
		name = "Lotus",
		description = "Light Laser Tower",
	},
	factoryship = {
		name = "Shipyard",
		description = "Produces Ships, Builds at 10 m/s",
	},
	tele_beacon = {
		name = "Lamp",
		description = "Teleport Bridge Entry Beacon, right click to teleport.",
	},
	armrock = {
		name = "Rocko",
		description = "Skirmisher Bot (Direct-Fire)",
	},
	tawf114 = {
		name = "Banisher",
		description = "Heavy Riot Support Tank",
	},
	tankriotraider = {
		name = "Panther",
		description = "Riot/Raider Tank",
	},
	coracv = {
		name = "Welder",
		description = "Armed Construction Tank, Builds at 7.5 m/s",
	},
	shieldarty = {
		name = "Racketeer",
		description = "Disarming Artillery",
	},
	gunshipcon = {
		name = "Wasp",
		description = "Heavy Construction Aircraft, Builds at 7.5 m/s",
	},
	roost = {
		name = "Roost",
		description = "Spawns Chicken",
	},
	subtacmissile = {
		name = "Scylla",
		description = "Tactical Nuke Missile Sub, Drains 20 m/s, 30 second stockpile",
	},
	shieldfelon = {
		name = "Felon",
		description = "Shielded Riot/Skirmisher Bot",
	},
	tiptest = {
		name = "TIP test unit",
		description = "bla",
	},
	armpw = {
		name = "Glaive",
		description = "Light Raider Bot",
	},
	striderhub = {
		name = "Strider Hub",
		description = "Constructs Striders, Builds at 10 m/s",
	},
	spiderriot = {
		name = "Redback",
		description = "Riot Spider",
	},
	spiderassault = {
		name = "Hermit",
		description = "All Terrain Assault Bot",
	},
	gunshipaa = {
		name = "Trident",
		description = "Anti-Air Gunship",
	},
	corclog = {
		name = "Dirtbag",
		description = "Box of Dirt",
	},
	dynhub_recon_base = {
		name = "Recon Support",
		description = "High Mobility Commander",
	},
	hoverminer = {
		name = "Dampener",
		description = "Minelaying Hover",
	},
	shiptorpraider = {
		name = "Hunter",
		description = "Torpedo-Boat (Raider)",
	},
	spideraa = {
		name = "Tarantula",
		description = "Anti-Air Spider",
	},
	corrazor = {
		name = "Razor",
		description = "Hardened Anti-Air Laser",
	},
	corgol = {
		name = "Goliath",
		description = "Very Heavy Tank Buster",
	},
	corch = {
		name = "Quill",
		description = "Construction Hovercraft, Builds at 5 m/s",
	},
	armaak = {
		name = "Archangel",
		description = "Heavy Anti-Air Jumper",
	},
	spherepole = {
		name = "Scythe",
		description = "Cloaked Raider Bot",
	},
	geo = {
		name = "Geothermal Generator",
		description = "Medium Powerplant (+25)",
	},
	corfast = {
		name = "Constable",
		description = "Jumpjet Constructor, Builds at 5 m/s",
	},
	dynfancy_strike_base = {
		name = "Strike Trainer",
		description = "Mobile Assault Commander",
	},
	pw_guerilla = {
		name = "Guerilla Jumpgate",
		description = "Spreads Influence remotely",
	},
	pw_estorage = {
		name = "Energy Storage",
		description = "Stores energy",
	},
	armarad = {
		name = "Advanced Radar",
		description = "Long-Range Radar",
	},
	amphraider2 = {
		name = "Archer",
		description = "Amphibious Raider/Riot Bot",
	},
	shipscout = {
		name = "Cutter",
		description = "Picket Ship (Disarming Scout)",
	},
	pw_wormhole = {
		name = "Wormhole Generator",
		description = "Links this planet to nearby planets",
	},
	shipriot = {
		name = "Corsair",
		description = "Corvette (Raider/Riot)",
	},
	armjamt = {
		name = "Sneaky Pete",
		description = "Area Cloaker/Jammer",
	},
	amphbomb = {
		name = "Limpet",
		description = "Amphibious slow mine",
	},
	arm_venom = {
		name = "Venom",
		description = "Lightning Riot Spider",
	},
	factoryjump = {
		name = "Jump/Specialist Plant",
		description = "Produces Jumpjets and Special Walkers, Builds at 10 m/s",
	},
	armpb = {
		name = "Gauss",
		description = "Gauss Turret, 20 health/s when closed",
	},
	nebula = {
		name = "Nebula",
		description = "Atmospheric Mothership",
	},
	corfav = {
		name = "Dart",
		description = "Raider/Scout Vehicle",
	},
	hoveraa = {
		name = "Flail",
		description = "Anti-Air Hovercraft",
	},
	armham = {
		name = "Hammer",
		description = "Light Artillery Bot",
	},
	shipcon = {
		name = "Mariner",
		description = "Construction Ship, Builds at 7.5 m/s",
	},
	armsptk = {
		name = "Recluse",
		description = "Skirmisher Spider (Indirect Fire)",
	},
	blackdawn = {
		name = "Black Dawn",
		description = "Heavy Raider/Assault Gunship",
	},
	shipcarrier = {
		name = "Reef",
		description = "Aircraft Carrier (Bombardment), Stockpiles tacnukes at 10 m/s",
	},
	rocksink = {
		name = "Rocking Damage Sink thing",
		description = "Rocks when you shoot at it.",
	},
	fakeunit_aatarget = {
		name = "Fake AA target",
		description = "Used by the jumpjet script.",
	},
	shipassault = {
		name = "Siren",
		description = "Destroyer (Riot/Assault)",
	},
	pw_garrison = {
		name = "Field Garrison",
		description = "Reduces Influence gain",
	},
	shiparty = {
		name = "Ronin",
		description = "Cruiser (Artillery)",
	},
	shipaa = {
		name = "Zephyr",
		description = "Anti-Air Frigate",
	},
	armamd = {
		name = "Protector",
		description = "Strategic Nuke Interception System",
	},
	mahlazer = {
		name = "Starlight",
		description = "Planetary Energy Chisel",
	},
	dynhub_assault_base = {
		name = "Guardian Support",
		description = "Heavy Combat Commander",
	},
	armbrtha = {
		name = "Big Bertha",
		description = "Strategic Plasma Cannon",
	},
	armcrabe = {
		name = "Crabe",
		description = "Heavy Riot/Skirmish Spider - Curls into Armored Form When Stationary",
	},
	pw_inhibitor = {
		name = "Wormhole Inhibitor",
		description = "Blocks Influence Spread",
	},
	subscout = {
		name = "Lancelet",
		description = "Scout/Suicide Minisub",
	},
	armrectr = {
		name = "Conjurer",
		description = "Cloaked Construction Bot, Builds at 5 m/s",
	},
	seismic = {
		name = "Quake",
		description = "Seismic Missile",
	},
	armsnipe = {
		name = "Spectre",
		description = "Cloaked Skirmish/Anti-Heavy Artillery Bot",
	},
	corbhmth = {
		name = "Behemoth",
		description = "Plasma Artillery Battery - Requires 50 Power",
	},
	wolverine_mine = {
		name = "Claw",
		description = "Wolverine Mine",
	},
	scorpion = {
		name = "Scorpion",
		description = "Cloaked Infiltration Strider",
	},
	armmstor = {
		name = "Storage",
		description = "Stores Metal and Energy (500)",
	},
	roostfac = {
		name = "Roost",
		description = "Spawns Big Chickens",
	},
	amphriot = {
		name = "Scallop",
		description = "Amphibious Riot Bot (Anti-Sub)",
	},
	amphaa = {
		name = "Angler",
		description = "Amphibious Anti-Air Bot",
	},
	corsent = {
		name = "Copperhead",
		description = "Flak Anti-Air Tank",
	},
	armkam = {
		name = "Banshee",
		description = "Raider Gunship",
	},
	raveparty = {
		name = "Disco Rave Party",
		description = "Destructive Rainbow Projector",
	},
	pw_wormhole2 = {
		name = "Improved Wormhole",
		description = "Links this planet to nearby planets",
	},
	pw_warpjammer = {
		name = "Warp Jammer",
		description = "Prevents warp attacks",
	},
	spideranarchid = {
		name = "Anarchid",
		description = "Riot EMP Spider",
	},
	asteroid = {
		name = "Asteroid",
		description = "Space Rock",
	},
	corvamp = {
		name = "Hawk",
		description = "Air Superiority Fighter",
	},
	dynfancy_recon_base = {
		name = "Recon Trainer",
		description = "High Mobility Commander",
	},
	pw_warpgate = {
		name = "Warp Gate",
		description = "Produces warp cores",
	},
	pw_mstorage2 = {
		name = "Metal Storage",
		description = "Stores metal",
	},
	corlevlr = {
		name = "Leveler",
		description = "Riot Vehicle",
	},
	corthud = {
		name = "Thug",
		description = "Shielded Assault Bot",
	},
	corjamt = {
		name = "Aegis",
		description = "Area Shield",
	},
	missiletower = {
		name = "Hacksaw",
		description = "Burst Anti-Air Turret",
	},
	corpyro2 = {
		name = "Pyro",
		description = "Raider/Riot Jumper",
	},
	empiricaldpser = {
		name = "Empirical DPS thing",
		description = "Shoot at it for science.",
	},
	pw_interception = {
		name = "Interception Network",
		description = "Intercepts planetary bombers",
	},
	hoverassault = {
		name = "Halberd",
		description = "Blockade Runner Hover",
	},
	cornecro = {
		name = "Convict",
		description = "Shielded Construction Bot, Builds at 5 m/s",
	},
	shiptransport = {
		name = "Surfboard",
		description = "Transport Platform",
	},
	armwar = {
		name = "Warrior",
		description = "Riot Bot",
	},
	pw_grid = {
		name = "Planetary Defense Grid",
		description = "Defends against everything",
	},
	cafus = {
		name = "Singularity Reactor",
		description = "Large Powerplant (+225) - HAZARDOUS",
	},
	armstiletto_laser = {
		name = "Thunderbird",
		description = "Disarming Lightning Bomber",
	},
	factoryspider = {
		name = "Spider Factory",
		description = "Produces Spiders, Builds at 10 m/s",
	},
	amphtele = {
		name = "Djinn",
		description = "Amphibious Teleport Bridge",
	},
	corstorm = {
		name = "Rogue",
		description = "Skirmisher Bot (Indirect Fire)",
	},
	jumpimpulse = {
		name = "Elevator",
		description = "Impulse Shenanigans Jumpbot",
	},
	pw_estorage2 = {
		name = "Double Energy Storage",
		description = "Stores energy",
	},
	shipskirm = {
		name = "Mistral",
		description = "Rocket Boat (Skirmisher)",
	},
	pw_dropfac = {
		name = "Dropship Factory",
		description = "Produces dropships",
	},
	corpyro = {
		name = "Pyro",
		description = "Raider/Riot Jumper",
	},
	dante = {
		name = "Dante",
		description = "Assault/Riot Strider",
	},
	puppy = {
		name = "Puppy",
		description = "Walking Missile",
	},
	panther = {
		name = "Panther",
		description = "Lightning Assault/Raider Tank",
	},
	nest = {
		name = "Nest",
		description = "Spawns Chickens",
	},
	corgrav = {
		name = "Newton",
		description = "Gravity Turret - On to Repulse, Off to Attract",
	},
	dynhub_support_base = {
		name = "Engineer Support",
		description = "Econ/Support Commander",
	},
	armjeth = {
		name = "Gremlin",
		description = "Cloaked Anti-Air Bot",
	},
	neebcomm = {
		name = "Neeb Comm",
		description = "Ugly Turkey",
	},
	logkoda = {
		name = "Kodachi",
		description = "Raider Tank",
	},
	amgeo = {
		name = "Advanced Geothermal",
		description = "Large Powerplant (+100) - HAZARDOUS",
	},
	pw_gaspowerstation = {
		name = "Gas Power Station",
		description = "Produces Energy",
	},
	jumpblackhole2 = {
		name = "Hoarder",
		description = "Assault/Riot Bot",
	},
	bladew = {
		name = "Gnat",
		description = "Anti-Heavy EMP Drone",
	},
	terraunit = {
		name = "Terraform",
		description = "Spent: 0",
	},
	hoversonic = {
		name = "Morningstar",
		description = "Antisub Hovercraft",
	},
	armestor = {
		name = "Energy Pylon",
		description = "Extends overdrive grid",
	},
	hoverskirm = {
		name = "Trisula",
		description = "Light Assault/Battle Hovercraft",
	},
	corshad = {
		name = "Raven",
		description = "Precision Bomber",
	},
	pw_mine = {
		name = "Power Generator Unit",
		description = "Produces 50 energy/turn",
	},
	amphfloater = {
		name = "Buoy",
		description = "Heavy Amphibious Skirmisher Bot",
	},
	hoverscout = {
		name = "Dagger",
		description = "Fast Attack Hovercraft",
	},
	hoverriot = {
		name = "Mace",
		description = "Riot Hover",
	},
	fakeunit_los = {
		name = "LOS Provider",
		description = "Knows all and sees all",
	},
	armcybr = {
		name = "Wyvern",
		description = "Singularity Bomber",
	},
	hoverdepthcharge = {
		name = "Claymore",
		description = "Anti-Sub Hovercraft",
	},
	heavyturret = {
		name = "Sunlance",
		description = "Anti-Tank Turret - Requires 25 Power",
	},
	tacnuke = {
		name = "Eos",
		description = "Tactical Nuke",
	},
	bomberdive = {
		name = "Raven",
		description = "Precision Bomber",
	},
	funnelweb = {
		name = "Funnelweb",
		description = "Drone/Shield Support Strider",
	},
	firewalker = {
		name = "Firewalker",
		description = "Saturation Artillery Walker",
	},
	corgator = {
		name = "Scorcher",
		description = "Raider Vehicle",
	},
	fighterdrone = {
		name = "Spicula",
		description = "Fighter Drone",
	},
	amphcon = {
		name = "Conch",
		description = "Amphibious Construction Bot, Builds at 7.5 m/s",
	},
	bomberassault = {
		name = "Eclipse",
		description = "Assault Bomber (Anti-Static)",
	},
	armzeus = {
		name = "Zeus",
		description = "Lightning Assault Bot",
	},
	fakeunit = {
		name = "Fake radar signal",
		description = "Created by scrambling devices.",
	},
	armanni = {
		name = "Annihilator",
		description = "Tachyon Projector - Requires 50 Power",
	},
	factoryveh = {
		name = "Light Vehicle Factory",
		description = "Produces Wheeled Vehicles, Builds at 10 m/s",
	},
	armsolar = {
		name = "Solar Collector",
		description = "Small Powerplant (+2)",
	},
	armbrawl = {
		name = "Brawler",
		description = "Fire Support Gunship",
	},
	arm_spider = {
		name = "Weaver",
		description = "Construction Spider, Builds at 7.5 m/s",
	},
	jumpblackhole = {
		name = "Placeholder",
		description = "Black Hole Launcher",
	},
	corned = {
		name = "Mason",
		description = "Construction Vehicle, Builds at 5 m/s",
	},
	factoryshield = {
		name = "Shield Bot Factory",
		description = "Produces Tough Robots, Builds at 10 m/s",
	},
	factoryplane = {
		name = "Airplane Plant",
		description = "Produces Airplanes, Builds at 10 m/s",
	},
	shipheavyarty = {
		name = "Shogun",
		description = "Battleship (Heavy Artillery)",
	},
	armraz = {
		name = "Razorback",
		description = "Assault/Riot Strider",
	},
	factorygunship = {
		name = "Gunship Plant",
		description = "Produces Gunships, Builds at 10 m/s",
	},
	factoryhover = {
		name = "Hovercraft Platform",
		description = "Produces Hovercraft, Builds at 10 m/s",
	},
	factorycloak = {
		name = "Cloaky Bot Factory",
		description = "Produces Cloaky Robots, Builds at 10 m/s",
	},
	empmissile = {
		name = "Shockley",
		description = "EMP missile",
	},
	nsaclash = {
		name = "Scalpel",
		description = "Skirmisher/Anti-Heavy Hovercraft",
	},
	cobtransport = {
		name = "Valkyrie",
		description = "Air Transport",
	},
	assaultcruiser = {
		name = "Vanquisher",
		description = "Heavy Cruiser (Assault)",
	},
	corsktl = {
		name = "Skuttle",
		description = "Cloaked Jumping Anti-Heavy Bomb",
	},
	armcarry = {
		name = "Reef (Classic)",
		description = "Aircraft Carrier (Bombardment) & Anti-Nuke",
	},
	slowmort = {
		name = "Moderator",
		description = "Disruptor Skirmisher Walker",
	},
	fighter = {
		name = "Swift",
		description = "Multi-role Fighter",
	},
	dynfancy_support_base = {
		name = "Engineer Trainer",
		description = "Econ/Support Commander",
	},
	capturecar = {
		name = "Dominatrix",
		description = "Capture Vehicle",
	},
	factorytank = {
		name = "Heavy Tank Factory",
		description = "Produces Heavy and Specialized Vehicles, Builds at 10 m/s",
	},
	armbanth = {
		name = "Bantha",
		description = "Ranged Support Strider",
	},
	corhlt = {
		name = "Stinger",
		description = "High-Energy Laser Tower",
	},
	corflak = {
		name = "Cobra",
		description = "Anti-Air Flak Gun",
	},
	armraven = {
		name = "Catapult",
		description = "Heavy Saturation Artillery Strider",
	},
	armcir = {
		name = "Chainsaw",
		description = "Long-Range Anti-Air Missile Battery",
	},
	armartic = {
		name = "Faraday",
		description = "EMP Turret",
	},
	corroach = {
		name = "Roach",
		description = "Crawling Bomb (Burrows)",
	},
	damagesink = {
		name = "Damage Sink thing",
		description = "Does not care if you shoot at it.",
	},
	corvalk = {
		name = "Valkyrie",
		description = "Air Transport",
	},
	corsilo = {
		name = "Silencer",
		description = "Strategic Nuclear Launcher, Drains 18 m/s, 3 minute stockpile",
	},
	hovershotgun = {
		name = "Punisher",
		description = "Shotgun Hover",
	},
	corsumo = {
		name = "Sumo",
		description = "Heavy Riot Jumper - On to Repulse, Off to Attract",
	},
	armspy = {
		name = "Infiltrator",
		description = "Cloaked Scout/Anti-Heavy",
	},
	armmerl = {
		name = "Impaler",
		description = "Precision Artillery Vehicle",
	},
	core_spectre = {
		name = "Aspis",
		description = "Area Shield Walker",
	},
	corrl = {
		name = "Defender",
		description = "Light Missile Tower",
	},
	pw_warpgatealt = {
		name = "Warp Gate",
		description = "Produces warp cores",
	},
	armnanotc = {
		name = "Caretaker",
		description = "Static Constructor, Builds at 10 m/s",
	},
	corraid = {
		name = "Ravager",
		description = "Assault Vehicle",
	},
	corrad = {
		name = "Radar Tower",
		description = "Early Warning System",
	},
	armwin = {
		name = "Wind/Tidal Generator",
		description = "Small Powerplant",
	},
	pw_artefact = {
		name = "Ancient Artefact",
		description = "Mysterious Relic",
	},
	armca = {
		name = "Crane",
		description = "Construction Aircraft, Builds at 4 m/s",
	},
	corcrash = {
		name = "Vandal",
		description = "Anti-Air Bot",
	},
	corak = {
		name = "Bandit",
		description = "Medium-Light Raider Bot",
	},
	amphraider3 = {
		name = "Duck",
		description = "Amphibious Raider Bot (Anti-Sub)",
	},
	corgarp = {
		name = "Wolverine",
		description = "Artillery Minelayer Vehicle",
	},
	armcomdgun = {
		name = "Ultimatum",
		description = "Cloaked Anti-Heavy/Anti-Strider Walker",
	},
	corhurc2 = {
		name = "Phoenix",
		description = "Saturation Napalm Bomber",
	},
	cormex = {
		name = "Metal Extractor",
		description = "Produces Metal",
	},
	armorco = {
		name = "Detriment",
		description = "Ultimate Assault Strider",
	},
	bomberstrike = {
		name = "Kestrel",
		description = "Tactical Strike Bomber",
	},
	armcsa = {
		name = "Athena",
		description = "Airborne SpecOps Engineer, Builds at 7.5 m/s",
	},
	armasp = {
		name = "Air Repair/Rearm Pad",
		description = "Repairs and Rearms Aircraft, repairs at 2.5 e/s per pad",
	},
	cormist = {
		name = "Slasher",
		description = "Deployable Missile Vehicle (must stop to fire)",
	},
	amphraider = {
		name = "Grebe",
		description = "Amphibious Raider Bot",
	},
	corcan = {
		name = "Jack",
		description = "Melee Assault Jumper",
	},
	armsonar = {
		name = "Sonar Station",
		description = "Locates Water Units",
	},
	bomberlaser = {
		name = "Pheonix with mini-laser",
		description = "Napalm Bomber",
	},
	amphassault = {
		name = "Grizzly",
		description = "Heavy Amphibious Assault Walker",
	},
	armmanni = {
		name = "Penetrator",
		description = "Anti-Heavy Artillery Hovercraft",
	},
	corbtrans = {
		name = "Vindicator",
		description = "Armed Heavy Air Transport",
	},
	corawac = {
		name = "Vulture",
		description = "Area Jammer, Radar/Sonar Plane",
	},
	armdeva = {
		name = "Stardust",
		description = "Anti-Swarm Turret",
	},
}

return {
	nameList = nameList,
	humanNames = humanNames
}