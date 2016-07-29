function widget:GetInfo()
	return {
		name    = 'Modoptions Panel',
		desc    = 'Implements the modoptions panel.',
		author  = 'GoogleFrog',
		date    = '29 July 2016',
		license = 'GNU GPL v2',
		layer   = 0,
		enabled = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local ModoptionsPanel = {}

function ModoptionsPanel.LoadModotpions(gameName)
	local success = VFS.MapArchive(gameName)
	Spring.Echo("successBla", success, gameName)
	local modoptions = VFS.LoadFile("ModOptions.lua")
	if modoptions then
		Spring.Utilities.TableEcho(modoptions)
	end
	VFS.UnmapArchive(gameName)
end

function ModoptionsPanel.ShowModoptions(gameName)
end

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Initialization

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.ModoptionsPanel = ModoptionsPanel
end
