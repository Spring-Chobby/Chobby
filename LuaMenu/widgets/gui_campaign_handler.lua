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
	x = 800/4000,
	y = 800/2602,
	width = 2400/4000,
	height = 1500/2602,
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function InitializeControls(parent)
	local window = Window:New {
		name = "planetsHolder",
		padding = {0,0,0,0},
		resizable = false,
		draggable = false,
		parent = parent,
	}
	
	local externalFunctions = {}
	
	function externalFunctions.UpdatePosition(x, y, width, height)
		window:SetPos(x, y, width, height)
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
					planetsHandler = InitializeControls(obj)
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