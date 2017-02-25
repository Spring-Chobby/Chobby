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
		currentLoginWindow = nil
	end
	local Configuration = WG.Chobby.Configuration
	local steamMode = Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam
	if steamMode then
		currentLoginWindow = WG.Chobby.SteamLoginWindow(failFunc, nil, "main_window")
	else
		currentLoginWindow = WG.Chobby.LoginWindow(failFunc, nil, "main_window")
	end
	return currentLoginWindow
end

local function TrySimpleSteamLogin()
	local Configuration = WG.Chobby.Configuration
	if not (Configuration.steamLinkComplete and Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam) then
		return false
	end
	if lobby.connected then
		lobby:Login(Configuration.userName, Configuration.password, 3, nil, "Chobby", true)
	else
		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort(), Configuration.userName, Configuration.password, 3, nil, "Chobby")
	end
	return true
end

local function TrySimpleLogin()
	local Configuration = WG.Chobby.Configuration
	if lobby.connected then
		lobby:Login(Configuration.userName, Configuration.password, 3, nil, "Chobby")
	else
		lobby:Connect(Configuration:GetServerAddress(), Configuration:GetServerPort(), Configuration.userName, Configuration.password, 3, nil, "Chobby")
	end
end

local function CheckAutologin()
	local Configuration = WG.Chobby.Configuration
	if not TrySimpleSteamLogin() then
		if Configuration.autoLogin and Configuration.userName then
			TrySimpleLogin()
		end
	end
end

local function InitializeListeners()
	local Configuration = WG.Chobby.Configuration
	
	-- Register and login response codes
	local function OnRegistrationAccepted()
		WG.Analytics.SendOnetimeEvent("lobby:account_created")
		if currentLoginWindow then
			registerRecieved = true
			WG.Delay(ResetRegisterRecieved, 0.8)
			currentLoginWindow.txtError:SetText(Configuration:GetSuccessColor() .. "Registered!")
		end
	end
	
	local function OnRegistrationDenied(listener, err, accountAlreadyExists)
		WG.Analytics.SendErrorEvent(err or "unknown")
		
		if Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam then
			Configuration.steamLinkComplete = true
		end
		
		if currentLoginWindow then
			if accountAlreadyExists and currentLoginWindow.ShowPassword then
				currentLoginWindow:ShowPassword()
			end
			registerRecieved = true
			WG.Delay(ResetRegisterRecieved, 0.8)
			currentLoginWindow.txtError:SetText(Configuration:GetErrorColor() .. (err or "Unknown Error"))
		end
	end
	
	local function OnLoginAccepted()
		Configuration.firstLoginEver = false
		WG.Analytics.SendOnetimeEvent("lobby:logged_in")
		
		if Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam then
			Configuration.steamLinkComplete = true
		end
		
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
		
		if Configuration.steamLinkComplete and Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam then
			-- Something failed so prompt re-register
			Configuration.steamLinkComplete = false
		end
		
		if not (currentLoginWindow and currentLoginWindow.window) then
			local loginWindow = GetNewLoginWindow()
			local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
		end
	end
	
	lobby:AddListener("OnRegistrationAccepted", OnRegistrationAccepted)
	lobby:AddListener("OnRegistrationDenied", OnRegistrationDenied)
	lobby:AddListener("OnAccepted", OnLoginAccepted)
	lobby:AddListener("OnDenied", OnLoginDenied)
	
	-- Stored register on connect
	local function OnConnect()
		WG.Analytics.SendOnetimeEvent("lobby:server_connect")
		local steamMode = Configuration.canAuthenticateWithSteam and Configuration.wantAuthenticateWithSteam
		if registerName then
			WG.Analytics.SendOnetimeEvent("lobby:send_register")
			lobby:Register(registerName, registerPassword, nil, steamMode)
			Configuration.userName = registerName
			Configuration.password = registerPassword
			registerName = nil
		end
		if Configuration.userName then
			lobby:Login(Configuration.userName, Configuration.password, 3, nil, "Chobby", steamMode)
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

function LoginWindowHandler.TryLoginMultiplayer(name, password)
	if wantLoginStatus[lobby:GetConnectionStatus()] then
		if not TrySimpleSteamLogin() then
			local loginWindow = GetNewLoginWindow(MultiplayerFailFunction)
			local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
		end
	end
end

function LoginWindowHandler.TryLogin()
	if not TrySimpleSteamLogin() then
		local loginWindow = GetNewLoginWindow()
		local popup = WG.Chobby.PriorityPopup(loginWindow.window, loginWindow.CancelFunc, loginWindow.AcceptFunc)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	LoginWindowHandler.TrySimpleSteamLogin = TrySimpleSteamLogin
	
	WG.Delay(InitializeListeners, 0.1)
	WG.Delay(CheckAutologin, 0.1)
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
