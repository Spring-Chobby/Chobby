--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Mission Launcher",
		desc      = "Launches missions, gets results",
		author    = "KingRaptor",
		version   = "1.0",
		date      = "2016.07.16",
		license   = "GNU GPL, v2 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
  }
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local RESULTS_FILE = "cache/mission_results.lua"	-- TODO: config?
local RESULTS_QUERY_PERIOD = 0.1

local results = {}
local listeners = {}
local waitingForResults = false
local timer = 0

local function RemoveResultsFile()
	if VFS.FileExists(RESULTS_FILE) then
		os.remove(RESULTS_FILE)
	end
end

local function LaunchMission(startscript, listenerFunc)
	listeners[#listeners + 1] = listenerFunc
	RemoveResultsFile()	
	results = {}
	Spring.Start(startscript, "")
	waitingForResults = true
end

local function GetResults()
	return Spring.Utilities.CopyTable(results)
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local function LoadResults()
	if VFS.FileExists(RESULTS_FILE) then
		results = VFS.Include(RESULTS_FILE)
		--RemoveResultsFile()
		waitingForResults = false
		
		for i,listener in pairs(listeners) do
			if (type(listener) == 'function') then
				listener(results)
			end
		end
		listeners = {}
		
		return results
	end
end

-- periodically query for results
function widget:Update(dt)
	timer = timer + dt
	if (timer > RESULTS_QUERY_PERIOD) then
		LoadResults()
		timer = 0
	end
end

function widget:Initialize()
	WG.MissionLauncher = {
		GetResults = GetResults,
		LoadResults = LoadResults,
		LaunchMission = LaunchMission
	}
end

function widget:Shutdown()
	WG.MissionLauncher = nil
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------