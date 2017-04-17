local chassis = "knight"

local function GetLevelRequirement(level)
	return 20*level^2 + 80*level - 100
end

return {
	chassis = chassis,
	GetLevelRequirements = GetLevelRequirements,
}