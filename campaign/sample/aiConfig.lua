local aiLibFunctions = {}

local circuitDifficulties = {
	"CircuitAIEasy",
	"CircuitAIMedium",
	"CircuitAIHard",
}

function aiLibFunctions.Circuit_difficulty_autofill(difficultySetting)
	return circuitDifficulties[difficultySetting]
end

return {
	aiLibFunctions = aiLibFunctions,
}