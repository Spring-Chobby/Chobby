local shortname = "sample"

local N_PLANETS = 65

local planetEdgeList = {
	{1,2},
	{2,3},
	{2,5},
	{3,4},
	{3,7},
	{4,8},
	{5,6},
	{5,12},
	{6,18},
	{6,20},
	{7,8},
	{7,9},
	{7,17},
	{8,10},
	{9,10},
	{9,11},
	--{10,36},
	--{11,40},
	{12,13},
	{12,17},
	{12,19},
	{13,14},
	{13,16},
	--{14,15},
	{14,19},
	--{14,43},
	{15,25},
	--{16,40},
	{18,19},
	--{19,26},
	--{20,21},
	{21,22},
	{21,29},
	{22,23},
	{23,24},
	{24,30},
	{25,34},
	{25,47},
	{26,27},
	{26,28},
	{26,29},
	{27,30},
	{28,34},
	{21,30},
	{30,31},
	{30,33},
	{31,32},
	{33,34},
	{33,35},
	{34,35},
	{34,48},
	{35,51},
	{36,37},
	{36,38},
	{37,41},
	{38,39},
	{39,52},
	{40,41},
	{41,42},
	{41,43},
	{42,53},
	{43,44},
	{44,45},
	{44,47},
	{45,46},
	{45,53},
	{45,54},
	{46,52},
	{46,54},
	{46,58},
	{47,48},
	{48,49},
	{48,50},
	{48,54},
	{49,51},
	{50,51},
	{50,58},
	{51,57},
	{52,53},
	{32,55},
	{55,56},
	{56,57},
	{57,59},
	{57,61},
	{58,59},
	{58,60},
	{60,62},
	{61,62},
	{62,63},
	{62,64},
	{63,65},
	{64,65},
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
	planets[i] = VFS.Include("campaign/" .. shortname .. "/planets/planet" .. i .. ".lua")(planetUtilities)
	planets[i].index = i
end

local initialPlanets = {}

for i = 1, #planets do
	if planets[i].startingPlanetCaptured then
		initialPlanets[#initialPlanets + 1] = i
	end
end

local retData = {
	planets = planets,
	planetAdjacency = planetAdjacency,
	planetEdgeList = planetEdgeList,
	initialPlanets = initialPlanets,
}

return retData
