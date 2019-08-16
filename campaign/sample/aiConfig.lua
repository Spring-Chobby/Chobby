local aiLibFunctions = {}

local circuitDifficulties = {
	"CircuitAIEasy",
	"CircuitAINormal",
	"CircuitAIHard",
	"CircuitAIBrutal",
}

function aiLibFunctions.Circuit_difficulty_autofill(difficultySetting)
	return ((WG.Chobby.Configuration:GetIsDevEngine() and "Dev") or "") .. circuitDifficulties[difficultySetting]
end

return {
	aiLibFunctions = aiLibFunctions,
}
