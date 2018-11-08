
local devString = ((WG.Chobby.Configuration:GetIsDevEngine() and " (dev)") or "")
local devPrefix = ((WG.Chobby.Configuration:GetIsDevEngine() and "Dev") or "")
local subnameMap = {
	{devPrefix .. "CircuitAIBeginner", "AI: Beginner" .. devString},
	{devPrefix .. "CircuitAINovice", "AI: Novice" .. devString},
	{devPrefix .. "CircuitAIEasy", "AI: Easy" .. devString},
	{devPrefix .. "CircuitAINormal", "AI: Normal" .. devString},
	{devPrefix .. "CircuitAIHard", "AI: Hard" .. devString},
	{devPrefix .. "CircuitAIBrutal", "AI: Brutal" .. devString},
	{"CAI", "AI: Legacy"},
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
	["AI: Beginner" .. devString] = 0,
	["AI: Novice" .. devString] = 1,
	["AI: Easy" .. devString] = 2,
	["AI: Normal" .. devString] = 3,
	["AI: Hard" .. devString] = 4,
	["AI: Brutal" .. devString] = 5,
	["Inactive AI"] = 6,
	["Chicken: Beginner"] = 6.5,
	["Chicken: Very Easy"] = 7,
	["Chicken: Easy"] = 8,
	["Chicken: Normal"] = 9,
	["Chicken: Hard"] = 10,
	["Chicken: Suicidal"] = 11,
	["Chicken: Custom"] = 12,
	["AI: Legacy"] = 13,
}

local aiTooltip = {
	["AI: Beginner" .. devString] = "Recommended for players with no strategy game experience.",
	["AI: Novice" .. devString] = "Recommended for players with some strategy game experience, or experience with related genres (such as MOBA).",
	["AI: Easy" .. devString] = "Recommended for experienced strategy gamers with some experience of streaming economy.",
	["AI: Normal" .. devString] = "Recommended for veteran strategy gamers.",
	["AI: Hard" .. devString] = "Recommended for veteran strategy gamers who aren't afraid of losing.",
	["AI: Brutal" .. devString] = "Recommended for veterans of Zero-K.",
	["AI: Legacy"] = "Older unsupported AI, still potentially challenging.",
	["Inactive AI"] = "This AI does absolutely nothing after spawning.",
	["Chicken: Beginner"] = "Defeat waves of aliens.",
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
