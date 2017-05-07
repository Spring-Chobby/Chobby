local shortname = "sample"

local N_PLANETS = 21

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
	{6,19},
	{7,8},
	{7,9},
	{7,17},
	{9,10},
	{9,11},
	{12,13},
	{12,17},
	{13,14},
	{13,16},
	{14,15},
	{18,20},
	{19,20},
	{20,21},
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
