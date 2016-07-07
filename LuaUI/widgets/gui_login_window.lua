--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Login Window",
		desc      = "Handles login and registration.",
		author    = "GoogleFrog",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Local Variables

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls()
	
	local loginWindow = WG.Chobby.LoginWindow()
	
	local popup = WG.Chobby.PriorityPopup(loginWindow.window)
	
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.Delay(InitializeControls, 0.02)
end

function widget:Shutdown()
	lobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	if WG.LibLobby then
		WG.LibLobby.lobbySkirmish:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------