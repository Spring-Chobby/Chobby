--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Limit FPS",
		desc      = "Limits FPS to save idle CPU cycles",
		author    = "Licho",
		date      = "-306210.1318053026",
		license   = "GPL-v2",
		layer     = 1001,
		enabled   = true,
	}
end

local MAX_FPS = 15

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

local lastTimer

function widget:Initialize() 
	lastTimer = Spring.GetTimer();
end

function widget:AllowDraw()
	local timer = Spring.GetTimer();
	local diff = Spring.DiffTimers(timer, lastTimer)
	if (diff >= 1/MAX_FPS) then
		lastTimer = timer
		return true
	end 
	return false
end
