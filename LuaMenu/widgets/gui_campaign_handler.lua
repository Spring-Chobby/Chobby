--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Handler",
		desc      = "Explore the galaxy",
		author    = "GoogleFrog",
		date      = "25 Jan 2017",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

local GALAXY_IMAGE = LUA_DIRNAME .. "images/heic1403aDowngrade.jpg"
local IMAGE_BOUNDS = {
	x = 810/4000,
	y = 710/2602,
	width = 2400/4000,
	height = 1500/2602,
}

local edgeDrawList = 0
local planetConfig, planetAdjacency, planetEdgeList

local ACTIVE_COLOR = {0,1,0,0.7}
local INACTIVE_COLOR = {0.3, 0.3, 0.3, 0.7}

local PLANET_START_COLOR = {1, 1, 1, 1}
local PLANET_NO_START_COLOR = {0.5, 0.5, 0.5, 1}

local TARGET_IMAGE = LUA_DIRNAME .. "images/niceCircle.png"

local REWARD_ICON_SIZE = 58

local planetList
local selectedPlanet
local currentWinPopup

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Rewards panels

local function MakeRewardList(holder, bottom, name, rewardsTypes, cullUnlocked, widthMult, stackHeight)
	if (not rewardsTypes) or #rewardsTypes == 0 then
		return false
	end
	
	local Configuration = WG.Chobby.Configuration
	
	widthMult = widthMult or 1
	stackHeight = stackHeight or 1
	
	local scroll, rewardsHolder
	
	local position = 0
	for t = 1, #rewardsTypes do
		local rewardList, tooltipFunction, alreadyUnlockedCheck,  overrideTooltip = rewardsTypes[t][1], rewardsTypes[t][2], rewardsTypes[t][3], rewardsTypes[t][4]
		if rewardList then
			for i = 1, #rewardList do
				local alreadyUnlocked = alreadyUnlockedCheck(rewardList[i])
				if not (cullUnlocked and alreadyUnlocked) then
					if not rewardsHolder then
						rewardsHolder = Control:New {
							x = 10,
							right = 10,
							bottom = bottom,
							height = 94,
							padding = {0, 0, 0, 0},
							parent = holder,
						}
						
						TextBox:New {
							x = 4,
							y = 2,
							right = 4,
							height = 30,
							text = name,
							font = Configuration:GetFont(2),
							parent = rewardsHolder
						}
						
						scroll = ScrollPanel:New {
							classname = "scrollpanel_borderless",
							x = 3,
							y = 18,
							right = 3,
							bottom = 2,
							scrollbarSize = 12,
							padding = {0, 0, 0, 0},
							parent = rewardsHolder,
						}
					end
					
					local info, imageFile, imageOverlay, count = tooltipFunction(rewardList[i])
					
					local x, y = (REWARD_ICON_SIZE*widthMult + 4)*math.floor(position/stackHeight), (position%stackHeight)*REWARD_ICON_SIZE/stackHeight
					if imageFile then
						local color = nil
						local statusString = ""
						if alreadyUnlocked then
							color = {0.5, 0.5, 0.5, 0.5}
							statusString = " (already unlocked)"
						end
						local tooltip = (overrideTooltip and info) or ((info.humanName or "???") .. statusString .. "\n " .. (info.description or ""))
						
						local image = Image:New{
							x = x,
							y = y,
							width = REWARD_ICON_SIZE*widthMult,
							height = REWARD_ICON_SIZE/stackHeight,
							keepAspect = true,
							color = color,
							tooltip = tooltip,
							file = imageOverlay or imageFile,
							file2 = imageOverlay and imageFile,
							parent = scroll,
						}
						if count then
							Label:New {
								x = 2,
								y = "50%",
								right = 4,
								bottom = 6,
								align = "right",
								fontsize = Configuration:GetFont(3).size,
								caption = count,
								parent = image,
							}
						end
						function image:HitTest(x,y) return self end
					else
						local tooltip = (overrideTooltip and info) or (info.name or "???")
						
						Button:New {
							x = x,
							y = y,
							width = REWARD_ICON_SIZE*widthMult,
							height = REWARD_ICON_SIZE/stackHeight,
							caption = tooltip,
							font = Configuration:GetFont(2),
							parent = scroll
						}
					end
					
					position = position + 1
				end
			end
		end
	end
	
	return (rewardsHolder and true) or false
end

local function MakeBonusObjectiveLine(parent, bottom, planetData, bonusObjectiveSuccess)

	local objectiveConfig = planetData.gameConfig.bonusObjectiveConfig
	if not objectiveConfig then
		return bottom
	end
	
	if bonusObjectiveSuccess then
		local function IsObjectiveUnlocked(objectiveID)
			return not bonusObjectiveSuccess[objectiveID]
		end
		local function GetObjectiveInfo(objectiveID)
			local tooltip = objectiveConfig[objectiveID].description
			if WG.CampaignData.GetBonusObjectiveComplete(planetData.index, objectiveID) then
				tooltip = tooltip .. " \n(Previously complete)"
			elseif bonusObjectiveSuccess[objectiveID] then
				tooltip = tooltip .. " \n(Newly complete)"
			else
				tooltip = tooltip .. " \n(Incomplete)"
			end 
			return tooltip, objectiveConfig[objectiveID].image, objectiveConfig[objectiveID].imageOverlay
		end
		local objectiveList = {}
		for i = 1, #objectiveConfig do
			objectiveList[i] = i
		end
		if MakeRewardList(parent, bottom, "Bonus Objectives", {{objectiveList, GetObjectiveInfo, IsObjectiveUnlocked, true}}, false) then
			return bottom + 98
		end
	else
		local function IsObjectiveUnlocked(objectiveID)
			return not WG.CampaignData.GetBonusObjectiveComplete(planetData.index, objectiveID)
		end
		local function GetObjectiveInfo(objectiveID)
			local tooltip = objectiveConfig[objectiveID].description
			return tooltip, objectiveConfig[objectiveID].image, objectiveConfig[objectiveID].imageOverlay
		end
		local objectiveList = {}
		for i = 1, #objectiveConfig do
			objectiveList[i] = i
		end
		if MakeRewardList(parent, bottom, "Bonus Objectives", {{objectiveList, GetObjectiveInfo, IsObjectiveUnlocked, true}}, false) then
			return bottom + 98
		end
	end
	
	return bottom
end

local function MakeRewardsPanel(parent, planetData, cullUnlocked, showCodex, bonusObjectiveSuccess)
	local bottom = 82
	
	rewards = planetData.completionReward
	
	if showCodex then
		if MakeRewardList(parent, bottom, "Codex", {{rewards.codexEntries, WG.CampaignData.GetCodexEntryInfo, WG.CampaignData.GetCodexEntryIsUnlocked}}, cullUnlocked, 3.96, 2) then
			bottom = bottom + 98
		end
	end
	
	local unlockRewards = {
		{rewards.units, WG.CampaignData.GetUnitInfo, WG.CampaignData.GetUnitIsUnlocked},
		{rewards.modules, WG.CampaignData.GetModuleInfo, WG.CampaignData.GetModuleIsUnlocked},
		{rewards.abilities, WG.CampaignData.GetAbilityInfo, WG.CampaignData.GetAbilityIsUnlocked}
	}
	
	if MakeRewardList(parent, bottom, "Unlocks", unlockRewards, cullUnlocked) then
		bottom = bottom + 98
	end
	
	bottom = MakeBonusObjectiveLine(parent, bottom, planetData, bonusObjectiveSuccess)
	
	return bottom
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Planet capturing

local function MakeWinPopup(planetData, bonusObjectiveSuccess)
	local victoryWindow = Window:New {
		caption = "",
		name = "victoryWindow",
		parent = WG.Chobby.lobbyInterfaceHolder,
		width = 520,
		height = 560,
		resizable = false,
		draggable = false,
		classname = "main_window",
	}
	
	local childWidth = victoryWindow.width - victoryWindow.padding[1] - victoryWindow.padding[3]
	
	Label:New {
		x = 0,
		y = 6,
		width = childWidth,
		height = 30,
		align = "center",
		caption = "Victory on " .. planetData.name .. "!",
		font = WG.Chobby.Configuration:GetFont(4),
		parent = victoryWindow
	}
	
	local experienceHolder = Control:New {
		x = 20,
		y = 58,
		right = 20,
		height = 100,
		padding = {0, 0, 0, 0},
		parent = victoryWindow,
	}
	
	local experienceDisplay = WG.CommanderHandler.GetExperienceDisplay(experienceHolder, 38, true)
	
	local rewardsHeight = MakeRewardsPanel(victoryWindow, planetData, true, true, bonusObjectiveSuccess)
	
	victoryWindow:SetPos(nil, nil, nil, 200 + rewardsHeight)
	
	local function CloseFunc()
		victoryWindow:Dispose()
	end
	
	local buttonClose = Button:New {
		x = (childWidth - 136)/2,
		width = 136,
		bottom = 1,
		height = 70,
		caption = i18n("continue"),
		font = WG.Chobby.Configuration:GetFont(3),
		parent = victoryWindow,
		classname = "negative_button",
		OnClick = {
			function()
				CloseFunc()
			end
		},
	}
	
	local popupHolder = WG.Chobby.PriorityPopup(victoryWindow, CloseFunc, CloseFunc)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateExperience(oldExperience, oldLevel, newExperience, newLevel, gainedBonusExperience)
		experienceDisplay.AddFancyExperience(newExperience - oldExperience, gainedBonusExperience)
	end
	
	return externalFunctions
end

local function ProcessPlanetVictory(planetID, bonusObjectives)
	if selectedPlanet then
		selectedPlanet.Close()
		selectedPlanet = nil
	end
	-- It is important to popup before capturing the planet to filter out the
	-- already unlocked rewards.
	currentWinPopup = MakeWinPopup(planetConfig[planetID], bonusObjectives)
	WG.CampaignData.CapturePlanet(planetID, bonusObjectives)
end

local function ProcessPlanetDefeat(planetID)
	if selectedPlanet then
		selectedPlanet.Close()
		selectedPlanet = nil
	end
	WG.Chobby.InformationPopup("Battle for " .. planetConfig[planetID].name .. " lost.", nil, nil, "Defeat")
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- TODO: use shader animation to ease info panel in

local function SelectPlanet(planetHandler, planetID, planetData, startable)
	local Configuration = WG.Chobby.Configuration
	
	local starmapInfoPanel = Panel:New{
		parent = planetHandler,
		x = 32,
		y = 32,
		right = 32,
		bottom = 32,
	}
	
	local subPanel = Panel:New{
		parent = starmapInfoPanel,
		x = "50%",
		y = "10%",
		right = "5%",
		bottom = "5%",
		children = {
			-- title
			Label:New{
				x = 8,
				y = 12,
				caption = string.upper(planetData.name),
				font = Configuration:GetFont(4),
			},
			-- grid of details
			Grid:New{
				x = 8,
				y = 60,
				right = 4,
				bottom = "72%",
				columns = 2,
				rows = 2,
				children = {
					Label:New{caption = "Primary", font = Configuration:GetFont(3)},
					Label:New{caption = planetData.infoDisplay.primary .. " (" .. planetData.infoDisplay.primaryType .. ") ", font = Configuration:GetFont(3)},
					Label:New{caption = "Type", font = Configuration:GetFont(3)},
					Label:New{caption = planetData.infoDisplay.terrainType or "<UNKNOWN>", font = Configuration:GetFont(3)},
					--Label:New{caption = "Radius", font = Configuration:GetFont(3)},
					--Label:New{caption = planetData.infoDisplay.radius or "<UNKNOWN>", font = Configuration:GetFont(3)},
					--Label:New{caption = "Military rating", font = Configuration:GetFont(3)},
					--Label:New{caption = tostring(planetData.infoDisplay.milRating or "<UNKNOWN>"), font = Configuration:GetFont(3)},
				},
			},
			-- desc text
			TextBox:New {
				x = 8,
				y = "30%",
				right = 4,
				bottom = "25%",
				text = planetData.infoDisplay.text,
				font = Configuration:GetFont(3),
			},
		}
	}
	
	MakeRewardsPanel(subPanel, planetData)
	
	if startable then
		local startButton = Button:New{
			right = 10,
			bottom = 10,
			width = 135,
			height = 70,
			classname = "action_button",
			parent = subPanel,
			caption = i18n("start"),
			font = Configuration:GetFont(4),
			OnClick = {
				function(self)
					WG.PlanetBattleHandler.StartBattle(planetID, planetData)
				end
			}
		}
		
		if Configuration.debugMode then
			local autoWinButton = Button:New{
				right = 150,
				bottom = 10,
				width = 150,
				height = 70,
				classname = "action_button",
				parent = subPanel,
				caption = "Auto Win",
				font = Configuration:GetFont(4),
				OnClick = {
					function(self)
						ProcessPlanetVictory(planetID)
					end
				}
			}
			local autoLostButton = Button:New{
				right = 305,
				bottom = 10,
				width = 175,
				height = 70,
				classname = "action_button",
				parent = subPanel,
				caption = "Auto Lose",
				font = Configuration:GetFont(4),
				OnClick = {
					function(self)
						ProcessPlanetDefeat(planetID)
					end
				}
			}
		end
	end
	
	-- close button
	Button:New{
		parent = starmapInfoPanel,
		y = 3,
		right = 3,
		width = 80,
		height = 45,
		classname = "negative_button",
		caption = i18n("close"),
		font = Configuration:GetFont(3),
		OnClick = {
			function(self) 
				self.parent:Dispose() 
			end
		}
	}
	
	-- list of missions on this planet
	--local missionsStack = StackPanel:New {
	--	parent = starmapInfoPanel,
	--	orientation = "vertical",
	--	x = 4,
	--	right = 4,
	--	height = "25%",
	--	bottom = 0,
	--	resizeItems = false,
	--	autoArrangeV = false,
	--}
	--for i=1,#planetDef.missions do
	--end
	
	-- planet image
	local planetImage = Image:New{
		parent = starmapInfoPanel,
		x = 0,
		right = "50%",
		y = (starmapInfoPanel.height - planetData.infoDisplay.size) / 2,
		height = planetData.infoDisplay.size,
		keepAspect = true,
		file = planetData.infoDisplay.image,
	}
	
	-- background
	local overflowX = (starmapInfoPanel.width - starmapInfoPanel.width) / 2
	local overflowY = (starmapInfoPanel.width - starmapInfoPanel.height) / 2
	local bg = Image:New{
		parent = starmapInfoPanel,
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		file = planetData.infoDisplay.backgroundImage,
		keepAspect = false,
	}
	-- force offscreen position
	bg.x = -overflowX
	bg.y = -overflowY
	bg:Invalidate()
	
	starmapInfoPanel:SetLayer(1)
	
	starmapInfoPanel.OnResize = starmapInfoPanel.OnResize or {}
	starmapInfoPanel.OnResize[#starmapInfoPanel.OnResize + 1] = function(obj, xSize, ySize)
		planetImage:SetPos(nil, math.floor((ySize - planetData.infoDisplay.size)/2))
	end
	
	local externalFunctions = {}
	
	function externalFunctions.Close()
		starmapInfoPanel:Dispose() 
	end
	
	return externalFunctions
end

local function GetPlanet(galaxyHolder, planetID, planetData, adjacency)
	local Configuration = WG.Chobby.Configuration
	
	local planetSize = planetData.mapDisplay.size
	local xPos, yPos = planetData.mapDisplay.x, planetData.mapDisplay.y
	
	local captured = WG.CampaignData.IsPlanetCaptured(planetID)
	local startable
	
	local target
	local targetSize = math.ceil(math.floor(planetSize*1.35)/2)*2
	local planetOffset = math.floor((targetSize - planetSize)/2)
	
	local planetHolder = Control:New{
		x = 0,
		y = 0,
		width = targetSize,
		height = targetSize,
		padding = {0, 0, 0, 0},
		parent = galaxyHolder,
	}
	
	local button = Button:New{
		x = planetOffset,
		y = planetOffset,
		width = planetSize,
		height = planetSize,
		classname = "button_planet",
		caption = "",
		OnClick = { 
			function(self)
				if selectedPlanet then
					selectedPlanet.Close()
					selectedPlanet = nil
				end
				selectedPlanet = SelectPlanet(galaxyHolder, planetID, planetData, startable)
			end
		},
		parent = planetHolder,
	}
	
	local image = Image:New {
		x = 3,
		y = 3,
		right = 2,
		bottom = 2,
		file = planetData.mapDisplay.image,
		keepAspect = true,
		parent = button,
	}
	
	if Configuration.debugMode then
		local number = Label:New {
			x = 3,
			y = 3,
			right = 6,
			bottom = 6,
			align = "center",
			valign = "center",
			caption = planetID,
			font = Configuration:GetFont(3),
			parent = image,
		}
	end
	
	local function UpdateSize(sizeScale)
		planetSize = planetData.mapDisplay.size*sizeScale
		targetSize = math.ceil(math.floor(planetSize*1.35)/2)*2
		planetOffset = math.floor((targetSize - planetSize)/2)
		
		button:SetPos(planetOffset, planetOffset, planetSize, planetSize)
	end
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(xSize, ySize)
		UpdateSize(math.max(1, xSize/1050))
		local x = math.max(0, math.min(xSize - targetSize, xPos*xSize - targetSize/2))
		local y = math.max(0, math.min(ySize - targetSize, yPos*ySize - targetSize/2))
		planetHolder:SetPos(x, y, targetSize, targetSize)
	end
	
	function externalFunctions.UpdateStartable()
		captured = WG.CampaignData.IsPlanetCaptured(planetID)
		startable = captured or planetData.startingPlanet
		if not startable then
			for i = 1, #adjacency do
				if adjacency[i] then
					if planetList[i].GetCaptured() then
						startable = true
						break
					end
				end
			end
		end
		
		if startable then
			image.color = PLANET_START_COLOR
		else
			image.color = PLANET_NO_START_COLOR
		end
		image:Invalidate()
		
		local targetable = startable and not captured
		if target then
			if not targetable then
				target:Dispose()
				target = nil
			end
		elseif targetable then
			target = Image:New{
				x = 0,
				y = 0,
				right = 0,
				bottom = 0,
				file = TARGET_IMAGE,
				keepAspect = true,
				parent = planetHolder,
			}
			target:SendToBack()
		end
	end
	
	function externalFunctions.GetCaptured()
		return WG.CampaignData.IsPlanetCaptured(planetID)
	end
	
	return externalFunctions
end

local function DrawEdgeLines()
	for i = 1, #planetEdgeList do
		for p = 1, 2 do
			local pid = planetEdgeList[i][p]
			local planetData = planetList[pid]
			local x, y = planetConfig[pid].mapDisplay.x, planetConfig[pid].mapDisplay.y
			gl.Color((planetData.GetCaptured() and ACTIVE_COLOR) or INACTIVE_COLOR)
			gl.Vertex(x, y)
		end
	end
end

local function CreateEdgeList()
	gl.BeginEnd(GL.LINES, DrawEdgeLines)
end

local function UpdateEdgeList()
	gl.DeleteList(edgeDrawList)
	edgeDrawList = gl.CreateList(CreateEdgeList)
end

local function UpdateAllStartable()
	for i = 1, #planetList do
		planetList[i].UpdateStartable()
	end
end

local function InitializePlanetHandler(parent)
	local Configuration = WG.Chobby.Configuration
	
	local window = ((Configuration.debugMode and Panel) or Control):New {
		name = "planetsHolder",
		padding = {0,0,0,0},
		parent = parent,
	}
	local planetWindow = Control:New {
		name = "planetWindow",
		x = 0,
		y = 0,
		width = "100%",
		height = "100%",
		padding = {0,0,0,0},
		parent = window,
	}
	
	local planetData = Configuration.campaignConfig.planetDefs
	planetConfig, planetAdjacency, planetEdgeList = planetData.planets, planetData.planetAdjacency, planetData.planetEdgeList
	
	planetList = {}
	for i = 1, #planetConfig do
		planetList[i] = GetPlanet(planetWindow, i, planetConfig[i], planetAdjacency[i])
	end
	
	UpdateAllStartable()
	UpdateEdgeList()
	
	local graph = Chili.Control:New{
		x       = 0,
		y       = 0,
		height  = "100%",
		width   = "100%",
		padding = {0,0,0,0},
		drawcontrolv2 = true,
		DrawControl = function (obj)
			local x = obj.x
			local y = obj.y
			local w = obj.width
			local h = obj.height
			
			gl.PushMatrix()
			gl.Translate(x, y, 0)
			gl.Scale(w, h, 1)
			gl.LineWidth(3)
			gl.CallList(edgeDrawList)
			gl.PopMatrix()
		end,
		parent = window,
	}
	
	local function PlanetCaptured(listener, planetID)
		planetList[planetID].UpdateStartable()
		UpdateAllStartable(planetList)
		UpdateEdgeList()
	end
	WG.CampaignData.AddListener("PlanetCaptured", PlanetCaptured)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(x, y, width, height)
		window:SetPos(x, y, width, height)
		if x then
			for i = 1, #planetList do
				planetList[i].UpdatePosition(width, height)
			end
		end
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ingame interface

local BATTLE_WON_STRING = "Campaign_PlanetBattleWon"
local BATTLE_LOST_STRING = "Campaign_PlanetBattleLost"

local function MakeBonusObjectivesList(bonusObjectives)
	if not bonusObjectives then
		return false
	end
	local list = {}
	local length = string.len(bonusObjectives)
	for i = 1, length do
		list[i] = (string.sub(bonusObjectives, i, i) == "1")
	end
	return list
end

function widget:RecvLuaMsg(msg)
	if string.find(msg, BATTLE_WON_STRING) then
		local endOfID = string.find(msg, " ")
		local planetID = tonumber(string.sub(msg, 25, endOfID))
		local bonusObjectives = string.sub(msg, endOfID + 1)
		if planetID and planetConfig and planetConfig[planetID] then
			ProcessPlanetVictory(planetID, MakeBonusObjectivesList(bonusObjectives))
		end
	end
	if string.find(msg, BATTLE_LOST_STRING) then
		msg = string.sub(msg, 26)
		local planetID = tonumber(msg)
		if planetID and planetConfig and planetConfig[planetID] then
			ProcessPlanetDefeat(planetID)
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local externalFunctions = {}

function externalFunctions.GetControl()
	
	local planetsHandler = {}
	
	local window = Control:New {
		name = "campaignHandler",
		x = "0%",
		y = "0%",
		width = "100%",
		height = "100%",
		padding = {0,0,0,0},
		OnParentPost = {
			function(obj, parent)
				if obj:IsEmpty() then
					planetsHandler = InitializePlanetHandler(obj)
				end
				
				local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
				local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
				local x, y, width, height = background:SetOverride(GALAXY_IMAGE, IMAGE_BOUNDS)
				planetsHandler.UpdatePosition(x, y, width, height)
				
				obj:UpdateClientArea()
			end
		},
		OnOrphan = {
			function(obj)
				if not obj.disposed then -- AutoDispose
					local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
					background:RemoveOverride()
				end
			end
		},
		OnResize = {
			function(obj, xSize, ySize)
				if not obj.parent then
					return
				end
				local background = WG.Chobby.interfaceRoot.GetBackgroundHolder()
				local x, y = obj:LocalToScreen(0, 0)
				
				local x, y, width, height = background:ResizeAspectWindow(x, y, xSize, ySize)
				planetsHandler.UpdatePosition(x, y, width, height)
			end
		},
	}
	return window
end

--------------------------------------------------------------------------------
-- Callins
--------------------------------------------------------------------------------

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	local function CampaignLoaded(listener)
		UpdateAllStartable()
		UpdateEdgeList()
		if selectedPlanet then
			selectedPlanet.Close()
			selectedPlanet = nil
		end
	end
	WG.CampaignData.AddListener("CampaignLoaded", CampaignLoaded)
	
	local function GainExperience(listener, oldExperience, oldLevel, newExperience, newLevel, gainedBonusExperience)
		if currentWinPopup then
			currentWinPopup.UpdateExperience(oldExperience, oldLevel, newExperience, newLevel, gainedBonusExperience)
		end
	end
	WG.CampaignData.AddListener("GainExperience", GainExperience)
	
	WG.CampaignHandler = externalFunctions
end

function widget:Shutdown()
	WG.CampaignHandler = nil
end