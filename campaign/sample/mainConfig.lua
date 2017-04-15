local shortname = "sample"

local planetDefs     = VFS.Include("campaign/" .. shortname .. "/planetDefs.lua")
local codex          = VFS.Include("campaign/" .. shortname .. "/codex.lua")
local initialUnlocks = VFS.Include("campaign/" .. shortname .. "/initialUnlocks.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	planetDefs = planetDefs,
	codex = codex,
	initialUnlocks = initialUnlocks
}

return externalFuncAndData