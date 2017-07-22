
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
}

planetUtilities.backgroundImages = {
	LUA_DIRNAME .. "images/starbackgrounds/1.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/2.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/3.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/4.jpg",
}

planetUtilities.PLANET_SIZE_MAP = 36
planetUtilities.PLANET_SIZE_INFO = 240
planetUtilities.ICON_DIR = LUA_DIRNAME .. "configs/gameConfig/zk/unitpics/"

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
	AREA_GUARD = 13922,
}

planetUtilities.ICON_OVERLAY = {
	ATTACK = LUA_DIRNAME .. "images/attack.png",
	GUARD = LUA_DIRNAME .. "images/guard.png",
	REPAIR = LUA_DIRNAME .. "images/repair.png",
	CLOCK = LUA_DIRNAME .. "images/clock.png",
	ALL = LUA_DIRNAME .. "images/battle.png",
}

planetUtilities.COMPARE = {
	AT_LEAST = 1,
	AT_MOST = 2
}

return planetUtilities