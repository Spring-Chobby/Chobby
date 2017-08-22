local aiLibFunctions = {}

local circuitDifficulties = {
	"CircuitAIEasy",
	"CircuitAINormal",
	"CircuitAIHard",
	"CircuitAIBrutal",
}

function aiLibFunctions.Circuit_difficulty_autofill(difficultySetting)
	return circuitDifficulties[difficultySetting]
end

return {
	aiLibFunctions = aiLibFunctions,
}