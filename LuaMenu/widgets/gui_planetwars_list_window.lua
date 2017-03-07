--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Planetwars List Window",
		desc      = "Handles planetwars battle list display.",
		author    = "GoogleFrog",
		date      = "7 March 2017",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -100000,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables


local requiredResources = {}
local requiredResourceCount = 0

local panelInterface

local function HaveRightEngineVersion()
	local configuration = WG.Chobby.Configuration
	if configuration.useWrongEngine then
		return true
	end
	local engineVersion = WG.LibLobby.lobby:GetSuggestedEngineVersion()
	return (not engineVersion) or configuration:IsValidEngineVersion(engineVersion)
end

local function HaveRightGameVersion()

end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function MakeQueueControl(parentControl, queueName, queueDescription, players, waiting, maxPartySize)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	local btnLeave, btnJoin
	
	local currentPartySize = 1
	local inQueue = false
	
	btnJoin = Button:New {
		x = 0,
		y = 0,
		width = 80,
		bottom = 0,
		caption = i18n("join"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		OnClick = {
			function(obj)
				if not HaveRightEngineVersion() then
					WG.Chobby.InformationPopup("Game engine update required, restart the menu to apply.")
					return
				end
				if requiredResourceCount ~= 0 then
					WG.Chobby.InformationPopup("All required maps and games must be downloaded before you can join matchmaking.")
					return
				end
			
				lobby:JoinMatchMaking(queueName)
				obj:SetVisibility(false)
				btnLeave:SetVisibility(true)
				WG.Analytics.SendOnetimeEvent("lobby:multiplayer:matchmaking:join_" .. queueName)
			end
		},
		parent = parentControl
	}
	
	btnLeave = Button:New {
		x = 0,
		y = 0,
		width = 80,
		bottom = 0,
		caption = i18n("leave"),
		font = Configuration:GetFont(3),
		classname = "action_button",
		OnClick = {
			function(obj)
				lobby:LeaveMatchMaking(queueName)
				obj:SetVisibility(false)
				btnJoin:SetVisibility(true)
			end
		},
		parent = parentControl
	}
	btnLeave:SetVisibility(false)
	
	local labelDisabled = TextBox:New {
		x = 0,
		y = 18,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Party too large",
		parent = parentControl
	}
	labelDisabled:SetVisibility(false)
	
	local lblTitle = TextBox:New {
		x = 105,
		y = 15,
		width = 120,
		height = 33,
		fontsize = Configuration:GetFont(3).size,
		text = queueName,
		parent = parentControl
	}
	
	local lblDescription = TextBox:New {
		x = 180,
		y = 8,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = queueDescription,
		parent = parentControl
	}
	
	local lblPlayers = TextBox:New {
		x = 180,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Playing: " .. players,
		parent = parentControl
	}
	
	local lblWaiting = TextBox:New {
		x = 280,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Waiting: " .. waiting,
		parent = parentControl
	}
	
	local function UpdateButton()
		if maxPartySize and (currentPartySize > maxPartySize) then
			btnJoin:SetVisibility(false)
			btnLeave:SetVisibility(false)
			labelDisabled:SetVisibility(true)
		else
			btnJoin:SetVisibility(not inQueue)
			btnLeave:SetVisibility(inQueue)
			labelDisabled:SetVisibility(false)
		end
	end
	
	local externalFunctions = {}
	
	function externalFunctions.SetInQueue(newInQueue)
		if newInQueue == inQueue then
			return
		end
		inQueue = newInQueue
		UpdateButton()
	end
	
	function externalFunctions.UpdateCurrentPartySize(newCurrentPartySize)
		if newCurrentPartySize == currentPartySize then
			return
		end
		currentPartySize = newCurrentPartySize
		UpdateButton()
	end
	
	function externalFunctions.UpdateQueueInformation(newName, newDescription, newPlayers, newWaiting, newMaxPartySize)
		if newName then
			lblTitle:SetText(newName)
		end
		if newDescription then
			lblDescription:SetText(newDescription)
		end
		if newPlayers then
			lblPlayers:SetText("Playing: " .. newPlayers)
		end
		if newWaiting then
			lblWaiting:SetText("Waiting: " .. newWaiting)
		end
	end
	
	return externalFunctions
end

local function InitializeControls(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local banStart
	local banDuration
	
	local lblTitle = Label:New {
		x = 20,
		right = 5,
		y = 17,
		height = 20,
		font = Configuration:GetFont(3),
		caption = "Planetwars",
		parent = window
	}

	local btnClose = Button:New {
		right = 11,
		y = 7,
		width = 80,
		height = 45,
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				window:Hide()
			end
		},
		parent = window
	}

	local listPanel = ScrollPanel:New {
		x = 5,
		right = 5,
		y = 90,
		height = 250,
		borderColor = {0,0,0,0},
		horizontalScrollbar = false,
		parent = window
	}
	
	local statusText = TextBox:New {
		x = 12,
		right = 5,
		y = 55,
		height = 200,
		fontsize = Configuration:GetFont(2).size,
		text = "",
		parent = window
	}
	
	local externalFunctions = {}
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local PlanetwarsListWindow = {}

function PlanetwarsListWindow.HaveMatchMakerResources()
	return HaveRightEngineVersion() and HaveRightGameVersion()
end

local queueListWindowControl

function PlanetwarsListWindow.GetControl()

	planetwarsListWindowControl = Control:New {
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0, 0, 0, 0},
		OnParent = {
			function(obj)
				if obj:IsEmpty() then
					panelInterface = InitializeControls(obj)
				end
			end
		},
	}
	
	return planetwarsListWindowControl
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Update()
	if panelInterface then
		panelInterface.UpdatePhaseTime()
	end
end

function widget:DownloadFinished()
	for resourceName,_ in pairs(requiredResources) do
		if panelInterface then
			panelInterface.UpdateRequiredResource(resourceName)
		end
	end
	
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.PlanetwarsListWindow = PlanetwarsListWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------