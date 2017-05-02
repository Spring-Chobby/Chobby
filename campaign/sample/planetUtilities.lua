
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