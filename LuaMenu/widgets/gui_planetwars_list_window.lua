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
-- Planet List

local function MakePlanetControl(parentControl, index, planetID, planetName, planetMap, playersNeeded, playersCount)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	local btnLeave, btnJoin
	
	Spring.Echo("MakePlanetControl", MakePlanetControl)
	local inQueue = false
	
	local holder = Control:New {
		x = 10,
		y = index*55 + 15,
		right = 0,
		height = 45,
		caption = "",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		parent = parentControl,
	}
	
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
			
				lobby:PwJoinPlanet(planetID)
				obj:SetVisibility(false)
				btnLeave:SetVisibility(true)
				--WG.Analytics.SendOnetimeEvent("lobby:multiplayer:matchmaking:join_" .. queueName)
			end
		},
		parent = holder
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
		parent = holder
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
		parent = holder
	}
	labelDisabled:SetVisibility(false)
	
	local lblTitle = TextBox:New {
		x = 105,
		y = 15,
		width = 120,
		height = 33,
		fontsize = Configuration:GetFont(3).size,
		text = queueName,
		parent = holder
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
		parent = holder
	}
	
	local lblPlayers = TextBox:New {
		x = 180,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Playing: ",
		parent = holder
	}
	
	local lblWaiting = TextBox:New {
		x = 280,
		y = 30,
		width = 120,
		height = 22,
		right = 5,
		align = "bottom",
		fontsize = Configuration:GetFont(1).size,
		text = "Waiting: ",
		parent = holder
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
	
	function externalFunctions.UpdatePlanetControl(newPlanetData)
	
	end
	
	function externalFunctions.Hide()
	
	end
	
	return externalFunctions
end

local function GetPlanetList(parentControl)
	
	local planets = {}
	
	local externalFunctions = {}
	
	function externalFunctions.SetPlanetList(newPlanetList, activeForMe)
		local index = 1
		if newPlanetList then
			while index <= #newPlanetList do
				local planetData = newPlanetList[index]
				if planets[index] then
					planets[index].UpdatePlanetControl(planetData.PlanetID, planetData.PlanetName, planetData.Map, planetData.Needed, planetData.Count)
				else
					planets[index] = MakePlanetControl(parentControl, index, planetData.PlanetID, planetData.PlanetName, planetData.Map, planetData.Needed, planetData.Count)
				end
				index = index + 1
			end
		end
		while index <= #planets do
			planets[index].Hide()
			index = index + 1
		end
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeControls(window)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
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
		y = 55,
		bottom = 250,
		borderColor = {0,0,0,0},
		horizontalScrollbar = false,
		parent = window
	}
	
	local planetList = GetPlanetList(listPanel)
	
	local statusText = TextBox:New {
		x = 12,
		right = 5,
		bottom = 120,
		height = 100,
		fontsize = Configuration:GetFont(2).size,
		text = "",
		parent = window
	}
	
	local function OnPwMatchCommand(listener, attackerFaction, defenderFactions, currentMode, planets, deadlineSeconds)
		planetList.SetPlanetList(planets)
	end
	
	lobby:AddListener("OnPwMatchCommand", OnPwMatchCommand)
	
	local planetwarsData = lobby:GetPlanetwarsData()
	OnPwMatchCommand(_, planetwarsData.attackerFaction, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets, 457)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateTimer()
	
	end
	
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
		name = "planetwarsListWindowControl",
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
		panelInterface.UpdateTimer()
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