--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Download Handler",
		desc      = "Part of a mess of code that handles downloads",
		author    = "GoogleFrog",
		date      = "10 April 2017",
		license   = "GPL-v2",
		layer     = 0,
		handler   = true,
		api       = true,
		enabled   = true,
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

local externalFunctions = {}

function externalFunctions.DownloadFinished(name, fileType, success)
	widgetHandler:DownloadFinished()
	Spring.Echo("Backup Download Finished", name, fileType, success)
	Chotify:Post({
		title = "Download " .. ((success and "Finished") or "Failed"),
		body = (name or "???") .. " of type " .. (fileType or "???"),
	})
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function TestDownload()
	WG.WrapperLoopback.DownloadFile("sands_of_time_v1.0", "MAP")
	Spring.Echo("TestDownload")
	Chotify:Post({
		title = "Download Failed",
		body = "Starting backup download for " .. ("sands_of_time_v1.0" or "???"),
	})
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.DownloadHandler = externalFunctions
	WG.Delay(TestDownload, 10)
end
