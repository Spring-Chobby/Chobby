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
	x = 850/4000,
	y = 800/2602,
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

local playerUnlocks = {
	"cormex",
	"armsolar",
	"armpw",
	"factorycloak",
}

local planetList

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
		right = 8,
		bottom = "10%",
		children = {
			-- title
			Label:New{
				x = textX,
				y = 12,
				caption = string.upper(planetData.name),
				font = Configuration:GetFont(4),
			},
			-- grid of details
			Grid:New{
				x = 4,
				y = 72,
				right = 4,
				bottom = "60%",
				columns = 2,
				rows = 4,
				children = {
					Label:New{caption = "Type", font = Configuration:GetFont(3)},
					Label:New{caption = planetData.infoDisplay.terrainType or "<UNKNOWN>", font = Configuration:GetFont(3)},
					Label:New{caption = "Radius", font = Configuration:GetFont(3)},
					Label:New{caption = planetData.infoDisplay.radius or "<UNKNOWN>", font = Configuration:GetFont(3)},
					Label:New{caption = "Primary", font = Configuration:GetFont(3)},
					Label:New{caption = planetData.infoDisplay.primary .. " (" .. planetData.infoDisplay.primaryType .. ") ", font = Configuration:GetFont(3)},
					Label:New{caption = "Military rating", font = Configuration:GetFont(3)},
					Label:New{caption = tostring(planetData.infoDisplay.milRating or "<UNKNOWN>"), font = Configuration:GetFont(3)},
				},
			},
			-- desc text
			TextBox:New {
				x = 4,
				y = "45%",
				right = 4,
				bottom = "25%",
				text = planetData.infoDisplay.text,
				font = Configuration:GetFont(2),
			},
		}
	}
	
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
					WG.PlanetBattleHandler.StartBattle(planetID, planetData, playerUnlocks)
				end
			}
		}
		
		if Configuration.debugMode then
			local autoWinButton = Button:New{
				right = 150,
				bottom = 10,
				width = 135,
				height = 70,
				classname = "action_button",
				parent = subPanel,
				caption = "Auto Win",
				font = Configuration:GetFont(4),
				OnClick = {
					function(self)
						WG.CampaignData.CapturePlanet(planetID)
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
				SelectPlanet(galaxyHolder, planetID, planetData, startable)
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
			right = 2,
			bottom = 2,
			caption = planetID,
			font = Configuration:GetFont(4),
			parent = image,
		}
	end
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(xSize, ySize)
		local x = math.max(0, math.min(xSize - targetSize, xPos*xSize - targetSize/2))
		local y = math.max(0, math.min(ySize - targetSize, yPos*ySize - targetSize/2))
		planetHolder:SetPos(x, y)
	end
	
	function externalFunctions.UpdateStartable()
		captured = WG.CampaignData.IsPlanetCaptured(planetID)
		startable = captured
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
				width = targetSize,
				height = targetSize,
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
	
	local window = Control:New {
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

local function MakeWinPopup(planetData)
	local reward = planetData.completionReward
	if not reward then
		WG.Chobby.InformationPopup("You won the battle.")
		return
	end
	local wonString = ""
	if reward.units then
		for i = 1, #reward.units do
			wonString = wonString .. " " .. reward.units[i] 
		end
	end
	if reward.modules then
		for i = 1, #reward.modules do
			wonString = wonString .. " " ..  reward.modules[i]
		end
	end
	WG.Chobby.InformationPopup("You won the battle and are rewarded with" .. wonString .. ".")
end

function widget:RecvLuaMsg(msg)
	if string.find(msg, BATTLE_WON_STRING) then
		msg = string.sub(msg, 25)
		local planetID = tonumber(msg)
		if planetID and planetConfig and planetConfig[planetID] then
			local config = planetConfig[planetID]
			WG.CampaignData.CapturePlanet(planetID)
			MakeWinPopup(planetConfig[planetID])

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

function externalFunctions.Refresh()
	UpdateAllStartable()
	UpdateEdgeList()
end

--------------------------------------------------------------------------------
-- Callins
--------------------------------------------------------------------------------

function widget:Initialize()
	CHOBBY_DIR = "LuaMenu/widgets/chobby/"
	VFS.Include("LuaMenu/widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignHandler = externalFunctions
end

function widget:Shutdown()
	WG.CampaignHandler = nil
end