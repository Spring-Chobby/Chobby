local nameList = {
	[1] = 'bug_big',
	[2] = 'bug_larva',
	[3] = 'bug_med',
	[4] = 'euf_aatank',
	[5] = 'euf_aatower_survival',
	[6] = 'euf_aatower',
	[7] = 'euf_airport',
	[8] = 'euf_angel',
	[9] = 'euf_artytower',
	[10] = 'euf_barracks_ai',
	[11] = 'euf_barracks',
	[12] = 'euf_bazooka',
	[13] = 'euf_bomber',
	[14] = 'euf_bunker_ai',
	[15] = 'euf_bunker',
	[16] = 'euf_church',
	[17] = 'euf_constructor_ai',
	[18] = 'euf_constructor_lvl2_ai',
	[19] = 'euf_constructor_lvl2',
	[20] = 'euf_constructor',
	[21] = 'euf_factory_ai',
	[22] = 'euf_factory',
	[23] = 'euf_hover',
	[24] = 'euf_interceptor',
	[25] = 'euf_lasertower_ai',
	[26] = 'euf_lasertower',
	[27] = 'euf_marine',
	[28] = 'euf_metalextractor_lvl1',
	[29] = 'euf_metalextractor_lvl2',
	[30] = 'euf_mlrs_ai',
	[31] = 'euf_mlrs',
	[32] = 'euf_paladin_ai',
	[33] = 'euf_paladin',
	[34] = 'euf_plasmatower_survival',
	[35] = 'euf_plasmatower',
	[36] = 'euf_powerplant',
	[37] = 'euf_priest',
	[38] = 'euf_pyro',
	[39] = 'euf_radar_lvl1',
	[40] = 'euf_radar_lvl2',
	[41] = 'euf_raider',
	[42] = 'euf_sanctum',
	[43] = 'euf_sarge_lvl1',
	[44] = 'euf_sarge_lvl10',
	[45] = 'euf_sarge_lvl2',
	[46] = 'euf_sarge_lvl3',
	[47] = 'euf_sarge_lvl4',
	[48] = 'euf_sarge_lvl5',
	[49] = 'euf_sarge_lvl6',
	[50] = 'euf_sarge_lvl7',
	[51] = 'euf_sarge_lvl8',
	[52] = 'euf_sarge_lvl9',
	[53] = 'euf_sarge',
	[54] = 'euf_scorpion_ai',
	[55] = 'euf_scorpion_burrowed',
	[56] = 'euf_scorpion',
	[57] = 'euf_scout',
	[58] = 'euf_scoutdrone',
	[59] = 'euf_sensorbot',
	[60] = 'euf_sniper_ai',
	[61] = 'euf_sniper',
	[62] = 'euf_solar',
	[63] = 'euf_start',
	[64] = 'euf_storage',
	[65] = 'euf_tank',
	[66] = 'euf_techcenter_shield_ai',
	[67] = 'euf_techcenter_shield',
	[68] = 'euf_techcenter',
	[69] = 'euf_transport',
	[70] = 'euf_walker_ai',
	[71] = 'euf_walker',
	[72] = 'euf_wall_lvl2',
	[73] = 'euf_werewolf',
	[74] = 'euf_wolf',
	[75] = 'pig',
	[76] = 'tc_acranius',
	[77] = 'tc_agares',
	[78] = 'tc_altar',
	[79] = 'tc_belial',
	[80] = 'tc_blade',
	[81] = 'tc_bonebeast',
	[82] = 'tc_crawler',
	[83] = 'tc_cursedhand_survival',
	[84] = 'tc_cursedhand',
	[85] = 'tc_damnedportal_ai',
	[86] = 'tc_damnedportal',
	[87] = 'tc_darkassembler',
	[88] = 'tc_deathwalker',
	[89] = 'tc_defender_survival',
	[90] = 'tc_defender',
	[91] = 'tc_dragon',
	[92] = 'tc_dragonqueen',
	[93] = 'tc_enforcer',
	[94] = 'tc_ghoul',
	[95] = 'tc_gunner',
	[96] = 'tc_heart_ai',
	[97] = 'tc_heart',
	[98] = 'tc_hellfire',
	[99] = 'tc_kaboom',
	[100] = 'tc_lich_ai',
	[101] = 'tc_lich_sum',
	[102] = 'tc_lich',
	[103] = 'tc_mage',
	[104] = 'tc_mancubus',
	[105] = 'tc_mermeoth',
	[106] = 'tc_metalextractor_lvl1',
	[107] = 'tc_metalextractor_lvl2',
	[108] = 'tc_necromancer_sum',
	[109] = 'tc_necromancer',
	[110] = 'tc_obelisk_lvl2',
	[111] = 'tc_obelisk',
	[112] = 'tc_pestilence',
	[113] = 'tc_purgatory_ai',
	[114] = 'tc_purgatory',
	[115] = 'tc_pyramid_ai',
	[116] = 'tc_pyramid',
	[117] = 'tc_redeemer',
	[118] = 'tc_restless',
	[119] = 'tc_rictus',
	[120] = 'tc_seeker',
	[121] = 'tc_seer',
	[122] = 'tc_shade_lvl1',
	[123] = 'tc_shade_lvl10',
	[124] = 'tc_shade_lvl2',
	[125] = 'tc_shade_lvl3',
	[126] = 'tc_shade_lvl4',
	[127] = 'tc_shade_lvl5',
	[128] = 'tc_shade_lvl6',
	[129] = 'tc_shade_lvl7',
	[130] = 'tc_shade_lvl8',
	[131] = 'tc_shade_lvl9',
	[132] = 'tc_shade',
	[133] = 'tc_skeleton',
	[134] = 'tc_sledgehammer',
	[135] = 'tc_soulcage',
	[136] = 'tc_spiderdemon',
	[137] = 'tc_storage',
	[138] = 'tc_suicide',
	[139] = 'tc_teeth_rotated',
	[140] = 'tc_teeth_rotated2',
	[141] = 'tc_teeth',
	[142] = 'tc_tower_survival',
	[143] = 'tc_tower',
	[144] = 'tc_undeadmarine_gun',
	[145] = 'tc_undeadmarine_melee',
	[146] = 'tc_wall_lvl2',
	[147] = 'tc_witch_shield',
	[148] = 'tc_witch',
	[149] = 'euf_techcenter_nuke',
	[150] = 'tc_altar_hellstorm',
	[151] = 'tc_soulstone',	
}

local categories = {
	cloak = {
		name = "Cloakbots",
		order = 1,
	},
	shield = {
		name = "Shieldbots",
		order = 2,
	},
	veh = {
		name = "Rovers",
		order = 3,
	},
	tank = {
		name = "Tanks",
		order = 4,
	},
	hover = {
		name = "Hovercraft",
		order = 5,
	},
	amph = {
		name = "Amphbots",
		order = 6,
	},
	jump = {
		name = "Jumpbots",
		order = 7,
	},
	spider = {
		name = "Spiders",
		order = 8,
	},
	gunship = {
		name = "Gunships",
		order = 9,
	},
	plane = {
		name = "Planes",
		order = 10,
	},
	ship = {
		name = "Ships",
		order = 11,
	},
	strider = {
		name = "Striders",
		order = 12,
	},
	econ = {
		name = "Economy",
		order = 13,
	},
	defence = {
		name = "Defence",
		order = 14,
	},
	special = {
		name = "Special",
		order = 15,
	},
	missilesilo = {
		name = "Missile Silo",
		order = 16,
	},
	drone = {
		name = "Drones",
		order = 17,
	},
}

local humanNames = {
	
	-- Soldiders
	euf_barracks = {
		category = "veh",
		order = 1,
		description = "Produces Light Soliders",
		humanName = "Imperial Barracks",
	},
	
	-- Tank
	factorytank = {
		category = "tank",
		order = 1,
		description = "Produces Vehicles",
		humanName = "War Factory",
	},
	
	-- Plane
	euf_airport = {
		category = "plane",
		order = 1,
		description = "Produces VTOLs",
		humanName = "Airplane Plant",
	},
	
	-- Econ
	euf_metalextractor_lvl1 = {
		category = "econ",
		order = 1,
		description = "Produces Metal",
		humanName = "Metal Extractor",
	},
	euf_metalextractor_lvl2 = {
		category = "econ",
		order = 2,
		description = "Produces More Metal",
		humanName = "Advanced Metal Extractor",
	},
	euf_solar = {
		category = "econ",
		order = 3,
		description = "Small Powerplant",
		humanName = "Solar Collector",
	},
	euf_powerplant = {
		category = "econ",
		order = 4,
		description = "Medium Powerplant",
		humanName = "Fusion Reactor",
	},
	euf_storage = {
		category = "econ",
		order = 5,
		description = "Stores Metal and Energy",
		humanName = "Storage",
	},

	-- Defence
	euf_plasmatower = {
		category = "defence",
		order = 1,
		description = "Light Defense Tower",
		humanName = "Plasma Tower",
	},
	euf_aatower = {
		category = "defence",
		order = 2,
		description = "Anti-Air Missile Tower",
		humanName = "Missile Tower",
	},
	euf_lasertower = {
		category = "defence",
		order = 3,
		description = "Heavy Defense Tower",
		humanName = "Laser Tower",
	},
	euf_artytower = {
		category = "defence",
		order = 4,
		description = "Log-Range Defense Tower",
		humanName = "Artillery Tower",
	},
	euf_techcenter_shield = {
		category = "defence",
		order = 5,
		description = "Area Shield",
		humanName = "Shielded Technology Center",
	},
	
	-- Special
	euf_radar_lvl1 = {
		category = "special",
		order = 1,
		description = "Early Warning System",
		humanName = "Radar Tower",
	},
	euf_radar_lvl2 = {
		category = "special",
		order = 2,
		description = "Long-Range Radar",
		humanName = "Advanced Radar",
	},
	
	-- Missile Silo
	euf_techcenter_nuke = {
		category = "missilesilo",
		order = 1,
		description = "Produces Tactical Nukes",
		humanName = "Nuclear Missile Silo",
	},
	
}

--------- To Generate ------------
--[[
local inNameList = {}
local nameList = {}
local carrierDefs = VFS.Include("LuaRules/Configs/drone_defs.lua")
local function AddUnit(unitName)
	if inNameList[unitName] then
		return
	end
	inNameList[unitName] = true
	nameList[#nameList + 1] = unitName
	
	local ud = UnitDefNames[unitName]
	if ud.buildOptions then
		for i = 1, #ud.buildOptions do
			AddUnit(UnitDefs[ud.buildOptions[i] ].name)
		end
	end
	
	if ud.customParams.morphto then
		AddUnit(ud.customParams.morphto)
	end
	
	if ud.weapons then
		for i = 1, #ud.weapons do
			local wd = WeaponDefs[ud.weapons[i].weaponDef]
			if wd and wd.customParams and wd.customParams.spawns_name then
				AddUnit(wd.customParams.spawns_name)
			end
		end
	end
	
	if carrierDefs[ud.id] then
		local data = carrierDefs[ud.id]
		for i = 1, #data do
			local droneUnitDefID = data[i].drone
			if droneUnitDefID and UnitDefs[droneUnitDefID] then
				AddUnit(UnitDefs[droneUnitDefID].name)
			end
		end
	end
end

local function GenerateLists()
	AddUnit("cloakcon")
	local humanNames = {}
	for i = 1, #nameList do
		humanNames[nameList[i] ] = {
			humanName = UnitDefNames[nameList[i] ].humanName,
			description = UnitDefNames[nameList[i] ].tooltip,
		}
	end
	Spring.Echo(Spring.Utilities.TableToString(nameList, "nameList"))
	Spring.Echo(Spring.Utilities.TableToString(humanNames, "humanNames"))
end

GenerateLists()
--]]

local function UnitOrder(name1, name2)
	local data1 = name1 and humanNames[name1]
	local data2 = name1 and humanNames[name2]
	if not data1 then
		return (data2 and true)
	end
	if not data2 then
		return true
	end
	
	local category1 = categories[data1.category].order
	local category2 = categories[data2.category].order
	return category1 < category2 or (category1 == category2 and data1.order < data2.order)
end

return {
	nameList = nameList,
	humanNames = humanNames,
	categories = categories,
	UnitOrder = UnitOrder,
}