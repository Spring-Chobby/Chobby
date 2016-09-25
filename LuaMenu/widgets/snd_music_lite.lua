--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name	= "Music Player Lite",
		desc	= "Plays music for ingame lobby client",
		author	= "GoogleFrog and KingRaptor",
		date	= "25 September 2016",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local TRACK_NAME = 'sounds/music/lobby/A Magnificent Journey (Alternative Version).ogg'

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function StartTrack()
	Spring.StopSoundStream()
	Spring.PlaySoundStream(TRACK_NAME, 1)
	Spring.Echo("PlaySoundStream(TRACK_NAME, 1)", TRACK_NAME, 1)
end

local function StopTrack()
	Spring.StopSoundStream()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Update()
	local playedTime, totalTime = Spring.GetSoundStreamTime()
	playedTime = math.floor(playedTime)
	totalTime = math.floor(totalTime)

	if (playedTime >= totalTime) then
		StartTrack()
	end
end

local MusicHandler = {
	StartTrack = StartTrack,
}

function widget:Initialize()
	WG.MusicHandler = MusicHandler
end

function widget:GamePreload()
	-- ingame, no longer any of our business
	if Spring.GetGameName() ~= "" then
		StopTrack()
	end
end

-- called when returning to menu from a game
function widget:ActivateMenu()
	-- start playing music again
	StartTrack()
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------