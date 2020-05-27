local RANK_DIR = "LuaMenu/configs/gameConfig/zk/profileimages/"

local rankMap = {
	[0] = "Nebulous",
	[1] = "Brown Dwarf",
	[2] = "Red Dwarf",
	[3] = "Subgiant",
	[4] = "Giant",
	[5] = "Supergiant",
	[6] = "Neutron Star",
	[7] = "Singularity",
}

local function GetRankAndImage(rankNumber)
	rankNumber = rankNumber or 0
	if not rankMap[rankNumber] then
		rankNumber = 0
	end
	return rankMap[rankNumber], RANK_DIR .. rankNumber .. ".png"
end

return GetRankAndImage
