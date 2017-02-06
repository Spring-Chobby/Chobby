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

local planetList = VFS.Include("campaign/planetDefs.lua")

local playerUnlocks = {
	"cormex",
	"armsolar",
	"armpw",
	"factorycloak",
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- TODO: use shader animation to ease info panel in
local function SelectPlanet(planetHandler, planetData)
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
				WG.PlanetBattleHandler.StartBattle(planetData, playerUnlocks)
			end
		}
	}
	
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


local function GetPlanet(planetHolder, planetData)
	local planetSize = planetData.mapDisplay.size
	local xPos, yPos = planetData.mapDisplay.x, planetData.mapDisplay.y
	
	local button = Button:New{
		x = 0,
		y = 0,
		width = planetSize,
		height = planetSize,
		classname = "button_planet",
		caption = "",
		OnClick = { 
			function(self)
				SelectPlanet(planetHolder, planetData)
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
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(xSize, ySize)
		local x = math.max(0, math.min(xSize - planetSize, xPos*xSize - planetSize/2))
		local y = math.max(0, math.min(ySize - planetSize, yPos*ySize - planetSize/2))
		button:SetPos(x,y)
	end
	
	return externalFunctions
end

local function InitializePlanetHandler(parent)
	local window = Control:New {
		name = "planetsHolder",
		padding = {0,0,0,0},
		resizable = false,
		draggable = false,
		parent = parent,
	}
	
	local planets = {}
	for i = 1, #planetList do
		planets[i] = GetPlanet(window, planetList[i])
	end
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(x, y, width, height)
		window:SetPos(x, y, width, height)
		if x then
			for i = 1, #planets do
				planets[i].UpdatePosition(width, height)
			end
		end
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External Interface

local externalFunctions = {}

function externalFunctions.GetControl()
	
	local planetsHandler
	
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
	
	WG.CampaignHandler = externalFunctions
end

function widget:Shutdown()
	WG.CampaignHandler = nil
end