local shortname = "sample"

local N_PLANETS = 68

local planetEdgeList = {
	{01,02},
	{02,03},
	{02,05},
	{03,04},
	{03,09},
	{04,07},
	{05,06},
	{05,13},
	{06,08},
	{06,20},
	{09,07},
	{09,10},
	{09,19},
	{07,11},
	{10,11},
	{10,12},
	{11,36},
	{12,40},
	{13,14},
	{13,19},
	{13,15},
	{14,17},
	{14,16},
	{17,18},
	{17,15},
	{17,43},
	{18,21},
	{16,40},
	{16,52},
	{19,52},
	{08,15},
	{15,26},
	{20,22},
	{22,23},
	{22,29},
	{23,24},
	{24,25},
	{25,30},
	{21,34},
	{21,48},
	{26,27},
	{26,28},
	{26,29},
	{27,30},
	{27,53},
	{28,34},
	{28,53},
	{22,30},
	{30,31},
	{30,33},
	{31,32},
	{32,57},
	{32,67},
	{33,34},
	{33,35},
	{33,53},
	{34,35},
	{34,49},
	{35,55},
	{36,37},
	{36,38},
	{37,41},
	{37,54},
	{38,39},
	{39,56},
	{40,41},
	{41,42},
	{41,43},
	{42,46},
	{42,54},
	{43,44},
	{44,45},
	{44,48},
	{45,58},
	{45,46},
	{45,47},
	{58,47},
	{58,63},
	{58,59},
	{58,66},
	{48,49},
	{49,50},
	{49,47},
	{49,62},
	{50,51},
	{50,55},
	{51,61},
	{51,63},
	{55,61},
	{56,46},
	{56,59},
	{57,60},
	{57,67},
	{60,61},
	{61,64},
	{63,62},
	{63,64},
	{64,65},
	{65,68},
	{59,66},
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
