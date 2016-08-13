--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "User status panel",
		desc      = "Displays user status and provides interface for logging out and exiting.",
		author    = "gajop",
		date      = "4 July 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Chili
local btnLogout
local lblPing

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Lobby listeners

local onAccepted, onDisconnected, onPong

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local UserStatusPanel = {}

local function Logout()
	if lobby:GetConnectionStatus() ~= "offline" then
		Spring.Echo("Logout")
		WG.Chobby.interfaceRoot.CleanMultiplayerState()
		WG.Chobby.Configuration:SetConfigValue("autoLogin", false)
		lobby:Disconnect()
	else
		Spring.Echo("Login")
		WG.LoginPopup()
	end
end

local function Quit()
	Spring.Echo("Quitting...")
	Spring.SendCommands("quitforce")
end

-- local function UpdateLatency()
-- 	local latency = lobby:GetLatency()
-- 	local color
-- 	latency = math.ceil(latency)
-- 	if latency < 500 then
-- 		color = WG.Chobby.Configuration:GetSuccessColor()
-- 	elseif latency < 1000 then
-- 		color = WG.Chobby.Configuration:GetWarningColor()
-- 	else
-- 		if latency > 9000 then
-- 			latency = "9000+"
-- 		end
-- 		color = "\255\255\125\0"
-- 	end
-- 	lblPing:SetCaption(color .. latency .. "ms\b")
-- end
-- 
-- local _lastUpdate = os.clock()
-- function widget:Update()
-- 	if os.clock() - _lastUpdate > 1 then
-- 		_lastUpdate = os.clock()
-- 		UpdateLatency()
-- 	end
-- end

local function InitializeControls(window)
	btnLogout = Button:New {
		y = 5,
		right = 5,
		width = 100, 
		height = 41,
		caption = i18n("login"),
		parent = window,
		font = WG.Chobby.Configuration:GetFont(3),
		OnClick = {Logout}
	}
	
	lblPing = Label:New {
		name = "ping",
		x = 0,
		width = 150,
		y = 15,
		height = 20,
		valign = "center",
		caption = "\255\180\180\180" .. i18n("offline") .. "\b",
		font = WG.Chobby.Configuration:GetFont(3),
		parent = window,
	}

	local userControl
	onAccepted = function(listener)
		userControl = WG.UserHandler.GetStatusUser(lobby:GetMyUserName())
		userControl:SetPos(nil, 54)
		window:AddChild(userControl)
		lobby:Ping()
	end

	onDisconnected = function(listener)
		if userControl and userControl.parent then
			window:RemoveChild(userControl)
		end
	end
	
	onPong = function(listener)
		--UpdateLatency()
	end
	lobby:AddListener("OnDisconnected", onDisconnected)
	lobby:AddListener("OnAccepted", onAccepted)
	lobby:AddListener("OnPong", onPong)
end

function UserStatusPanel.GetControl()
	local window = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					InitializeControls(obj)
				end
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

local oldStatus

function widget:Update()
	local newStatus = lobby:GetConnectionStatus()
	if newStatus ~= oldStatus then
		if newStatus == "disconnected" or newStatus == "offline" then
			btnLogout:SetCaption(i18n("login"))
			lblPing:SetCaption("\255\180\180\180" .. i18n("offline") .. "\b")
		else
			btnLogout:SetCaption(i18n("logout"))
		end
		if newStatus == "connecting" then
			lblPing:SetCaption(WG.Chobby.Configuration:GetPartialColor() .. i18n("connecting") .. "\b")
		elseif newStatus == "connected" then
			lblPing:SetCaption(WG.Chobby.Configuration:GetSuccessColor() .. i18n("online") .. "\b")
		end
		oldStatus = newStatus
	end
end

function widget:Initialize()
	
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.UserStatusPanel = UserStatusPanel

	-- TODO: This should probably be moved elsewhere
	WG.Delay(UserStatusPanel.GetControl, 0.01)
end

function widget:Shutdown()
	if lobby then
		lobby:RemoveListener("OnAccepted", onAccepted)
		lobby:RemoveListener("OnPong", onPong)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
