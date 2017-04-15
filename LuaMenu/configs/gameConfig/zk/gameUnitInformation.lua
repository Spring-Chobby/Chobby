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
--			humanName = UnitDefNames[nameList[i]].humanName,
--			description = UnitDefNames[nameList[i]].tooltip,
--		}
--	end
--end
--Spring.Echo(Spring.Utilities.TableToString(newNamesList, "newNamesList"))
--Spring.Echo(Spring.Utilities.TableToString(humanData, "humanData"))

local humanNames = {
	spherecloaker = {
		humanName = "Eraser",
		description = "Area Cloaker/Jammer Walker",
	},
	gunshipsupport = {
		humanName = "Rapier",
		description = "Multi-Role Support Gunship",
	},
	dynhub_strike_base = {
		humanName = "Strike Support",
		description = "Mobile Assault Commander",
	},
	amphartillery = {
		humanName = "Kraken",
		description = "Amphibious Skirmisher/Artillery Bot",
	},
	cormart = {
		humanName = "Pillager",
		description = "General-Purpose Artillery",
	},
	corcrw = {
		humanName = "Krow",
		description = "Flying Fortress",
	},
	missilesilo = {
		humanName = "Missile Silo",
		description = "Produces Tactical Missiles, Builds at 10 m/s",
	},
	jumpriot = {
		humanName = "Infernal",
		description = "Riot Jumper",
	},
	armflea = {
		humanName = "Flea",
		description = "Ultralight Scout Spider (Burrows)",
	},
	armfus = {
		humanName = "Fusion Reactor",
		description = "Medium Powerplant (+35)",
	},
	blastwing = {
		humanName = "Blastwing",
		description = "Flying Bomb (Burrows)",
	},
	pw_mine2 = {
		humanName = "Orbital Solar Array",
		description = "Produces 100 energy/turn",
	},
	zenith = {
		humanName = "Zenith",
		description = "Meteor Controller",
	},
	correap = {
		humanName = "Reaper",
		description = "Assault Tank",
	},
	starlight_satellite = {
		humanName = "Owl",
		description = "Starlight relay satellite",
	},
	screamer = {
		humanName = "Screamer",
		description = "Very Long-Range Anti-Air Missile Tower",
	},
	vehaa = {
		humanName = "Crasher",
		description = "Fast Anti-Air Vehicle",
	},
	pw_generic = {
		humanName = "Generic Neutral Structure",
		description = "Blank",
	},
	napalmmissile = {
		humanName = "Inferno",
		description = "Napalm Missile",
	},
	turrettorp = {
		humanName = "Urchin",
		description = "Torpedo Launcher",
	},
	factoryamph = {
		humanName = "Amphibious Bot Plant",
		description = "Produces Amphibious Bots, Builds at 10 m/s",
	},
	cordoom = {
		humanName = "Doomsday Machine",
		description = "Medium Range Defense Fortress - Requires 50 Power",
	},
	trem = {
		humanName = "Tremor",
		description = "Heavy Saturation Artillery Tank",
	},
	destroyer = {
		humanName = "Daimyo",
		description = "Destroyer (Riot/Antisub)",
	},
	armtick = {
		humanName = "Tick",
		description = "All Terrain EMP Bomb (Burrows)",
	},
	cormak = {
		humanName = "Outlaw",
		description = "Riot Bot",
	},
	pw_mine3 = {
		humanName = "Planetary Geothermal Tap",
		description = "Produces 250 energy/turn",
	},
	subraider = {
		humanName = "Seawolf",
		description = "Attack Submarine (Stealth Raider)",
	},
	thicket = {
		humanName = "Thicket",
		description = "Barricade",
	},
	corsh = {
		humanName = "Dagger",
		description = "Fast Attack Hovercraft",
	},
	corllt = {
		humanName = "Lotus",
		description = "Light Laser Tower",
	},
	factoryship = {
		humanName = "Shipyard",
		description = "Produces Ships, Builds at 10 m/s",
	},
	tele_beacon = {
		humanName = "Lamp",
		description = "Teleport Bridge Entry Beacon, right click to teleport.",
	},
	armrock = {
		humanName = "Rocko",
		description = "Skirmisher Bot (Direct-Fire)",
	},
	tawf114 = {
		humanName = "Banisher",
		description = "Heavy Riot Support Tank",
	},
	tankriotraider = {
		humanName = "Panther",
		description = "Riot/Raider Tank",
	},
	coracv = {
		humanName = "Welder",
		description = "Armed Construction Tank, Builds at 7.5 m/s",
	},
	shieldarty = {
		humanName = "Racketeer",
		description = "Disarming Artillery",
	},
	gunshipcon = {
		humanName = "Wasp",
		description = "Heavy Construction Aircraft, Builds at 7.5 m/s",
	},
	roost = {
		humanName = "Roost",
		description = "Spawns Chicken",
	},
	subtacmissile = {
		humanName = "Scylla",
		description = "Tactical Nuke Missile Sub, Drains 20 m/s, 30 second stockpile",
	},
	shieldfelon = {
		humanName = "Felon",
		description = "Shielded Riot/Skirmisher Bot",
	},
	tiptest = {
		humanName = "TIP test unit",
		description = "bla",
	},
	armpw = {
		humanName = "Glaive",
		description = "Light Raider Bot",
	},
	striderhub = {
		humanName = "Strider Hub",
		description = "Constructs Striders, Builds at 10 m/s",
	},
	spiderriot = {
		humanName = "Redback",
		description = "Riot Spider",
	},
	spiderassault = {
		humanName = "Hermit",
		description = "All Terrain Assault Bot",
	},
	gunshipaa = {
		humanName = "Trident",
		description = "Anti-Air Gunship",
	},
	corclog = {
		humanName = "Dirtbag",
		description = "Box of Dirt",
	},
	dynhub_recon_base = {
		humanName = "Recon Support",
		description = "High Mobility Commander",
	},
	hoverminer = {
		humanName = "Dampener",
		description = "Minelaying Hover",
	},
	shiptorpraider = {
		humanName = "Hunter",
		description = "Torpedo-Boat (Raider)",
	},
	spideraa = {
		humanName = "Tarantula",
		description = "Anti-Air Spider",
	},
	corrazor = {
		humanName = "Razor",
		description = "Hardened Anti-Air Laser",
	},
	corgol = {
		humanName = "Goliath",
		description = "Very Heavy Tank Buster",
	},
	corch = {
		humanName = "Quill",
		description = "Construction Hovercraft, Builds at 5 m/s",
	},
	armaak = {
		humanName = "Archangel",
		description = "Heavy Anti-Air Jumper",
	},
	spherepole = {
		humanName = "Scythe",
		description = "Cloaked Raider Bot",
	},
	geo = {
		humanName = "Geothermal Generator",
		description = "Medium Powerplant (+25)",
	},
	corfast = {
		humanName = "Constable",
		description = "Jumpjet Constructor, Builds at 5 m/s",
	},
	dynfancy_strike_base = {
		humanName = "Strike Trainer",
		description = "Mobile Assault Commander",
	},
	pw_guerilla = {
		humanName = "Guerilla Jumpgate",
		description = "Spreads Influence remotely",
	},
	pw_estorage = {
		humanName = "Energy Storage",
		description = "Stores energy",
	},
	armarad = {
		humanName = "Advanced Radar",
		description = "Long-Range Radar",
	},
	amphraider2 = {
		humanName = "Archer",
		description = "Amphibious Raider/Riot Bot",
	},
	shipscout = {
		humanName = "Cutter",
		description = "Picket Ship (Disarming Scout)",
	},
	pw_wormhole = {
		humanName = "Wormhole Generator",
		description = "Links this planet to nearby planets",
	},
	shipriot = {
		humanName = "Corsair",
		description = "Corvette (Raider/Riot)",
	},
	armjamt = {
		humanName = "Sneaky Pete",
		description = "Area Cloaker/Jammer",
	},
	amphbomb = {
		humanName = "Limpet",
		description = "Amphibious slow mine",
	},
	arm_venom = {
		humanName = "Venom",
		description = "Lightning Riot Spider",
	},
	factoryjump = {
		humanName = "Jump/Specialist Plant",
		description = "Produces Jumpjets and Special Walkers, Builds at 10 m/s",
	},
	armpb = {
		humanName = "Gauss",
		description = "Gauss Turret, 20 health/s when closed",
	},
	nebula = {
		humanName = "Nebula",
		description = "Atmospheric Mothership",
	},
	corfav = {
		humanName = "Dart",
		description = "Raider/Scout Vehicle",
	},
	hoveraa = {
		humanName = "Flail",
		description = "Anti-Air Hovercraft",
	},
	armham = {
		humanName = "Hammer",
		description = "Light Artillery Bot",
	},
	shipcon = {
		humanName = "Mariner",
		description = "Construction Ship, Builds at 7.5 m/s",
	},
	armsptk = {
		humanName = "Recluse",
		description = "Skirmisher Spider (Indirect Fire)",
	},
	blackdawn = {
		humanName = "Black Dawn",
		description = "Heavy Raider/Assault Gunship",
	},
	shipcarrier = {
		humanName = "Reef",
		description = "Aircraft Carrier (Bombardment), Stockpiles tacnukes at 10 m/s",
	},
	rocksink = {
		humanName = "Rocking Damage Sink thing",
		description = "Rocks when you shoot at it.",
	},
	fakeunit_aatarget = {
		humanName = "Fake AA target",
		description = "Used by the jumpjet script.",
	},
	shipassault = {
		humanName = "Siren",
		description = "Destroyer (Riot/Assault)",
	},
	pw_garrison = {
		humanName = "Field Garrison",
		description = "Reduces Influence gain",
	},
	shiparty = {
		humanName = "Ronin",
		description = "Cruiser (Artillery)",
	},
	shipaa = {
		humanName = "Zephyr",
		description = "Anti-Air Frigate",
	},
	armamd = {
		humanName = "Protector",
		description = "Strategic Nuke Interception System",
	},
	mahlazer = {
		humanName = "Starlight",
		description = "Planetary Energy Chisel",
	},
	dynhub_assault_base = {
		humanName = "Guardian Support",
		description = "Heavy Combat Commander",
	},
	armbrtha = {
		humanName = "Big Bertha",
		description = "Strategic Plasma Cannon",
	},
	armcrabe = {
		humanName = "Crabe",
		description = "Heavy Riot/Skirmish Spider - Curls into Armored Form When Stationary",
	},
	pw_inhibitor = {
		humanName = "Wormhole Inhibitor",
		description = "Blocks Influence Spread",
	},
	subscout = {
		humanName = "Lancelet",
		description = "Scout/Suicide Minisub",
	},
	armrectr = {
		humanName = "Conjurer",
		description = "Cloaked Construction Bot, Builds at 5 m/s",
	},
	seismic = {
		humanName = "Quake",
		description = "Seismic Missile",
	},
	armsnipe = {
		humanName = "Spectre",
		description = "Cloaked Skirmish/Anti-Heavy Artillery Bot",
	},
	corbhmth = {
		humanName = "Behemoth",
		description = "Plasma Artillery Battery - Requires 50 Power",
	},
	wolverine_mine = {
		humanName = "Claw",
		description = "Wolverine Mine",
	},
	scorpion = {
		humanName = "Scorpion",
		description = "Cloaked Infiltration Strider",
	},
	armmstor = {
		humanName = "Storage",
		description = "Stores Metal and Energy (500)",
	},
	roostfac = {
		humanName = "Roost",
		description = "Spawns Big Chickens",
	},
	amphriot = {
		humanName = "Scallop",
		description = "Amphibious Riot Bot (Anti-Sub)",
	},
	amphaa = {
		humanName = "Angler",
		description = "Amphibious Anti-Air Bot",
	},
	corsent = {
		humanName = "Copperhead",
		description = "Flak Anti-Air Tank",
	},
	armkam = {
		humanName = "Banshee",
		description = "Raider Gunship",
	},
	raveparty = {
		humanName = "Disco Rave Party",
		description = "Destructive Rainbow Projector",
	},
	pw_wormhole2 = {
		humanName = "Improved Wormhole",
		description = "Links this planet to nearby planets",
	},
	pw_warpjammer = {
		humanName = "Warp Jammer",
		description = "Prevents warp attacks",
	},
	spideranarchid = {
		humanName = "Anarchid",
		description = "Riot EMP Spider",
	},
	asteroid = {
		humanName = "Asteroid",
		description = "Space Rock",
	},
	corvamp = {
		humanName = "Hawk",
		description = "Air Superiority Fighter",
	},
	dynfancy_recon_base = {
		humanName = "Recon Trainer",
		description = "High Mobility Commander",
	},
	pw_warpgate = {
		humanName = "Warp Gate",
		description = "Produces warp cores",
	},
	pw_mstorage2 = {
		humanName = "Metal Storage",
		description = "Stores metal",
	},
	corlevlr = {
		humanName = "Leveler",
		description = "Riot Vehicle",
	},
	corthud = {
		humanName = "Thug",
		description = "Shielded Assault Bot",
	},
	corjamt = {
		humanName = "Aegis",
		description = "Area Shield",
	},
	missiletower = {
		humanName = "Hacksaw",
		description = "Burst Anti-Air Turret",
	},
	corpyro2 = {
		humanName = "Pyro",
		description = "Raider/Riot Jumper",
	},
	empiricaldpser = {
		humanName = "Empirical DPS thing",
		description = "Shoot at it for science.",
	},
	pw_interception = {
		humanName = "Interception Network",
		description = "Intercepts planetary bombers",
	},
	hoverassault = {
		humanName = "Halberd",
		description = "Blockade Runner Hover",
	},
	cornecro = {
		humanName = "Convict",
		description = "Shielded Construction Bot, Builds at 5 m/s",
	},
	shiptransport = {
		humanName = "Surfboard",
		description = "Transport Platform",
	},
	armwar = {
		humanName = "Warrior",
		description = "Riot Bot",
	},
	pw_grid = {
		humanName = "Planetary Defense Grid",
		description = "Defends against everything",
	},
	cafus = {
		humanName = "Singularity Reactor",
		description = "Large Powerplant (+225) - HAZARDOUS",
	},
	armstiletto_laser = {
		humanName = "Thunderbird",
		description = "Disarming Lightning Bomber",
	},
	factoryspider = {
		humanName = "Spider Factory",
		description = "Produces Spiders, Builds at 10 m/s",
	},
	amphtele = {
		humanName = "Djinn",
		description = "Amphibious Teleport Bridge",
	},
	corstorm = {
		humanName = "Rogue",
		description = "Skirmisher Bot (Indirect Fire)",
	},
	jumpimpulse = {
		humanName = "Elevator",
		description = "Impulse Shenanigans Jumpbot",
	},
	pw_estorage2 = {
		humanName = "Double Energy Storage",
		description = "Stores energy",
	},
	shipskirm = {
		humanName = "Mistral",
		description = "Rocket Boat (Skirmisher)",
	},
	pw_dropfac = {
		humanName = "Dropship Factory",
		description = "Produces dropships",
	},
	corpyro = {
		humanName = "Pyro",
		description = "Raider/Riot Jumper",
	},
	dante = {
		humanName = "Dante",
		description = "Assault/Riot Strider",
	},
	puppy = {
		humanName = "Puppy",
		description = "Walking Missile",
	},
	panther = {
		humanName = "Panther",
		description = "Lightning Assault/Raider Tank",
	},
	nest = {
		humanName = "Nest",
		description = "Spawns Chickens",
	},
	corgrav = {
		humanName = "Newton",
		description = "Gravity Turret - On to Repulse, Off to Attract",
	},
	dynhub_support_base = {
		humanName = "Engineer Support",
		description = "Econ/Support Commander",
	},
	armjeth = {
		humanName = "Gremlin",
		description = "Cloaked Anti-Air Bot",
	},
	neebcomm = {
		humanName = "Neeb Comm",
		description = "Ugly Turkey",
	},
	logkoda = {
		humanName = "Kodachi",
		description = "Raider Tank",
	},
	amgeo = {
		humanName = "Advanced Geothermal",
		description = "Large Powerplant (+100) - HAZARDOUS",
	},
	pw_gaspowerstation = {
		humanName = "Gas Power Station",
		description = "Produces Energy",
	},
	jumpblackhole2 = {
		humanName = "Hoarder",
		description = "Assault/Riot Bot",
	},
	bladew = {
		humanName = "Gnat",
		description = "Anti-Heavy EMP Drone",
	},
	terraunit = {
		humanName = "Terraform",
		description = "Spent: 0",
	},
	hoversonic = {
		humanName = "Morningstar",
		description = "Antisub Hovercraft",
	},
	armestor = {
		humanName = "Energy Pylon",
		description = "Extends overdrive grid",
	},
	hoverskirm = {
		humanName = "Trisula",
		description = "Light Assault/Battle Hovercraft",
	},
	corshad = {
		humanName = "Raven",
		description = "Precision Bomber",
	},
	pw_mine = {
		humanName = "Power Generator Unit",
		description = "Produces 50 energy/turn",
	},
	amphfloater = {
		humanName = "Buoy",
		description = "Heavy Amphibious Skirmisher Bot",
	},
	hoverscout = {
		humanName = "Dagger",
		description = "Fast Attack Hovercraft",
	},
	hoverriot = {
		humanName = "Mace",
		description = "Riot Hover",
	},
	fakeunit_los = {
		humanName = "LOS Provider",
		description = "Knows all and sees all",
	},
	armcybr = {
		humanName = "Wyvern",
		description = "Singularity Bomber",
	},
	hoverdepthcharge = {
		humanName = "Claymore",
		description = "Anti-Sub Hovercraft",
	},
	heavyturret = {
		humanName = "Sunlance",
		description = "Anti-Tank Turret - Requires 25 Power",
	},
	tacnuke = {
		humanName = "Eos",
		description = "Tactical Nuke",
	},
	bomberdive = {
		humanName = "Raven",
		description = "Precision Bomber",
	},
	funnelweb = {
		humanName = "Funnelweb",
		description = "Drone/Shield Support Strider",
	},
	firewalker = {
		humanName = "Firewalker",
		description = "Saturation Artillery Walker",
	},
	corgator = {
		humanName = "Scorcher",
		description = "Raider Vehicle",
	},
	fighterdrone = {
		humanName = "Spicula",
		description = "Fighter Drone",
	},
	amphcon = {
		humanName = "Conch",
		description = "Amphibious Construction Bot, Builds at 7.5 m/s",
	},
	bomberassault = {
		humanName = "Eclipse",
		description = "Assault Bomber (Anti-Static)",
	},
	armzeus = {
		humanName = "Zeus",
		description = "Lightning Assault Bot",
	},
	fakeunit = {
		humanName = "Fake radar signal",
		description = "Created by scrambling devices.",
	},
	armanni = {
		humanName = "Annihilator",
		description = "Tachyon Projector - Requires 50 Power",
	},
	factoryveh = {
		humanName = "Light Vehicle Factory",
		description = "Produces Wheeled Vehicles, Builds at 10 m/s",
	},
	armsolar = {
		humanName = "Solar Collector",
		description = "Small Powerplant (+2)",
	},
	armbrawl = {
		humanName = "Brawler",
		description = "Fire Support Gunship",
	},
	arm_spider = {
		humanName = "Weaver",
		description = "Construction Spider, Builds at 7.5 m/s",
	},
	jumpblackhole = {
		humanName = "Placeholder",
		description = "Black Hole Launcher",
	},
	corned = {
		humanName = "Mason",
		description = "Construction Vehicle, Builds at 5 m/s",
	},
	factoryshield = {
		humanName = "Shield Bot Factory",
		description = "Produces Tough Robots, Builds at 10 m/s",
	},
	factoryplane = {
		humanName = "Airplane Plant",
		description = "Produces Airplanes, Builds at 10 m/s",
	},
	shipheavyarty = {
		humanName = "Shogun",
		description = "Battleship (Heavy Artillery)",
	},
	armraz = {
		humanName = "Razorback",
		description = "Assault/Riot Strider",
	},
	factorygunship = {
		humanName = "Gunship Plant",
		description = "Produces Gunships, Builds at 10 m/s",
	},
	factoryhover = {
		humanName = "Hovercraft Platform",
		description = "Produces Hovercraft, Builds at 10 m/s",
	},
	factorycloak = {
		humanName = "Cloaky Bot Factory",
		description = "Produces Cloaky Robots, Builds at 10 m/s",
	},
	empmissile = {
		humanName = "Shockley",
		description = "EMP missile",
	},
	nsaclash = {
		humanName = "Scalpel",
		description = "Skirmisher/Anti-Heavy Hovercraft",
	},
	cobtransport = {
		humanName = "Valkyrie",
		description = "Air Transport",
	},
	assaultcruiser = {
		humanName = "Vanquisher",
		description = "Heavy Cruiser (Assault)",
	},
	corsktl = {
		humanName = "Skuttle",
		description = "Cloaked Jumping Anti-Heavy Bomb",
	},
	armcarry = {
		humanName = "Reef (Classic)",
		description = "Aircraft Carrier (Bombardment) & Anti-Nuke",
	},
	slowmort = {
		humanName = "Moderator",
		description = "Disruptor Skirmisher Walker",
	},
	fighter = {
		humanName = "Swift",
		description = "Multi-role Fighter",
	},
	dynfancy_support_base = {
		humanName = "Engineer Trainer",
		description = "Econ/Support Commander",
	},
	capturecar = {
		humanName = "Dominatrix",
		description = "Capture Vehicle",
	},
	factorytank = {
		humanName = "Heavy Tank Factory",
		description = "Produces Heavy and Specialized Vehicles, Builds at 10 m/s",
	},
	armbanth = {
		humanName = "Bantha",
		description = "Ranged Support Strider",
	},
	corhlt = {
		humanName = "Stinger",
		description = "High-Energy Laser Tower",
	},
	corflak = {
		humanName = "Cobra",
		description = "Anti-Air Flak Gun",
	},
	armraven = {
		humanName = "Catapult",
		description = "Heavy Saturation Artillery Strider",
	},
	armcir = {
		humanName = "Chainsaw",
		description = "Long-Range Anti-Air Missile Battery",
	},
	armartic = {
		humanName = "Faraday",
		description = "EMP Turret",
	},
	corroach = {
		humanName = "Roach",
		description = "Crawling Bomb (Burrows)",
	},
	damagesink = {
		humanName = "Damage Sink thing",
		description = "Does not care if you shoot at it.",
	},
	corvalk = {
		humanName = "Valkyrie",
		description = "Air Transport",
	},
	corsilo = {
		humanName = "Silencer",
		description = "Strategic Nuclear Launcher, Drains 18 m/s, 3 minute stockpile",
	},
	hovershotgun = {
		humanName = "Punisher",
		description = "Shotgun Hover",
	},
	corsumo = {
		humanName = "Sumo",
		description = "Heavy Riot Jumper - On to Repulse, Off to Attract",
	},
	armspy = {
		humanName = "Infiltrator",
		description = "Cloaked Scout/Anti-Heavy",
	},
	armmerl = {
		humanName = "Impaler",
		description = "Precision Artillery Vehicle",
	},
	core_spectre = {
		humanName = "Aspis",
		description = "Area Shield Walker",
	},
	corrl = {
		humanName = "Defender",
		description = "Light Missile Tower",
	},
	pw_warpgatealt = {
		humanName = "Warp Gate",
		description = "Produces warp cores",
	},
	armnanotc = {
		humanName = "Caretaker",
		description = "Static Constructor, Builds at 10 m/s",
	},
	corraid = {
		humanName = "Ravager",
		description = "Assault Vehicle",
	},
	corrad = {
		humanName = "Radar Tower",
		description = "Early Warning System",
	},
	armwin = {
		humanName = "Wind/Tidal Generator",
		description = "Small Powerplant",
	},
	pw_artefact = {
		humanName = "Ancient Artefact",
		description = "Mysterious Relic",
	},
	armca = {
		humanName = "Crane",
		description = "Construction Aircraft, Builds at 4 m/s",
	},
	corcrash = {
		humanName = "Vandal",
		description = "Anti-Air Bot",
	},
	corak = {
		humanName = "Bandit",
		description = "Medium-Light Raider Bot",
	},
	amphraider3 = {
		humanName = "Duck",
		description = "Amphibious Raider Bot (Anti-Sub)",
	},
	corgarp = {
		humanName = "Wolverine",
		description = "Artillery Minelayer Vehicle",
	},
	armcomdgun = {
		humanName = "Ultimatum",
		description = "Cloaked Anti-Heavy/Anti-Strider Walker",
	},
	corhurc2 = {
		humanName = "Phoenix",
		description = "Saturation Napalm Bomber",
	},
	cormex = {
		humanName = "Metal Extractor",
		description = "Produces Metal",
	},
	armorco = {
		humanName = "Detriment",
		description = "Ultimate Assault Strider",
	},
	bomberstrike = {
		humanName = "Kestrel",
		description = "Tactical Strike Bomber",
	},
	armcsa = {
		humanName = "Athena",
		description = "Airborne SpecOps Engineer, Builds at 7.5 m/s",
	},
	armasp = {
		humanName = "Air Repair/Rearm Pad",
		description = "Repairs and Rearms Aircraft, repairs at 2.5 e/s per pad",
	},
	cormist = {
		humanName = "Slasher",
		description = "Deployable Missile Vehicle (must stop to fire)",
	},
	amphraider = {
		humanName = "Grebe",
		description = "Amphibious Raider Bot",
	},
	corcan = {
		humanName = "Jack",
		description = "Melee Assault Jumper",
	},
	armsonar = {
		humanName = "Sonar Station",
		description = "Locates Water Units",
	},
	bomberlaser = {
		humanName = "Pheonix with mini-laser",
		description = "Napalm Bomber",
	},
	amphassault = {
		humanName = "Grizzly",
		description = "Heavy Amphibious Assault Walker",
	},
	armmanni = {
		humanName = "Penetrator",
		description = "Anti-Heavy Artillery Hovercraft",
	},
	corbtrans = {
		humanName = "Vindicator",
		description = "Armed Heavy Air Transport",
	},
	corawac = {
		humanName = "Vulture",
		description = "Area Jammer, Radar/Sonar Plane",
	},
	armdeva = {
		humanName = "Stardust",
		description = "Anti-Swarm Turret",
	},
}

return {
	nameList = nameList,
	humanNames = humanNames
}