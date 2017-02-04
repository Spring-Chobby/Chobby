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

local planetImages = {
	LUA_DIRNAME .. "images/planets/arid01.png",
	LUA_DIRNAME .. "images/planets/barren01.png",
	LUA_DIRNAME .. "images/planets/terran03_damaged.png",
	LUA_DIRNAME .. "images/planets/tundra01.png",
}

local planetPositions = {
	{0.22, 0.1},
	{0.31, 0.19},
	{0.3, 0.36},
	{0.14, 0.44},
	{0.05, 0.54},
	{0.3, 0.52},
	{0.24, 0.69},
	{0.16, 0.91},
	{0.27, 0.85},
	{0.7, 0.9},
	{0.56, 0.87},
	{0.42, 0.72},
	{0.64, 0.79},
	{0.59, 0.66},
	{0.61, 0.52},
	{0.66, 0.35},
	{0.47, 0.11},
	{0.64, 0.19},
	{0.72, 0.08},
	{0.72, 0.66},
	{0.79, 0.52},
	{0.85, 0.35},
	{0.89, 0.22},
	{0.92, 0.63},
	{0.41, 0.91},
}

local PLANET_SIZE = 54

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function GetPlanet(planetHolder, xPos, yPos)
	
	local button = Button:New{
		x = 0,
		y = 0,
		width = PLANET_SIZE,
		height = PLANET_SIZE,
		classname = "button_planet",
		caption = "",
		OnClick = { 
			function(self)
				--SelectPlanet(planetDef.id)
			end
		},
		parent = planetHolder,
	}
	
	local image = Image:New {
		file = planetImages[math.floor(math.random()*4) + 1],
		x = 3,
		y = 3,
		right = 2,
		bottom = 2,
		keepAspect = true,
		parent = button,
	}
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(xSize, ySize)
		local x = math.max(0, math.min(xSize - PLANET_SIZE, xPos*xSize - PLANET_SIZE/2))
		local y = math.max(0, math.min(ySize - PLANET_SIZE, yPos*ySize - PLANET_SIZE/2))
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
	for i = 1, #planetPositions do
		planets[i] = GetPlanet(window, planetPositions[i][1], planetPositions[i][2])
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