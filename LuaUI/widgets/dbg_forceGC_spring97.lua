--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "GC at >300MB",
    desc      = "Workaround for abnormal memory usage while rejoining game in Spring 97."
				.."Usual ingame usage never exceed 100MB.",
    author    = "xponen",
    version   = "1",
    date      = "4 June 2014",
    license   = "none",
    layer     = math.huge,
	alwaysStart = true,
    enabled   = true  --  loaded by default?
  }
end
--Note: cannot use widget:GameProgress() to check for rejoining status because its broken in Spring 97 (the callin didn't tell rejoiner the actual current frame)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:Initialize()
	if (Game.version:find('91.0') == 1) then
		Spring.Echo("Removed 'GC at >100MB': not needed for Spring 91")
		widgetHandler:RemoveWidget()
	end
end

local timer = Spring.GetTimer() --time of last "collect garbage".
local interval = 20 -- interval of 20 seconds
local memThreshold = 102400 --amount of memory usage (kilobyte) before calling LUA GC
function widget:Update()
	local currentTime = Spring.GetTimer()
	if Spring.DiffTimers(currentTime, timer) >= interval then --if minimum interval reached:
		timer = currentTime
		local memusage = collectgarbage("count") --get total amount of memory usage
		if (memusage > memThreshold) then
			local memString = "Calling Garbage Collector on excessive Lua memory usage: " .. ('%.1f'):format(memusage/1024) .. " MB" --display current memory usage to player
			Spring.Echo(memString)
			collectgarbage("collect") --collect garbage
		end
	end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------