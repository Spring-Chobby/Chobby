
Spring.Utilities = Spring.Utilities or {}

-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

function Spring.Utilities.FormatTime(seconds, includeSeconds)
	local hours = math.floor(seconds/3600)
	local minutes = math.floor(seconds/60)%60
	local seconds = math.floor(seconds)%60
	
	--Spring.Echo("pastTime", pastTime[1], pastTime[2], pastTime[3], pastTime[4], "pastSeconds", pastSeconds)
	--Spring.Echo("currentTime", currentTime[1], currentTime[2], currentTime[3], currentTime[4], "currentSeconds", currentSeconds)
	--Spring.Echo("seconds", seconds)
	
	local timeText = ""
	if hours > 0 then
		timeText = timeText .. hours .. "h "
	end
	if hours > 0 or minutes > 0 or (not includeSeconds) then
		timeText = timeText .. minutes .. "m "
	end
	if includeSeconds then
		timeText = timeText .. seconds .. "s "
	end
	
	return timeText
end

function Spring.Utilities.GetTimeToPast(pastTimeString, includeSeconds)
	if (not pastTimeString) or (type(pastTimeString) ~= "string") then
		return "??"
	end

	-- Example: 2016-07-21T14:49:00.4731696Z
	local pastTime = {
		string.sub(pastTimeString, 18, 19),
		string.sub(pastTimeString, 15, 16),
		string.sub(pastTimeString, 12, 13),
		string.sub(pastTimeString, 9, 10),
		--string.sub(pastTimeString, 6, 7),
		--string.sub(pastTimeString, 0, 4),
	}

	for i = 1, #pastTime do
		pastTime[i] = tonumber(pastTime[i])
		if not pastTime[i] then
			return "??"
		end
	end

	local currentTime = {
		tonumber(os.date("!%S")),
		tonumber(os.date("!%M")),
		tonumber(os.date("!%H")),
		tonumber(os.date("!%d")),
		--tonumber(os.date("!%m")),
		--tonumber(os.date("!%Y")),
	}

	local pastSeconds = pastTime[1] + 60*(pastTime[2] + 60*pastTime[3])
	local currentSeconds = currentTime[1] + 60*(currentTime[2] + 60*currentTime[3])
	if currentTime[4] ~= pastTime[4] then
		-- Always assume that the past time is one day behind.
		currentSeconds = currentSeconds + 86400
	end
	
	return Spring.Utilities.FormatTime(currentSeconds - pastSeconds, includeSeconds)
end
