
local subnameMap = {
	{"CircuitAIBeginner", "AI: Beginner"},
	{"CircuitAIEasy", "AI: Easy"},
	{"CircuitAINormal", "AI: Normal"},
	{"CircuitAIHard", "AI: Hard"},
	{"CircuitAIBrutal", "AI: Brutal"},
	{"CircuitAIInsane", "AI: Insane"},
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
	["AI: Easy"] = 1,
	["AI: Normal"] = 2,
	["AI: Hard"] = 3,
	["AI: Brutal"] = 4,
	["AI: Insane"] = 5,
	["Inactive AI"] = 6,
	["Chicken: Very Easy"] = 7,
	["Chicken: Easy"] = 8,
	["Chicken: Normal"] = 9,
	["Chicken: Hard"] = 10,
	["Chicken: Suicidal"] = 11,
	["Chicken: Custom"] = 12,
}

local aiTooltip = {
	["AI: Beginner"] = "Recommended for players with no strategy game experience.",
	["AI: Very Easy"] = "Recommended for players with some strategy game experience, or experience with related games (such as MOBA).",
	["AI: Easy"] = "Recommended for experienced strategy gamers with some experience of streaming economy.",
	["AI: Normal"] = "Recommended for veteran strategy gamers.",
	["AI: Hard"] = "Recommended for veteran strategy gamers who aren't afraid of losing.",
	["AI: Brutal"] = "Recommended for veterans of Zero-K.",
	["Inactive AI"] = "This AI does absolutely nothing after spawning.",
	["Chicken: Very Easy"] = "Defeat waves of aliens.",
	["Chicken: Easy"] = "Defeat waves of aliens.",
	["Chicken: Normal"] = "Defeat waves of aliens.",
	["Chicken: Hard"] = "Defeat waves of aliens.",
	["Chicken: Suicidal"] = "Defeat waves of aliens. Good luck.",
	["Chicken: Custom"] = "Customizable chicken defense. Look in Adv Options.",
}

return {
	GetAiSimpleName = GetAiSimpleName,
	simpleAiOrder = simpleAiOrder,
	aiTooltip = aiTooltip
}
