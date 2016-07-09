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
local lblPlayerIcon
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
	if lobby.status ~= "offline" then
		Spring.Echo("Logout")
		lobby:Disconnect()
		WG.Chobby.Configuration.autoLogin = false
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
	-- TODO: Representing my user should be done in a uniform way: 
	-- See: https://github.com/Spring-Chobby/Chobby/issues/49
	lblPlayerIcon = Label:New {
		x = 0,
		width = 150,
		y = 0,
		height = 20,
		valign = "center",
		caption = "",
		parent = window,
		font = {
			size = 16,
		},
	}

	local btnLogout = Button:New {
		right = 10,
		width = 100, 
		height = 40,
		caption = i18n("login"),
		parent = window,
		OnClick = {Logout}
	}
	
	lblPing = Label:New {
		x = 0,
		width = 150,
		y = 25,
		height = 20,
		valign = "center",
		caption = "\255\180\180\180" .. i18n("offline") .. "\b",
		font = {
			size = 20,
		},
		parent = window,
	}

	onAccepted = function(listener)
		lblPlayerIcon:SetCaption(lobby:GetMyUserName())
		btnLogout:SetCaption(i18n("logout"))
		lobby:Ping()
		lblPing:SetCaption(WG.Chobby.Configuration:GetSuccessColor() .. i18n("online") .. "\b")
	end
	onDisconnected = function(listener)
		if lobby.status == "offline" then
			btnLogout:SetCaption(i18n("login"))
		end
		if lobby.status == "offline" then
			lblPing:SetCaption("\255\180\180\180" .. i18n("offline") .. "\b")
		else
			lblPing:SetCaption(WG.Chobby.Configuration:GetErrorColor() .. "D/C\b")
		end
	end
	onPong = function(listener)
-- 		UpdateLatency()
	end
	lobby:AddListener("OnAccepted", onAccepted)
	lobby:AddListener("OnDisconnected", onDisconnected)
	lobby:AddListener("OnPong", onPong)
end

function UserStatusPanel.GetControl()
	local window = Control:New {
		right = 0,
		y = 10,
		width = 200,
		height = "100%",
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

function widget:Initialize()
	
	VFS.Include("LuaUI/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.UserStatusPanel = UserStatusPanel

	-- TODO: This should probably be moved elsewhere
	UserStatusPanel.GetControl()
end

function widget:Shutdown()
	if lobby then
		lobby:RemoveListener("OnAccepted", onAccepted)
		lobby:RemoveListener("OnDisconnected", onDisconnected)
		lobby:RemoveListener("OnPong", onPong)
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
