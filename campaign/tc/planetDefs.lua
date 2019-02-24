local shortname = "tc"

local N_PLANETS = 6

planetEdgeList = {
	{01, 02},	
	{02, 03},
	{03, 04},
	{03, 05},
	{05, 06},	
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
	if planets[i].predownloadMap then
		startingPlanetMaps[#startingPlanetMaps + 1] = planets[i].gameConfig.mapName
	end
end

-- Print Maps
--local featuredMapList = WG.CommunityWindow.LoadStaticCommunityData().MapItems
--local mapNameMap = {}
--local subNameMap = {}
--for i = 1, #featuredMapList do
--	mapNameMap[featuredMapList[i].Name] = true
--	subNameMap[featuredMapList[i].Name:sub(0, 8)] = featuredMapList[i].Name
--end
--for i = 1, #planets do
--	local map = planets[i].gameConfig.mapName
--	if mapNameMap[map] then
--		Spring.Echo("planet map", i, map, "Featured")
--	elseif subNameMap[map:sub(0, 8)] then
--		Spring.Echo("planet map", i, map, "Unfeatured", subNameMap[map:sub(0, 8)])
--	else
--		Spring.Echo("planet map", i, map, "UnfeaturedNoReplace")
--	end
--end

-- Sum Experience
--local xpSum = 0
--local bonusSum = 0
--for i = 1, #planets do
--	xpSum = xpSum + planets[i].completionReward.experience
--	local bonus = planets[i].gameConfig.bonusObjectiveConfig or {}
--	for i = 1, #bonus do
--		bonusSum = bonusSum + bonus[i].experience
--	end
--end
--Spring.Echo("Total Experience", xpSum + bonusSum, "Main", xpSum, "Bonus", bonusSum)

local retData = {
	planets = planets,
	planetAdjacency = planetAdjacency,
	planetEdgeList = planetEdgeList,
	initialPlanets = initialPlanets,
	startingPlanetMaps = startingPlanetMaps,
}

return retData
