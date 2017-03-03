local shortname = "sample"

local planetDefs  = VFS.Include("campaign/" .. shortname .. "/planetDefs.lua")
local codex       = VFS.Include("campaign/" .. shortname .. "/codex.lua")

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	planetDefs = planetDefs,
	codex = codex,
}


return externalFuncAndData