local aiLibFunctions = {}

local circuitDifficulties = {
	"NO AI",
	"Skirmish AI",
}

function aiLibFunctions.Circuit_difficulty_autofill(difficultySetting)
	return ((WG.Chobby.Configuration:GetIsDevEngine() and "Dev") or "") .. circuitDifficulties[difficultySetting]
end

return {
	aiLibFunctions = aiLibFunctions,
}