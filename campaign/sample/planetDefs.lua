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
for i = 1, #planetPositions do
	planets[i] = VFS.Include("campaign/" .. shortname .. "/planets/planet" .. 1 .. ".lua")
	planets[i].id = ("planet" .. i)
end

local initialUnlocks = {units = {}, modules = {}}
local initialPlanets = {}

local function AddUnlocks(unlockTable, unlockType)
	for i = 1, #unlockTable do
		initialUnlocks[unlockType][#initialUnlocks[unlockType] + 1] = unlockTable[i]
	end
end

for i = 1, #planets do
	if planets[i].startingPlanet then
		initialPlanets[#initialPlanets + 1] = i
		local unlocks = planets[i].completionReward
		AddUnlocks(unlocks.units, "units")
		AddUnlocks(unlocks.modules, "modules")
	end
end

local retData = {
	planets = planets,
	planetAdjacency = planetAdjacency,
	planetEdgeList = planetEdgeList,
	initialSetup = {
		planets = initialPlanets,
		unlocks = initialUnlocks,
	},
}

return retData
