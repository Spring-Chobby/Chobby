local shortname = "sample"

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

local planets = {}
local planetUtilities = VFS.Include("campaign/" .. shortname .. "/planetUtilities.lua")
for i = 1, 25 do
	planets[i] = VFS.Include("campaign/" .. shortname .. "/planets/planet" .. i .. ".lua")(planetUtilities)
	planets[i].id = ("planet" .. i)
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
