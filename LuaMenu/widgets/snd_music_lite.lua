--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
--	file:		gui_music.lua
--	brief:	yay music
--	author:	cake
--
--	Copyright (C) 2007.
--	Licensed under the terms of the GNU GPL, v2 or later.
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name	= "Music Player Lite",
		desc	= "Plays music for ingame lobby client",
		author	= "cake, trepan, Smoth, Licho, xponen",
		date	= "Mar 01, 2008, Aug 20 2009, Nov 23 2011",
		license	= "GNU GPL, v2 or later",
		layer	= 0,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

options_path = 'Settings/Audio'
options = {
	useIncludedTracks = {
		name = "Use Included Tracks",
		type = 'bool',
		value = true,
		desc = 'Use the tracks included with Zero-K',
		noHotkey = true,
	},
}

local windows = {}

local warThreshold = 5000
local peaceThreshold = 1000
local PLAYLIST_FILE = 'sounds/music/playlist.lua'
local LOOP_BUFFER = 0.015	-- if looping track is this close to the end, go ahead and loop
local UPDATE_PERIOD = 1

local musicType = 'lobby'
local timeframetimer = 0
local timeframetimer_short = 0
local loopTrack = ''
local previousTrack = ''
local previousTrackType = ''
local newTrackWait = 1000
local fadeVol
local curTrack	= "no name"
local songText	= "no name"
local haltMusic = false
local looping = false
local paused = false
local lastTrackTime = -1

local warTracks, peaceTracks, briefingTracks, victoryTracks, defeatTracks

local firstTime = false
local wasPaused = false
local firstFade = true
local initSeed = 0
local initialized = false

local timer = Spring.GetTimer()
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function GetMusicType()
	return musicType
end

local function StartLoopingTrack(trackInit, trackLoop)
	if not (VFS.FileExists(trackInit) and VFS.FileExists(trackLoop)) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Missing one or both tracks for looping")
	end
	haltMusic = true
	Spring.StopSoundStream()
	musicType = 'custom'
	
	curTrack = trackInit
	loopTrack = trackLoop
	Spring.PlaySoundStream(trackInit, WG.music_volume or 0.5)
	looping = 0.5
end

local function StartTrack(track)
	haltMusic = false
	looping = false
	Spring.StopSoundStream()
	
	local newTrack = previousTrack
	if track then
		newTrack = track	-- play specified track
		musicType = 'custom'
	else
		local tries = 0
		repeat
			if (#lobbyTracks == 0) then return end
			newTrack = lobbyTracks[math.random(1, #lobbyTracks)]
			tries = tries + 1
		until newTrack ~= previousTrack or tries >= 10
		musicType = 'lobby'
	end
	-- for key, val in pairs(oggInfo) do
		-- Spring.Echo(key, val)	
	-- end
	firstFade = false
	previousTrack = newTrack
	
	-- if (oggInfo.comments.TITLE and oggInfo.comments.TITLE) then
		-- Spring.Echo("Song changed to: " .. oggInfo.comments.TITLE .. " By: " .. oggInfo.comments.ARTIST)
	-- else
		-- Spring.Echo("Song changed but unable to get the artist and title info")
	-- end
	curTrack = newTrack
	Spring.PlaySoundStream(newTrack,WG.music_volume or 0.5)
	
	WG.music_start_volume = WG.music_volume
end

local function StopTrack(noContinue)
	looping = false
	Spring.StopSoundStream()
	if noContinue then
		haltMusic = true
	else
		haltMusic = false
		StartTrack()
	end
end

function widget:Update()
	if gameOver then
		return
	end
	
	local currentTime = Spring.GetTimer()
	local dt = Spring.DiffTimers(currentTime, timer)
	
	if not initialized then
		math.randomseed(os.clock()* 100)
		initialized=true
		-- these are here to give epicmenu time to set the values properly
		-- (else it's always default at startup)
		if VFS.FileExists(PLAYLIST_FILE, VFS.RAW_FIRST) then
			local tracks = VFS.Include(PLAYLIST_FILE, nil, VFS.RAW_FIRST)
			lobbyTracks = tracks.lobby
		end
		
		local vfsMode = (options.useIncludedTracks.value and VFS.RAW_FIRST) or VFS.RAW
		lobbyTracks	= warTracks or VFS.DirList('sounds/music/lobby/', '*.ogg', vfsMode)
	end
	
	timeframetimer_short = timeframetimer_short + dt
	if timeframetimer_short > 0.03 then
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = tonumber( ("%.2f"):format(playedTime) )
		paused = (playedTime == lastTrackTime)
		lastTrackTime = playedTime
		if looping then
			if looping == 0.5 then
				looping = 1
			elseif playedTime >= totalTime - LOOP_BUFFER then
				Spring.StopSoundStream()
				Spring.PlaySoundStream(loopTrack,WG.music_volume or 0.5)
			end
		end
		timeframetimer_short = 0
	end
	
	timeframetimer = timeframetimer + dt
	if (timeframetimer > UPDATE_PERIOD) then	-- every second
		timeframetimer = 0
		newTrackWait = newTrackWait + 1
		
		if (not firstTime) then
			StartTrack()
			firstTime = true -- pop this cherry	
		end
		
		local playedTime, totalTime = Spring.GetSoundStreamTime()
		playedTime = math.floor(playedTime)
		totalTime = math.floor(totalTime)
		--Spring.Echo(playedTime, totalTime)
		
		--Spring.Echo(playedTime, totalTime, newTrackWait)
		
		--if((totalTime - playedTime) <= 6 and (totalTime >= 1) ) then
			--Spring.Echo("time left:", (totalTime - playedTime))
			--Spring.Echo("volume:", (totalTime - playedTime)/6)
			--if ((totalTime - playedTime)/6 >= 0) then
			--	Spring.SetSoundStreamVolume((totalTime - playedTime)/6)
			--else
			--	Spring.SetSoundStreamVolume(0.1)
			--end
		--elseif(playedTime <= 5 )then--and not firstFade
			--Spring.Echo("time playing:", playedTime)
			--Spring.Echo("volume:", playedTime/5)
			--Spring.SetSoundStreamVolume( playedTime/5)
		--end
		--Spring.Echo(previousTrackType, musicType)
		if (playedTime >= totalTime)	-- both zero means track stopped
		 and not(haltMusic or looping) then
			previousTrackType = musicType
			StartTrack()
			
			--Spring.Echo("Track: " .. newTrack)
			newTrackWait = 0
		end
	end
	
	timer = currentTime
end

function widget:Initialize()
	WG.Music = WG.Music or {}
	WG.Music.StartTrack = StartTrack
	WG.Music.StartLoopingTrack = StartLoopingTrack
	WG.Music.StopTrack = StopTrack
	WG.Music.GetMusicType = GetMusicType

	-- Spring.Echo(math.random(), math.random())
	-- Spring.Echo(os.clock())
 
	-- for TrackName,TrackDef in pairs(peaceTracks) do
		-- Spring.Echo("Track: " .. TrackDef)	
	-- end
	--math.randomseed(os.clock()* 101.01)--lurker wants you to burn in hell rgn
	-- for i=1,20 do Spring.Echo(math.random()) end
end

function widget:Shutdown()
	Spring.StopSoundStream()
	WG.Music = nil
	
	for i=1,#windows do
		(windows[i]):Dispose()
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------