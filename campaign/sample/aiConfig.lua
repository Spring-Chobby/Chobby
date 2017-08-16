local aiLibFunctions = {}

local circuitDifficulties = {
	"CircuitAINormal",
	"CircuitAIHard",
	"CircuitAIInsane",
	"CircuitAIBrutal",
}

function aiLibFunctions.Circuit_difficulty_autofill(difficultySetting)
	return circuitDifficulties[difficultySetting]
end

return {
	aiLibFunctions = aiLibFunctions,
}