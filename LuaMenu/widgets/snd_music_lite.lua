--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name	= "Music Player Lite",
		desc	= "Plays music for ingame lobby client",
		author	= "GoogleFrog and KingRaptor",
		date	= "25 September 2016",
		license	= "GNU GPL, v2 or later",
		layer	= 2000,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local playingTrack	-- boolean
local previousTrack
local loopTrack	-- string trackPath

local randomTrackList = {
	"sounds/lobbyMusic/A Magnificent Journey (Alternative Version).ogg",
	"sounds/lobbyMusic/Dream Infinity.ogg",
	"sounds/lobbyMusic/Interstellar.ogg",
	"sounds/lobbyMusic/Tomorrow Landscape.ogg",
}
local OPEN_TRACK_NAME = 'sounds/lobbyMusic/The Secret of Ayers Rock.ogg'

-- load custom game dependent music
if WG.Chobby then
	if WG.Chobby.Configuration.gameConfig.randomTrackList then
		randomTrackList = WG.Chobby.Configuration.gameConfig.randomTrackList
		if not randomTrackList[1] then
			return
		end
	end
	if WG.Chobby.Configuration.gameConfig.openTrack ~= nil then
		OPEN_TRACK_NAME = WG.Chobby.Configuration.gameConfig.openTrack
		if not OPEN_TRACK_NAME or OPEN_TRACK_NAME == '' then
			OPEN_TRACK_NAME = randomTrackList[math.random(#randomTrackList)]
		end
	end
end

local function GetRandomTrack(previousTrack)
	local trackCount = #randomTrackList
	local previousTrackIndex
	if previousTrack then
		for i = 1, #randomTrackList do
			if randomTrackList[i] == previousTrack then
				trackCount = trackCount - 1
				previousTrackIndex = i
				break 
			end
		end
	end
	
	local randomTrack = math.ceil(math.random()*trackCount)
	if randomTrack == previousTrackIndex then
		randomTrack = trackCount + 1
	end
	return randomTrackList[randomTrack]
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function StartTrack(trackName, volume)
	trackName = trackName or GetRandomTrack(previousTrack)
	volume = volume or WG.Chobby.Configuration.menuMusicVolume
	Spring.Echo("Starting Track", trackName, volume)
	if volume == 0 then
		return
	end
	Spring.StopSoundStream()
	Spring.PlaySoundStream(trackName, volume)
	playingTrack = true
end

local function LoopTrack(trackName, trackNameIntro, volume)
	trackNameIntro = trackNameIntro or trackName
	loopTrack = trackName
	StartTrack(trackNameIntro, volume)
end

local function StopTrack()
	Spring.StopSoundStream()
	playingTrack = false
	loopTrack = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local function SetTrackVolume(volume)
	if volume == 0 then
		StopTrack()
		return
	end
	if playingTrack then
		Spring.SetSoundStreamVolume(volume)
		return
	end
	StartTrack(GetRandomTrack(), volume)
	previousTrack = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local firstActivation = true
local ingame = false

function widget:Update()

	if ingame or (WG.Chobby.Configuration.menuMusicVolume == 0 )then
		return
	end
	
	if not playingTrack then
		return	
	end
	
	local playedTime, totalTime = Spring.GetSoundStreamTime()
	playedTime = math.floor(playedTime)
	totalTime = math.floor(totalTime)

	if (playedTime >= totalTime) then
		local newTrack = loopTrack or GetRandomTrack(previousTrack)
		StartTrack(newTrack)
		previousTrack = newTrack
	end
end

local MusicHandler = {
	StartTrack = StartTrack,
	StopTrack = StopTrack,
	LoopTrack = LoopTrack
}

-- Called just before the game loads
-- This could be used to implement music in the loadscreen
--function widget:GamePreload()
--	-- Ingame, no longer any of our business
--	if Spring.GetGameName() ~= "" then
--		ingame = true
--		StopTrack()
--	end
--end

-- called when returning to menu from a game
function widget:ActivateMenu()
	ingame = false
	if firstActivation then
		StartTrack(OPEN_TRACK_NAME)
		previousTrack = OPEN_TRACK_NAME
		firstActivation = false
		return
	end
	-- start playing music again
	local newTrack = GetRandomTrack(previousTrack)
	StartTrack(newTrack)
	previousTrack = newTrack
end

function widget:Initialize()

	math.randomseed(os.clock() * 100)
	
	local Configuration = WG.Chobby.Configuration

	local function onConfigurationChange(listener, key, value)
		if key == "menuMusicVolume" then
			SetTrackVolume(value)
		end
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	local function OnBattleAboutToStart()
		ingame = true
		StopTrack()
	end
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	
	WG.MusicHandler = MusicHandler
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------