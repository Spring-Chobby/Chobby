--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Limit FPS",
		desc      = "Limits FPS to save idle CPU cycles",
		author    = "Licho",
		date      = "-306210.1318053026",
		license   = "GPL-v2",
		layer     = -3000,
		handler   = true,
		api       = true, -- Makes KeyPress occur before chili
		enabled   = true,
	}
end

local MAX_FPS = 15
local FAST_FPS = 40
local oldX, oldY

local lastTimer
local forceRedraw = false
local fastRedraw = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local LimitFps = {}

function LimitFps.ForceRedraw()
	forceRedraw = true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function widget:Initialize() 
	lastTimer = Spring.GetTimer();
	
	WG.LimitFps = LimitFps
end

function widget:AllowDraw()
	--Spring.Echo("AllowDraw game", Spring.GetGameName())
	if forceRedraw then
		forceRedraw = false
		fastRedraw = false
		return true
	end
	local timer = Spring.GetTimer();
	local diff = Spring.DiffTimers(timer, lastTimer)
	if (fastRedraw and (diff >= 1/FAST_FPS)) then
		fastRedraw = false
		lastTimer = timer
		return true
	elseif (diff >= 1/MAX_FPS) then
		lastTimer = timer
		return true
	end
	return false
end

function widget:Update()
	local x, y = Spring.GetMouseState()
	--Spring.Echo("Mouse", x, oldX, y, oldY)
	if x ~= oldX or y ~= oldY then
		fastRedraw = true
	end
	oldX, oldY = x, y
end

function widget:MousePress()
	forceRedraw = true
	return false
end

function widget:KeyPress()
	forceRedraw = true
	return false
end
