
local subnameMap = {
	{"CircuitAIVeryEasy", "AI: Very Easy"},
	{"CircuitAIEasy", "AI: Easy"},
	{"CircuitAIMedium", "AI: Medium"},
	{"CircuitAIHard", "AI: Hard"},
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
	["AI: Very Easy"] = 1,
	["AI: Easy"] = 2,
	["AI: Medium"] = 3,
	["AI: Hard"] = 4,
	["Inactive AI"] = 5,
	["Chicken: Very Easy"] = 6,
	["Chicken: Easy"] = 7,
	["Chicken: Normal"] = 8,
	["Chicken: Hard"] = 9,
	["Chicken: Suicidal"] = 10,
	["Chicken: Custom"] = 11,
}

return {
	GetAiSimpleName = GetAiSimpleName,
	simpleAiOrder = simpleAiOrder
}
