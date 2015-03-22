local versionNumber = "v1.0"

function widget:GetInfo()
	return {
		name      = "Delay API",
		desc      = versionNumber .. " Allows delaying of widget calls.",
		author    = "gajop",
		date      = "future",
		license   = "GNU LGPL, v2.1 or later",
		layer     = -10000,
		enabled   = true  --  loaded by default?
	}
end

local currentTime = 0
local calls = {}

-- delay in miliseconds
local function DelayCall(f, delay)
	delay = math.floor(delay)
	local executeTime = currentTime + delay
	table.insert(calls, {f, executeTime})
end

function widget:Update()
	currentTime = os.clock()
	for i = #calls, 1, -1 do
		local call = calls[i]
		if currentTime >= call[2] then
			call[1]()
			calls[i] = nil
		end
	end
end

WG.Delay = DelayCall
