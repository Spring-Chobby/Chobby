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

local registerName, registerPassword

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
		local loginWindow = WG.Chobby.LoginWindow(MultiplayerFailFunction, nil, "main_window")
		if loginWindow and loginWindow.window then
			local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
		else
			Log.Error("Failed to create loginWindow")
		end
	end
end

local function LoginPopup()
	local loginWindow = WG.Chobby.LoginWindow(nil, nil, "main_window")
	local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
end

local function InitialWindow()
	local Configuration = WG.Chobby.Configuration
	if Configuration.autoLogin and Configuration.userName then
		local loginWindow = LoginWindow(nil, nil, "main_window")
		loginWindow.window:Hide()
		lobby:AddListener("OnDenied", function(listener)
			loginWindow.window:Show()
			local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
			lobby:RemoveListener("OnDenied", listener)
		end)
		loginWindow:tryLogin()
	elseif Configuration.promptNewUsersToLogIn then
		local loginWindow = WG.Chobby.LoginWindow(nil, "play_offline", "main_window")
		local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
	end
	
	local function OnConnect()
		if registerName then
			lobby:Register(registerName, registerPassword)
			registerName = nil
		end
		if Configuration.userName and Configuration.password then
			lobby:Login(Configuration.userName, Configuration.password, 3, nil, "Chobby")
		end
	end
	
	lobby:AddListener("OnConnect", OnConnect)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Functions

local LoginWindowHandler = {}

function LoginWindowHandler.QueueRegister(name, password)
	registerName = name
	registerPassword = password
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.MultiplayerEntryPopup = MultiplayerEntryPopup
	WG.LoginPopup = LoginPopup

	WG.Delay(InitialWindow, 0.001)
	WG.LoginWindowHandler = LoginWindowHandler
end

function widget:Shutdown()
	lobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	if WG.LibLobby then
		WG.LibLobby.localLobby:RemoveListener("BattleAboutToStart", onBattleAboutToStart)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
