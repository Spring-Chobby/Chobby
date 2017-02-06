-- TODO: migrate this stuff to external def file
local planetImages = {
	LUA_DIRNAME .. "images/planets/arid01.png",
	LUA_DIRNAME .. "images/planets/barren01.png",
	LUA_DIRNAME .. "images/planets/barren03.png",
	LUA_DIRNAME .. "images/planets/terran01.png",
	LUA_DIRNAME .. "images/planets/terran03_damaged.png",
	LUA_DIRNAME .. "images/planets/tundra01.png",
	LUA_DIRNAME .. "images/planets/tundra03.png",
}

local backgroundImages = {
	LUA_DIRNAME .. "images/starbackgrounds/1.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/2.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/3.jpg",
	LUA_DIRNAME .. "images/starbackgrounds/4.jpg",
}

local planetPositions = {
	{0.22, 0.1},
	{0.31, 0.19},
	{0.3, 0.36},
	{0.14, 0.44},
	{0.05, 0.54},
	{0.3, 0.52},
	{0.24, 0.69},
	{0.16, 0.91},
	{0.27, 0.85},
	{0.7, 0.9},
	{0.56, 0.87},
	{0.42, 0.72},
	{0.64, 0.79},
	{0.59, 0.66},
	{0.61, 0.52},
	{0.66, 0.35},
	{0.47, 0.11},
	{0.64, 0.19},
	{0.72, 0.08},
	{0.72, 0.66},
	{0.79, 0.52},
	{0.85, 0.35},
	{0.89, 0.22},
	{0.92, 0.63},
	{0.41, 0.91},
}

local PLANET_SIZE_MAP = 54
local PLANET_SIZE_INFO = 240

local function MakePlanet(planetID)
	local image = planetImages[math.floor(math.random()*#planetImages) + 1]
	
	local planetData = {
		name = "Pong",
		mapDisplay = {
			x = planetPositions[planetID][1],
			y = planetPositions[planetID][2],
			image = image,
			size = PLANET_SIZE_MAP,
		},
		infoDisplay = {
			image = image,
			size = PLANET_SIZE_INFO,
			backgroundImage = backgroundImages[math.floor(math.random()*#backgroundImages) + 1],
			terrainType = "Terran",
			radius = "6700 km",
			primary = "Tau Ceti",
			primaryType = "G8",
			milRating = 1,
			text = [[Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
			Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.
			Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
			Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.]]
		}
	}
	
	return planetData
end

local planets = {}
for i = 1, #planetPositions do
	planets[i] = MakePlanet(i)
end

return planets
