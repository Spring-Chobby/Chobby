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

local externalFunctions = {}
local listeners = {}
local wrapperFunctions = {}

local downloadQueue = {} -- {name, fileType, priority, id}
local downloadCount = 0
local topPriority = 0
local removedDownloads = {}

local requestUpdate = false

-- Wrapper types are RAPID, MAP, MISSION, DEMO, ENGINE, NOTKNOWN
local typeMap = {
	game = "RAPID",
	map = "MAP",
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local function CallListeners(event, ...)
	if listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = Spring.Utilities.ShallowCopy(listeners[event])
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		args = {...}
		xpcall(function() listener(listener, unpack(args)) end,
			function(err) Spring.Echo("Campaign Listener Error", err) end )
	end
	return true
end

function externalFunctions.AddListener(event, listener)
	if listener == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function externalFunctions.RemoveListener(event, listener)
	if listeners[event] then
		for k, v in pairs(listeners[event]) do
			if v == listener then
				table.remove(listeners[event], k)
				if #listeners[event] == 0 then
					listeners[event] = nil
				end
				break
			end
		end
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Utilities

local function DownloadSortFunc(a, b)
	return a.priority > b.priority or (a.priority == b.priority and a.index < b.index)
end

local function DownloadQueueUpdate()
	requestUpdate = false
	
	if #downloadQueue == 0 then
		CallListeners("DownloadUpdate", downloadQueue, removedDownloads)
		return
	end
	table.sort(downloadQueue, DownloadSortFunc)
	
	local front = downloadQueue[1]
	if not front.active then
		if WG.WrapperLoopback then
			WG.WrapperLoopback.DownloadFile(front.name, typeMap[front.fileType])
		else
			VFS.DownloadArchive(front.name, front.fileType)
		end
	end
	
	CallListeners("DownloadUpdate", downloadQueue, removedDownloads)
end

local function GetDownloadIndex(downloadList, name, fileType)
	for i = 1, #downloadList do
		local data = downloadList[i]
		if data.name == name and data.fileType == fileType then
			return i
		end
	end
	return nil
end

local function RemoveDownload(name, fileType, putInRemoveList, removalType)
	local index = GetDownloadIndex(downloadQueue, name, fileType)
	if not index then
		return false
	end
	
	if putInRemoveList then
		downloadQueue[index].removalType = removalType
		removedDownloads[#removedDownloads + 1] = downloadQueue[index]
	end
	downloadQueue[index] = downloadQueue[#downloadQueue]
	downloadQueue[#downloadQueue] = nil
	requestUpdate = true
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Externals Functions

function externalFunctions.QueueDownload(name, fileType, priorty)
	priorty = priorty or 1
	if priorty == -1 then
		priorty = topPriority + 1
	end
	if topPriority < priority then
		topPriority = priority
	end
	
	local index = GetDownloadIndex(downloadQueue, name, fileType)
	if index then
		local data = downloadQueue[index]
		if priority > data.priority then
			data.priority = priority
			requestUpdate = true
		end
		return
	end
	
	downloadCount = downloadCount + 1
	downloadQueue[#downloadQueue + 1] = {
		name = name,
		fileType = fileType,
		priorty = priorty,
		id = downloadCount,
	}
	requestUpdate = true
end

function externalFunctions.SetDownloadTopPriority(name, fileType)
	local index = GetDownloadIndex(downloadQueue, name, fileType)
	if not index then
		return
	end
	
	topPriority = topPriority + 1
	downloadQueue[index].priority = topPriority
	requestUpdate = true
	return true
end

function externalFunctions.CancelDownload(name, fileType)
	RemoveDownload(name, fileType, true, "cancel")
end

function externalFunctions.RetryDownload(name, fileType)
	local index = GetDownloadIndex(removedDownloads, name, fileType)
	if not index then
		return false
	end
	
	externalFunctions.QueueDownload(name, fileType, removedDownloads[index].priority)
	removedDownloads[index] = removedDownloads[#removedDownloads]
	removedDownloads[#removedDownloads] = nil
	requestUpdate = true
	return true
end

function externalFunctions.RemoveRemovedDownload(name, fileType)
	local index = GetDownloadIndex(removedDownloads, name, fileType)
	if not index then
		return false
	end
	
	removedDownloads[index] = removedDownloads[#removedDownloads]
	removedDownloads[#removedDownloads] = nil
	requestUpdate = true
	return true
end


function externalFunctions.MaybeDownloadArchive(name, archiveType, priorty)
	if not VFS.HasArchive(name) then
		externalFunctions.QueueDownload(name, archiveType, priorty)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Wrapper Interface

function wrapperFunctions.DownloadFinished(name, fileType, success)
	RemoveDownload(name, fileType, true, (success and "success") or "fail")
	
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
	WG.WrapperLoopback.DownloadFile("Sands of Time v1.0", "MAP")
	Spring.Echo("TestDownload")
	Chotify:Post({
		title = "Download Failed",
		body = "Starting backup download for " .. ("Sands of Time v1.0" or "???"),
	})
end

function widget:Initialize()
	CHOBBY_DIR = LUA_DIRNAME .. "widgets/chobby/"
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.DownloadWrapperInterface = wrapperFunctions
	WG.DownloadHandler = externalFunctions
	--WG.Delay(TestDownload, 2)
end

function widget:Update()
	if requestUpdate then
		DownloadQueueUpdate()
	end
end
