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

local planetAdjacency = {
	{},
	{1},
	{0, 1},
	{0, 0, 1},
	{0, 0, 0, 1},
	{0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 1, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0},
	{0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
}

local planetEdgeList = {}
-- Complete the matrix
for i = 1, #planetAdjacency do
	local row = planetAdjacency[i]
	row[i] = 0
	for j = i + 1, #planetAdjacency do
		row[j] = planetAdjacency[j][i]
	end
end

-- Convert to true/false and make edge list
for i = 1, #planetAdjacency do
	for j = 1, #planetAdjacency do
		planetAdjacency[j][i] = (planetAdjacency[j][i] == 1)
	end
end

-- Make edge list
for i = 1, #planetAdjacency do
	for j = i + 1, #planetAdjacency do
		if planetAdjacency[j][i] then
			planetEdgeList[#planetEdgeList + 1] = {j, i}
		end
	end
end

local PLANET_SIZE_MAP = 48
local PLANET_SIZE_INFO = 240

local function MakePlanet(planetID)
	local image = planetImages[math.floor(math.random()*#planetImages) + 1]
	
	local planetData = {
		id = "planet" .. planetID,
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
		},
		gameConfig = {
			missionStartscript = false,
			mapName = "TitanDuel",
			playerConfig = {
				startX = 400,
				startZ = 400,
				allyTeam = 0,
				useUnlocks = true,
				facplop = true,
				extraUnlocks = {
					"factoryshield",
					"shieldfelon",
					"armdeva",
					"armfus",
					"corllt",
				},
				startUnits = {
					{
						name = "corllt",
						x = 1000,
						z = 300,
						facing = 2,
					},
					{
						name = "armfus",
						x = 1000,
						z = 500,
						facing = 1,
					},
					{
						name = "armfus",
						x = 1200,
						z = 500,
						facing = 0,
					},
					{
						name = "armnanotc",
						x = 1000,
						z = 400,
						facing = 2,
					},
					{
						name = "armwar",
						x = 850,
						z = 850,
						facing = 0,
					},
					{
						name = "armwar",
						x = 900,
						z = 850,
						facing = 0,
					},
					{
						name = "armwar",
						x = 850,
						z = 900,
						facing = 0,
					},
					{
						name = "armwar",
						x = 900,
						z = 900,
						facing = 0,
					},
					{
						name = "corsktl",
						x = 4210,
						z = 4670,
						facing = 0,
					},
					{
						name = "corsktl",
						x = 300,
						z = 300,
						facing = 0,
					},
				}
			},
			aiConfig = {
				{
					startX = 200,
					startZ = 200,
					aiLib = "CircuitAIHard",
					humanName = "Ally",
					bitDependant = true,
					facplop = false,
					allyTeam = 0,
					unlocks = {
						"factorycloak",
						"corllt",
						"cormex",
						"armsolar",
						"armpw",
						"armrock",
						"armwar",
						"armham",
					}
				},
				{
					startX = 250,
					startZ = 250,
					aiLib = "CircuitAIHard",
					humanName = "Another Ally",
					bitDependant = true,
					facplop = false,
					allyTeam = 0,
					unlocks = {
						"factorycloak",
						"corllt",
						"cormex",
						"armsolar",
						"armpw",
					}
				},
				{
					startX = 3200,
					startZ = 3200,
					aiLib = "CircuitAIHard",
					humanName = "Mortal Enemy",
					bitDependant = true,
					facplop = true,
					allyTeam = 1,
					unlocks = {
						"factorycloak",
						"corllt",
						"cormex",
						"armsolar",
						"armwar",
					}
				},
			},
		},
		completionReward = {
			units = {
				"cafus",
			},
			modules = {
			},
		}
	}
	
	return planetData
end

local planets = {}
for i = 1, #planetPositions do
	planets[i] = MakePlanet(i)
end

return {planets = planets, planetAdjacency = planetAdjacency, planetEdgeList = planetEdgeList}
