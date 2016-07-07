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

local function MultiplayerFailFunction()
	WG.Chobby.interfaceRoot.GetMainWindowHandler().SetBackAtMainMenu()
end

local function InitializeControls()
	local loginWindow = WG.Chobby.LoginWindow(MultiplayerFailFunction)
	local popup = WG.Chobby.PriorityPopup(loginWindow.window)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local function MultiplayerEntryPopup()
	InitializeControls()
end

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.MultiplayerEntryPopup = MultiplayerEntryPopup
end

function widget:Shutdown()
	lobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	if WG.LibLobby then
		WG.LibLobby.lobbySkirmish:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------