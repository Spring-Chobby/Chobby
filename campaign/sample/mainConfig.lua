local shortname = "sample"

local planetDefs     = VFS.Include("campaign/" .. shortname .. "/planetDefs.lua")
local codex          = VFS.Include("campaign/" .. shortname .. "/codex.lua")
local initialUnlocks = VFS.Include("campaign/" .. shortname .. "/initialUnlocks.lua")
local abilityDefs    = VFS.Include("campaign/" .. shortname .. "/abilityDefs.lua")
local unlocksList    = VFS.Include("campaign/" .. shortname .. "/unlocksList.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	planetDefs = planetDefs,
	codex = codex,
	initialUnlocks = initialUnlocks,
	abilityDefs = abilityDefs,
	unlocksList = unlocksList,
}

return externalFuncAndData