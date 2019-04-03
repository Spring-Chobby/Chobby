
local planetUtilities = {}

planetUtilities.planetImages = {
	LUA_DIRNAME .. "images/planets/arid01.png",
	LUA_DIRNAME .. "images/planets/barren01.png",
	LUA_DIRNAME .. "images/planets/barren02.png",
	LUA_DIRNAME .. "images/planets/barren03.png",
	LUA_DIRNAME .. "images/planets/desert01.png",
	LUA_DIRNAME .. "images/planets/desert02.png",
	LUA_DIRNAME .. "images/planets/desert03.png",
	LUA_DIRNAME .. "images/planets/inferno01.png",
	LUA_DIRNAME .. "images/planets/inferno02.png",
	LUA_DIRNAME .. "images/planets/inferno03.png",
	LUA_DIRNAME .. "images/planets/inferno04.png",
	LUA_DIRNAME .. "images/planets/ocean01.png",
	LUA_DIRNAME .. "images/planets/ocean02.png",
	LUA_DIRNAME .. "images/planets/ocean03.png",
	LUA_DIRNAME .. "images/planets/radiated01.png",
	LUA_DIRNAME .. "images/planets/radiated02.png",
	LUA_DIRNAME .. "images/planets/radiated03.png",
	LUA_DIRNAME .. "images/planets/swamp01.png",
	LUA_DIRNAME .. "images/planets/swamp02.png",
	LUA_DIRNAME .. "images/planets/swamp03.png",
	LUA_DIRNAME .. "images/planets/terran01.png",
	LUA_DIRNAME .. "images/planets/terran02.png",
	LUA_DIRNAME .. "images/planets/terran03.png",
	LUA_DIRNAME .. "images/planets/terran03_damaged.png",
	LUA_DIRNAME .. "images/planets/terran04.png",
	LUA_DIRNAME .. "images/planets/tundra01.png",
	LUA_DIRNAME .. "images/planets/tundra02.png",
	LUA_DIRNAME .. "images/planets/tundra03.png",
	LUA_DIRNAME .. "images/planets/46.png",	
}

planetUtilities.backgroundImages = {
	LUA_DIRNAME .. "images/starbackgrounds/1.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/2.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/3.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/4.jpg",
}

planetUtilities.MAIN_EXP = 100
planetUtilities.BONUS_EXP = 25

planetUtilities.PLANET_SIZE_MAP = 36
planetUtilities.PLANET_SIZE_INFO = 200 --240
planetUtilities.ICON_DIR = LUA_DIRNAME .. "configs/gameConfig/tc/unitpics/"

planetUtilities.planetPositions = {
[1] = {850, 800},
[2] = {760, 900},
[3] = {670, 850},
[4] = {550, 950},
[5] = {625, 700},
[6] = {775, 400},
[7] = {895, 300},
}

for i = 1, #planetUtilities.planetPositions do
	local planet = planetUtilities.planetPositions[i]
	planet[1], planet[2] = planet[1]/1000, planet[2]/1000
end

planetUtilities.DEFAULT_RESOURCES = {
	metal = 100,
	energy = 100,
}

planetUtilities.COMMAND = {
	CAPTURE = 130,
	GROUPADD = 36,
	OPT_SHIFT = 32,
	PATROL = 15,
	STOP = 0,
	OPT_META = 4,
	RESURRECT = 125,
	GUARD = 25,
	INSERT = 1,
	FIGHT = 16,
	LOAD_UNITS = 75,
	RESTORE = 110,
	OPT_ALT = 128,
	INTERNAL = 60,
	OPT_INTERNAL = 8,
	MOVESTATE_HOLDPOS = 0,
	OPT_CTRL = 64,
	WAITCODE_DEATH = 2,
	MOVE_STATE = 50,
	WAIT = 5,
	OPT_RIGHT = 16,
	LOOPBACKATTACK = 20,
	AUTOREPAIRLEVEL = 135,
	SQUADWAIT = 8,
	TRAJECTORY = 120,
	MOVESTATE_ROAM = 2,
	REPEAT = 115,
	FIRE_STATE = 45,
	LOAD_ONTO = 76,
	UNLOAD_UNIT = 81,
	TIMEWAIT = 6,
	REMOVE = 2,
	MOVE = 10,
	GROUPCLEAR = 37,
	MANUALFIRE = 105,
	STOCKPILE = 100,
	GROUPSELECT = 35,
	FIRESTATE_FIREATNEUTRAL = 3,
	RECLAIM = 90,
	MOVESTATE_MANEUVER = 1,
	ONOFF = 85,
	FIRESTATE_NONE = -1,
	FIRESTATE_RETURNFIRE = 1,
	FIRESTATE_HOLDFIRE = 0,
	GATHERWAIT = 9,
	IDLEMODE = 145,
	MOVESTATE_NONE = -1,
	AISELECT = 30,
	SET_WANTED_MAX_SPEED = 70,
	FIRESTATE_FIREATWILL = 2,
	SETBASE = 55,
	WAITCODE_GATHER = 4,
	UNLOAD_UNITS = 80,
	DEATHWAIT = 7,
	REPAIR = 40,
	AREA_ATTACK = 21,
	WAITCODE_TIME = 1,
	WAITCODE_SQUAD = 3,
	ATTACK = 20,
	
	-- Custom commands
	RAW_MOVE = 31109,
	JUMP = 38521,
}

planetUtilities.ICON_OVERLAY = {
	ATTACK = LUA_DIRNAME .. "images/attack.png",
	GUARD = LUA_DIRNAME .. "images/guard.png",
	REPAIR = LUA_DIRNAME .. "images/repair.png",
	CLOCK = LUA_DIRNAME .. "images/clock.png",
	ALL = LUA_DIRNAME .. "images/battle.png",
}

planetUtilities.DIFFICULTY = {
	EASY = 1,
	MEDIUM = 2,
	HARD = 3,
	BRUTAL = 4,
}

planetUtilities.FACING = {
	SOUTH = 0,
	EAST = 1,
	NORTH = 2,
	WEST = 3,
}

planetUtilities.TERRAFORM_SHAPE = {
	RECTANGLE = 1,
	LINE = 2,
	RAMP = 3,
}

planetUtilities.TERRAFORM_TYPE = {
	LEVEL = 1,
	RAISE = 2,
	SMOOTH = 3,
}

planetUtilities.TERRAFORM_VOLUME = {
	NONE = 0,
	RAISE_ONLY = 1,
	LOWER_ONLY = 2,
}

planetUtilities.COMPARE = {
	AT_LEAST = 1,
	AT_MOST = 2
}

return planetUtilities
