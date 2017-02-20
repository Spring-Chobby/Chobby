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

local currentLoginWindow

local registerRecieved = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function ResetRegisterRecieved()
	registerRecieved = false
end

local function MultiplayerFailFunction()
	WG.Chobby.interfaceRoot.GetMainWindowHandler().SetBackAtMainMenu()
end

local wantLoginStatus = {
	["offline"] = true,
	["closed"] = true,
	["disconnected"] = true,
}

local function GetNewLoginWindow(failFunc)
	if currentLoginWindow and currentLoginWindow.window then
		currentLoginWindow.window:Dispose()
	end
	currentLoginWindow = WG.Chobby.LoginWindow(failFunc, nil, "main_window")
	return currentLoginWindow
end

local function MultiplayerEntryPopup()
	if wantLoginStatus[lobby:GetConnectionStatus()] then
		local loginWindow = GetNewLoginWindow(MultiplayerFailFunction)
		if loginWindow and loginWindow.window then
			local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
		else
			Log.Error("Failed to create loginWindow")
		end
	end
end

local function LoginPopup()
	local loginWindow = GetNewLoginWindow()
	local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
end

local function InitializeListeners()
	local Configuration = WG.Chobby.Configuration
	
	-- Autologin behaviour
	if Configuration.autoLogin and Configuration.userName then
		local loginWindow = GetNewLoginWindow()
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
	
	-- Register and login response codes
	local function OnRegistrationAccepted()
		WG.Analytics.SendOnetimeEvent("lobby:account_created")
		if currentLoginWindow then
			registerRecieved = true
			WG.Delay(ResetRegisterRecieved, 0.8)
			currentLoginWindow.txtError:SetText(Configuration:GetSuccessColor() .. "Registered!")
		end
	end
	local function OnRegistrationDenied(listener, err)
		WG.Analytics.SendErrorEvent(err or "unknown")
		if currentLoginWindow then
			registerRecieved = true
			WG.Delay(ResetRegisterRecieved, 0.8)
			currentLoginWindow.txtError:SetText(Configuration:GetErrorColor() .. (err or "Unknown Error"))
		end
	end
	local function OnLoginAccepted()
		Configuration.firstLoginEver = false
		WG.Analytics.SendOnetimeEvent("lobby:logged_in")
		if currentLoginWindow then
			ChiliFX:AddFadeEffect({
				obj = currentLoginWindow.window,
				time = 0.2,
				endValue = 0,
				startValue = 1,
				after = function()
					currentLoginWindow.window:Dispose()
				end,
			})
			for channelName, _ in pairs(Configuration:GetChannels()) do
				lobby:Join(channelName)
			end
		end
	end
	local function OnLoginDenied(listener, err)
		WG.Analytics.SendErrorEvent(err or "unknown")
		if currentLoginWindow and not registerRecieved then
			currentLoginWindow.txtError:SetText(Configuration:GetErrorColor() .. (err or "Denied, unknown reason"))
		end
	end
	
	lobby:AddListener("OnRegistrationAccepted", OnRegistrationAccepted)
	lobby:AddListener("OnRegistrationDenied", OnRegistrationDenied)
	lobby:AddListener("OnAccepted", OnLoginAccepted)
	lobby:AddListener("OnDenied", OnLoginDenied)
	
	-- Stored register on connect
	local function OnConnect()
		WG.Analytics.SendOnetimeEvent("lobby:server_connect")
		if registerName then
			WG.Analytics.SendOnetimeEvent("lobby:send_register")
			lobby:Register(registerName, registerPassword)
			Configuration.userName = registerName
			Configuration.password = registerPassword
			registerName = nil
		end
		if Configuration.userName then
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

	WG.Delay(InitializeListeners, 0.001)
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
