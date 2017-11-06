local shortname = "sample"

local N_PLANETS = 69

planetEdgeList = {
	{01, 02},
	{02, 03},
	{02, 05},
	{03, 04},
	{03, 09},
	{04, 08},
	{05, 06},
	{05, 13},
	{06, 07},
	{06, 20},
	{07, 22},
	{08, 43},
	{09, 08},
	{09, 10},
	{09, 19},
	{10, 11},
	{10, 12},
	{11, 36},
	{11, 43},
	{12, 37},
	{12, 40},
	{12, 52},
	{13, 14},
	{13, 15},
	{13, 19},
	{14, 17},
	{14, 16},
	{15, 26},
	{16, 40},
	{16, 52},
	{17, 15},
	{17, 18},
	{17, 29},
	{18, 21},
	{18, 26},
	{19, 52},
	{20, 26},
	{20, 22},
	{21, 34},
	{21, 48},
	{22, 25},
	{22, 23},
	{23, 24},
	{24, 30},
	{25, 30},
	{26, 27},
	{26, 28},
	{27, 30},
	{27, 53},
	{28, 34},
	{28, 53},
	{29, 44},
	{30, 31},
	{30, 33},
	{31, 32},
	{32, 57},
	{32, 60},
	{33, 34},
	{33, 35},
	{33, 53},
	{34, 35},
	{34, 49},
	{35, 55},
	{36, 37},
	{36, 38},
	{37, 41},
	{37, 54},
	{38, 39},
	{39, 54},
	{39, 56},
	{40, 41},
	{41, 29},
	{41, 42},
	{42, 46},
	{42, 54},
	{44, 45},
	{44, 48},
	{45, 46},
	{45, 47},
	{46, 56},
	{47, 49},
	{47, 62},
	{47, 58},
	{48, 49},
	{49, 50},
	{49, 62},
	{50, 51},
	{50, 55},
	{51, 61},
	{51, 63},
	{55, 61},
	{56, 59},
	{57, 67},
	{58, 59},
	{58, 63},
	{58, 66},
	{59, 66},
	{60, 67},
	{61, 64},
	{63, 62},
	{63, 64},
	{64, 65},
	{65, 68},
	{01, 69},
}

local planetAdjacency = {}

-- Create the matrix
for i = 1, N_PLANETS do
	planetAdjacency[i] = {}
	for j = 1, N_PLANETS do
		planetAdjacency[i][j] = false
	end
end

-- Populate the matrix
for i = 1, #planetEdgeList do
	planetAdjacency[planetEdgeList[i][1]][planetEdgeList[i][2]] = true
	planetAdjacency[planetEdgeList[i][2]][planetEdgeList[i][1]] = true
end

local planets = {}
local planetUtilities = VFS.Include("campaign/" .. shortname .. "/planetUtilities.lua")
for i = 1, N_PLANETS do
	planets[i] = VFS.Include("campaign/" .. shortname .. "/planets/planet" .. i .. ".lua")(planetUtilities, i)
	planets[i].index = i
end

-- Apply Defaults
local function ApplyDefaults(teamData)
	if not teamData.startMetal then
		teamData.startMetal = planetUtilities.DEFAULT_RESOURCES.metal
	end
	if not teamData.startEnergy then
		teamData.startEnergy = planetUtilities.DEFAULT_RESOURCES.energy
	end
end

for i = 1, #planets do
	local planetData = planets[i]
	
	-- Player defaults
	ApplyDefaults(planetData.gameConfig.playerConfig)
	
	-- AI defaults
	local aiConfig = planetData.gameConfig.aiConfig
	for j = 1, #aiConfig do
		ApplyDefaults(aiConfig[j])
	end
end

local initialPlanets = {}
for i = 1, #planets do
	if planets[i].startingPlanetCaptured then
		initialPlanets[#initialPlanets + 1] = i
	end
end

local startingPlanetMaps = {}
for i = 1, #planets do
	if planets[i].startingPlanet or planets[i].startingPlanetCaptured then
		startingPlanetMaps[#startingPlanetMaps + 1] = planets[i].gameConfig.mapName
	end
end

local retData = {
	planets = planets,
	planetAdjacency = planetAdjacency,
	planetEdgeList = planetEdgeList,
	initialPlanets = initialPlanets,
	startingPlanetMaps = startingPlanetMaps,
}

return retData
