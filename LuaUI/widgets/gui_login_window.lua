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

local wantLoginStatus = {
	["offline"] = true,
	["closed"] = true,
	["disconnected"] = true,
}

local function MultiplayerEntryPopup()
	if wantLoginStatus[lobby:GetConnectionStatus()] then
		local loginWindow = WG.Chobby.LoginWindow(MultiplayerFailFunction, nil, "overlay_window")
		local popup = WG.Chobby.PriorityPopup(loginWindow.window)
	end
end

local function LoginPopup()
	local loginWindow = WG.Chobby.LoginWindow(nil, nil, "overlay_window")
	local popup = WG.Chobby.PriorityPopup(loginWindow.window)
end

local function InitialWindow()
	if WG.Chobby.Configuration.autoLogin then
		local loginWindow = WG.Chobby.LoginWindow(nil, nil, "overlay_window")
		loginWindow.window:Hide()
		lobby:AddListener("OnDenied", function(listener)
			loginWindow.window:Show()
			local popup = WG.Chobby.PriorityPopup(loginWindow.window)
			lobby:RemoveListener("OnDenied", listener)
		end)
		loginWindow:tryLogin()
	elseif WG.Chobby.Configuration.promptNewUsersToLogIn then
		local loginWindow = WG.Chobby.LoginWindow(nil, "play_offline", "overlay_window")
		local popup = WG.Chobby.PriorityPopup(loginWindow.window)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = "LuaUI/widgets/chobby/"
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.MultiplayerEntryPopup = MultiplayerEntryPopup
	WG.LoginPopup = LoginPopup

	WG.Delay(InitialWindow, 0.001)
end

function widget:Shutdown()
	lobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	if WG.LibLobby then
		WG.LibLobby.lobbySkirmish:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
