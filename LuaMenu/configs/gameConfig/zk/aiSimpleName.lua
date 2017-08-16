
local subnameMap = {
	{"CircuitAIBeginner", "AI: Beginner"},
	{"CircuitAIVeryEasy", "AI: Very Easy"},
	{"CircuitAIEasy", "AI: Easy"},
	{"CircuitAIMedium", "AI: Medium"},
	{"CircuitAIHard", "AI: Hard"},
	{"CircuitAIBrutal", "AI: Brutal"},
}

local function GetAiSimpleName(name)
	if name == "Null AI" then
		return "Inactive AI"
	end
	if string.find(name, "Chicken") then
		return name
	end
	for i = 1, #subnameMap do
		if string.find(name, subnameMap[i][1]) then
			return subnameMap[i][2]
		end
	end
	return false
end

local simpleAiOrder = {
	["AI: Beginner"] = 0,
	["AI: Very Easy"] = 1,
	["AI: Easy"] = 2,
	["AI: Medium"] = 3,
	["AI: Hard"] = 4,
	["AI: Brutal"] = 5,
	["Inactive AI"] = 6,
	["Chicken: Very Easy"] = 7,
	["Chicken: Easy"] = 8,
	["Chicken: Normal"] = 9,
	["Chicken: Hard"] = 10,
	["Chicken: Suicidal"] = 11,
	["Chicken: Custom"] = 12,
}

local aiTooltip = {
	["AI: Beginner"] = 0,
	["AI: Very Easy"] = 1,
	["AI: Easy"] = 2,
	["AI: Medium"] = 3,
	["AI: Hard"] = 4,
	["AI: Brutal"] = 5,
	["Inactive AI"] = "This AI does nothing after spawning.",
	["Chicken: Very Easy"] = "Easiest ",
	["Chicken: Easy"] = 8,
	["Chicken: Normal"] = 9,
	["Chicken: Hard"] = 10,
	["Chicken: Suicidal"] = 11,
	["Chicken: Custom"] = 12,
}

return {
	GetAiSimpleName = GetAiSimpleName,
	simpleAiOrder = simpleAiOrder,
	aiTooltip = aiTooltip
}
