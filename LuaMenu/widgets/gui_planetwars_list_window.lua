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

local IMG_LINK     = LUA_DIRNAME .. "images/link.png"

local panelInterface
local PLANET_NAME_LENGTH = 210

local phaseTimer

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function MaybeDownloadArchive(archiveName, archiveType)
	if not VFS.HasArchive(archiveName) then
		VFS.DownloadArchive(archiveName, archiveType)
	end
end

local function MaybeDownloadMap(mapName)
	MaybeDownloadArchive(mapName, "map")
end

local function HaveRightEngineVersion()
	local configuration = WG.Chobby.Configuration
	if configuration.useWrongEngine then
		return true
	end
	local engineVersion = WG.LibLobby.lobby:GetSuggestedEngineVersion()
	return (not engineVersion) or configuration:IsValidEngineVersion(engineVersion)
end

local function HaveRightGameVersion()
	local gameName = WG.Chobby.Configuration:GetDefaultGameName()
	local haveGame = VFS.HasArchive(gameName)
	return haveGame
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Timing

local function GetPhaseTimer()
	local deadlineSeconds
	local startTimer
	
	local externalFunctions = {}
	
	function externalFunctions.SetNewDeadline(newDeadlineSeconds)
		deadlineSeconds = newDeadlineSeconds
		startTimer = Spring.GetTimer()
	end
	
	function externalFunctions.GetTimeRemaining()
		if not deadlineSeconds then
			return false
		end
		return math.max(0, deadlineSeconds - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer)))
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet Drawer

local function GetPlanetImage(holder, x, y, size, planetImage, structureList)
	local children = {}
	
	if structureList then
		for i = 1, #structureList do
			children[#children + 1] = Image:New {
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				keepAspect = true,
				file = "LuaMenu/images/structures/" .. structureList[i],
			}
		end
	end
	
	if planetImage then
		local planetPad = math.floor(size*7/30)
		children[#children + 1] = Image:New {
			x = planetPad,
			y = planetPad,
			right = planetPad,
			bottom = planetPad,
			keepAspect = true,
			file = "LuaMenu/images/planets/" .. planetImage,
		}
	end
	
	local imagePanel = Panel:New {
		classname = "panel_light",
		x = x,
		y = y,
		width = size,
		height = size,
		padding = {1,1,1,1},
		children = children,
		parent = holder,
	}
	
	return imagePanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet List

local function MakePlanetControl(planetData, attacker, defender)
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	local config = WG.Chobby.Configuration
	local mapName = planetData.Map
	local planetID = planetData.PlanetID
	
	local joinedBattle = false
	local downloading = false
	local currentPlayers = planetData.Count or 0
	local maxPlayers = planetData.Needed or 0
	
	local btnJoin
	
	local holder = Panel:New {
		x = 0,
		y = 0,
		width = "100%",
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
	}
	
	local planetImage = GetPlanetImage(holder, 2, 2, 86, planetData.PlanetImage, planetData.StructureImages)
	
	local minimapPanel = Panel:New {
		x = 100,
		y = 5,
		width = 26,
		height = 26,
		padding = {1,1,1,1},
		parent = holder,
	}
	local btnMinimap = Button:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		classname = "button_square",
		caption = "",
		parent = minimapPanel,
		padding = {1,1,1,1},
		OnClick = {
			function ()
				if mapName and config.gameConfig.link_particularMapPage then
					WG.BrowserHandler.OpenUrl(config.gameConfig.link_particularMapPage(mapName))
				end
			end
		},
	}
	local imMinimap = Image:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = config:GetMinimapImage(mapName),
		parent = btnMinimap,
	}
	
	local btnPlanetLink = Button:New {
		x = 130,
		y = 7,
		width = PLANET_NAME_LENGTH,
		height = 24,
		classname = "button_square",
		caption = "",
		padding = {0, 0, 0, 0},
		parent = holder,
		OnClick = {
			function ()
				WG.BrowserHandler.OpenUrl("http://zero-k.info/Planetwars/Planet/" .. planetID)
			end
		}
	}
	local tbPlanetName = TextBox:New {
		x = 2,
		y = 3,
		right = 20,
		align = "left",
		fontsize = config:GetFont(3).size,
		parent = btnPlanetLink,
	}
	local imgPlanetLink = Image:New {
		x = 0,
		y = 4,
		width = 18,
		height = 18,
		keepAspect = true,
		file = IMG_LINK,
		parent = btnPlanetLink,
	}
	
	local playerCaption = TextBox:New {
		name = "missionName",
		x = 270,
		y = 54,
		width = 350,
		height = 20,
		valign = 'center',
		fontsize = Configuration:GetFont(3).size,
		text = "0/0",
		parent = holder,
	}
	
	local function SetPlanetName(newPlanetName)
		newPlanetName = StringUtilities.GetTruncatedStringWithDotDot(newPlanetName, tbPlanetName.font, PLANET_NAME_LENGTH - 24)
		tbPlanetName:SetText(newPlanetName)
		local length = tbPlanetName.font:GetTextWidth(newPlanetName)
		imgPlanetLink:SetPos(length + 7)
	end
	
	local function UpdatePlayerCaption()
		if joinedBattle then
			playerCaption:SetText("Joined - Waiting for players: " .. currentPlayers .. "/" .. maxPlayers)
		else
			playerCaption:SetText(currentPlayers .. "/" .. maxPlayers)
		end
	end
	
	local function UpdateJoinButton()
		if not (attacker or defender) then
			playerCaption:SetPos(104)
			UpdatePlayerCaption()
			btnJoin:SetVisibility(false)
			return
		end
		
		if joinedBattle then
			playerCaption:SetPos(104)
		else
			playerCaption:SetPos(270)
			local haveMap = VFS.HasArchive(mapName)
			if haveMap then
				if attacker then
					btnJoin:SetCaption(i18n("attack_planet"))
				elseif defender then
					btnJoin:SetCaption(i18n("defend_planet"))
				end
			else
				if downloading then
					btnJoin:SetCaption(i18n("downloading"))
				else
					btnJoin:SetCaption(i18n("download_map"))
				end
			end
		end
		UpdatePlayerCaption()
		btnJoin:SetVisibility(not joinedBattle)
	end
	
	btnJoin = Button:New {
		x = 100,
		width = 160,
		bottom = 6,
		height = 45,
		caption = i18n("defend_planet"),
		font = Configuration:GetFont(3),
		classname = "option_button",
		OnClick = {
			function(obj)
				if not VFS.HasArchive(mapName) then
					if not downloading then
						MaybeDownloadMap(mapName)
						downloading = true
						UpdateJoinButton()
					end
					return
				end
				
				if not HaveRightEngineVersion() then
					WG.Chobby.InformationPopup("Game engine update required, restart the menu to apply.")
					return
				end
				
				if not HaveRightGameVersion() then
					WG.Chobby.InformationPopup("Game version update required, restart the menu to apply.")
					return
				end
				
				joinedBattle = true
				lobby:PwJoinPlanet(planetID)
				UpdateJoinButton()
				WG.Analytics.SendOnetimeEvent("lobby:multiplayer:planetwars:join")
			end
		},
		parent = holder
	}
	
	-- Initialization
	SetPlanetName(planetData.PlanetName)
	UpdateJoinButton()
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePlanetControl(newPlanetData, newAttacker, newDefender, resetJoinedBattle)
		mapName = newPlanetData.Map
		currentPlayers = newPlanetData.Count or 0
		maxPlayers = newPlanetData.Needed or 0
		
		if resetJoinedBattle then
			joinedBattle = false
		end
		
		attacker, defender = newAttacker, newDefender
		
		if planetID ~= newPlanetData.PlanetID then
			planetImage:Dispose()
			planetImage = GetPlanetImage(holder, 2, 2, 86, newPlanetData.PlanetImage, newPlanetData.StructureImages)
			
			imMinimap.file = config:GetMinimapImage(mapName)
			imMinimap:Invalidate()
			
			SetPlanetName(newPlanetData.PlanetName)
		end
		planetID = newPlanetData.PlanetID
		
		UpdateJoinButton()
	end
	
	function externalFunctions.CheckDownload()
		if holder.visible then
			UpdateJoinButton()
		end
	end
	
	function externalFunctions.GetControl()
		return holder
	end
	
	return externalFunctions
end

local function GetPlanetList(parentControl)
	
	local planets = {}
	
	local sortableList = WG.Chobby.SortableList(parentControl, nil, 90, 1)

	local externalFunctions = {}
	
	function externalFunctions.SetPlanetList(newPlanetList, attacker, defender, modeSwitched)
		sortableList:Clear()
		local items = {}
		if newPlanetList then
			for i = 1, #newPlanetList do
				if planets[i] then
					planets[i].UpdatePlanetControl(newPlanetList[i], attacker, defender, modeSwitched)
				else
					planets[i] = MakePlanetControl(newPlanetList[i], attacker, defender, modeSwitched)
				end
				items[i] = {i, planets[i].GetControl()}
			end
			sortableList:AddItems(items)
		end
	end
	
	function externalFunctions.CheckDownload()
		for i = 1, #planets do
			planets[i].CheckDownload()
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
	
	local title = "Planetwars"
	
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
	
	local listHolder = Control:New {
		x = 5,
		right = 5,
		y = 55,
		bottom = 250,
		padding = {0, 0, 0, 0},
		parent = window,
	}
	
	local planetList = GetPlanetList(listHolder)
	
	local statusText = TextBox:New {
		x = 12,
		right = 5,
		bottom = 120,
		height = 100,
		fontsize = Configuration:GetFont(2).size,
		text = "",
		parent = window
	}
	
	local function OnPwMatchCommand(listener, attackerFaction, defenderFactions, currentMode, planets, deadlineSeconds, modeSwitched)
		if currentMode == lobby.PW_ATTACK then
			if attackerFaction then
				title = "Planetwars: " .. attackerFaction .. " selecting target - "
			else
				title = "Planetwars: attacking - "
			end
		else
			if defenderFactions and #defenderFactions then
				local defenderString = ""
				for i = 1, #defenderFactions do
					if i == #defenderFactions then
						defenderString = defenderString .. defenderFactions[i]
					else
						defenderString = defenderString .. defenderFactions[i] .. ", "
					end
					title = "Planetwars: " .. defenderString .. " mustering defense - "
				end
			else
				title = "Planetwars: defending - "
			end
		end
		
		local myFaction = lobby:GetMyFaction()
		local attacker = (myFaction == attackerFaction)
		local defender = false
		if defenderFactions then
			for i = 1, #defenderFactions do
				if myFaction == defenderFactions[i] then
					defender = true
					break
				end
			end
		end
		
		planetList.SetPlanetList(planets, (currentMode == lobby.PW_ATTACK) and attacker,  (currentMode == lobby.PW_DEFEND) and defender, modeSwitched)
	end
	
	lobby:AddListener("OnPwMatchCommand", OnPwMatchCommand)
	
	local planetwarsData = lobby:GetPlanetwarsData()
	OnPwMatchCommand(_, planetwarsData.attackerFaction, planetwarsData.defenderFactions, planetwarsData.currentMode, planetwarsData.planets, 457)
	
	local externalFunctions = {}
	
	function externalFunctions.CheckDownload()
		planetList.CheckDownload()
	end
	
	function externalFunctions.UpdateTimer()
		local timeRemaining = phaseTimer.GetTimeRemaining()
		if timeRemaining then
			lblTitle:SetCaption(title .. Spring.Utilities.FormatTime(timeRemaining, true))
		end
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

function DelayedInitialize()
	local Configuration = WG.Chobby.Configuration
	local lobby = WG.LibLobby.lobby
	
	phaseTimer = GetPhaseTimer()
	
	local function OnPwMatchCommand(listener, attackerFaction, defenderFactions, currentMode, planets, deadlineSeconds, modeSwitched)
		phaseTimer.SetNewDeadline(deadlineSeconds)
	end
	lobby:AddListener("OnPwMatchCommand", OnPwMatchCommand)
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
	panelInterface.CheckDownload()
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	WG.Delay(DelayedInitialize, 1)
	
	WG.PlanetwarsListWindow = PlanetwarsListWindow
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------