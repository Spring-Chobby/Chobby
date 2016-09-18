--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Queue status panel",
		desc      = "Displays queue status.",
		author    = "GoogleFrog",
		date      = "11 September 2016",
		license   = "GNU LGPL, v2.1 or later",
		layer     = 0,
		enabled   = true  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Variables
local queueStatusHandler -- global for timer update
local readyCheckPopup 
local findingMatch = false

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialization

local function InitializeQueueStatusHandler(parentControl)
	local lobby = WG.LibLobby.lobby

	local button = Button:New {
		name = "cancel",
		x = "68%",
		right = 4,
		y = 4,
		bottom = 4,
		padding = {0,0,0,0},
		caption = "Cancel",
		font = WG.Chobby.Configuration:GetFont(3),
		classname = "negative_button",
		OnClick = {
			function()
				lobby:LeaveMatchMakingAll()
			end
		},
		parent = parentControl,
	}
	
	local rightBound = "33%"
	local bottomBound = 12
	local queueText = nil
	local bigMode = true
	local queueTimer = Spring.GetTimer()
	
	local timeWaiting = 0
	local queueString = ""
	local playersString = ""
	
	local queueStatusText = TextBox:New {
		x = 8,
		y = 12,
		right = rightBound,
		bottom = bottomBound,
		fontsize = WG.Chobby.Configuration:GetFont(2).size,
		text = "",
		parent = parentControl
	}
	
	local externalFunctions = {}
	
	function externalFunctions.ResetTimer()
		queueTimer = Spring.GetTimer()
	end
	
	function externalFunctions.UpdateTimer(forceUpdate)
		if not queueTimer then
			return
		end
		local newTimeWaiting = math.floor(Spring.DiffTimers(Spring.GetTimer(),queueTimer))
		if (not forceUpdate) and timeWaiting == newTimeWaiting then
			return
		end
		timeWaiting = newTimeWaiting
		queueStatusText:SetText(queueText .. ((bigMode and  "\nTime Waiting: ") or ", Wait: ") .. timeWaiting .. "s")
	end
	
	local function UpdateQueueText()
		queueText = ((bigMode and "Searching: ") or "Search: ") .. queueString .. ((bigMode and  "\nPlayers: ") or "\nPlay: ") .. playersString
		externalFunctions.UpdateTimer(true)
	end
	
	function externalFunctions.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
		local firstQueue = true
		playersString = ""
		queueString = ""
		for i = 1, #joinedQueueList do
			if not firstQueue then
				queueString = queueString .. ", "
				playersString = playersString .. ", "
			end
			playersString = playersString .. ((queueCounts and queueCounts[joinedQueueList[i]]) or 0)
			firstQueue = false
			queueString = queueString .. joinedQueueList[i] 
		end
		
		UpdateQueueText()
	end
	
	function externalFunctions.Resize(xSize, ySize)
		queueStatusText._relativeBounds.right = rightBound
		queueStatusText._relativeBounds.bottom = bottomBound
		queueStatusText:UpdateClientArea()
		if ySize < 60 then
			queueStatusText:SetPos(6, 4)
			bigMode = false
		else
			queueStatusText:SetPos(8, 13)
			bigMode = true
		end
		UpdateQueueText()
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Ready Check Popup

local function CreateReadyCheckWindow(secondsRemaining)
	local Configuration = WG.Chobby.Configuration
	
	local readyCheckWindow = Window:New {
		caption = "",
		name = "readyCheckWindow",
		parent = screen0,
		width = 310,
		height = 310,
		resizable = false,
		draggable = false,
		classname = "overlay_window",
	}

	local title = Label:New {
		x = 40,
		right = 0,
		y = 15,
		height = 35,
		caption = i18n("match_found"),
		font = Configuration:GetFont(4),
		parent = readyCheckWindow,
	}

	local statusLabel = Label:New {
		x = 30,
		width = 200,
		y = 75,
		height = 35,
		caption = "",
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local playersAcceptedLabel = Label:New {
		x = 30,
		width = 200,
		y = 120,
		height = 35,
		caption = "Players accepted: 0",
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
	}

	local acceptRegistered = false
	local displayTimer = true
	local startTimer = Spring.GetTimer()
	local timeRemaining = secondsRemaining
	
	local function DoDispose()
		if readyCheckWindow then
			readyCheckWindow:Dispose()
			readyCheckWindow = nil	
		end
	end
	
	local function CancelFunc()
		lobby:RejectMatchMakingMatch()
		statusLabel:SetCaption(Configuration:GetErrorColor() .. "Rejected match")
		displayTimer = false
		WG.Delay(DoDispose, 1)
	end

	local function AcceptFunc()
		lobby:AcceptMatchMakingMatch()
	end

	local buttonAccept = Button:New {
		right = 150,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("accept"),
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
		classname = "action_button",
		OnClick = {
			function()
				AcceptFunc()
			end
		},
	}

	local buttonReject = Button:New {
		right = 1,
		width = 135,
		bottom = 1,
		height = 70,
		caption = i18n("reject"),
		font = Configuration:GetFont(3),
		parent = readyCheckWindow,
		classname = "negative_button",
		OnClick = {
			function()
				RejectFunc()
			end
		},
	}

	local popupHolder = WG.Chobby.PriorityPopup(readyCheckWindow, RejectFunc, AcceptFunc, screen0)
	
	local externalFunctions = {}
	
	function externalFunctions.UpdateTimer()
		local newTimeRemaining = secondsRemaining - math.ceil(Spring.DiffTimers(Spring.GetTimer(), startTimer))
		if newTimeRemaining < 0 then
			DoDispose()
		end
		if not displayTimer then
			return
		end
		if timeRemaining == newTimeRemaining then
			return
		end
		timeRemaining = newTimeRemaining
		statusLabel:SetCaption(((acceptRegistered and "Waiting for players ") or "Accept in ") .. timeRemaining .. "s")
	end
	
	function externalFunctions.UpdatePlayerCount(readyPlayers)
		-- queueReadyCounts is not a useful number.
		playersAcceptedLabel:SetCaption("Players accepted: " .. readyPlayers)
	end
	
	function externalFunctions.AcceptRegistered()
		if acceptRegistered then
			return
		end
		acceptRegistered = true
		statusLabel:SetCaption("Waiting for players " .. (timeRemaining or "time error") .. "s")
		
		buttonAccept:Hide()
		
		buttonReject:SetPos(nil, nil, 90, 60)
		buttonReject._relativeBounds.right = 1
		buttonReject._relativeBounds.bottom = 1
		buttonReject:UpdateClientArea()
	end
	
	function externalFunctions.MatchMakingComplete(success)
		if success then
			statusLabel:SetCaption(Configuration:GetSuccessColor() .. "Battle starting")
		else
			statusLabel:SetCaption(Configuration:GetErrorColor() .. "Match rejected")
		end
		displayTimer = false
		WG.Delay(DoDispose, 1)
	end
	
	return externalFunctions
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- External functions

local QueueStatusPanel = {}

function QueueStatusPanel.GetControl()
	local lobby = WG.LibLobby.lobby
	
	local queuePanel = Panel:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		caption = "",
		resizable = false,
		draggable = false,
		OnResize = {
			function (obj, xSize, ySize)
				if queueStatusHandler then
					queueStatusHandler.Resize(xSize, ySize)
				end
			end
		}
	}
	
	queueStatusHandler = InitializeQueueStatusHandler(queuePanel)
	
	lobby:AddListener("OnMatchMakerStatus", 
		function(listener, inMatchMaking, joinedQueueList, queueCounts, currentEloWidth, joinedTime, bannedTime)
			findingMatch = inMatchMaking
			
			if inMatchMaking then
				
				if not queuePanel.visible then
					queueStatusHandler.ResetTimer()
				end
				queueStatusHandler.UpdateMatches(joinedQueueList, queueCounts, currentEloWidth, joinedTime)
			end
			queuePanel:SetVisibility(inMatchMaking)
		end
	)
	
	local function OnMatchMakerReadyCheck(_, secondsRemaining)
		if not readyCheckPopup then
			readyCheckPopup = CreateReadyCheckWindow(secondsRemaining)
		end
	end
	
	local function OnMatchMakerReadyUpdate(_, readyAccepted, likelyToPlay, queueReadyCounts, battleSize, readyPlayers)
		if readyAccepted then
			readyCheckPopup.AcceptRegistered()
		end
		if readyPlayers then
			readyCheckPopup.UpdatePlayerCount(readyPlayers)
		end
	end
	
	local function OnMatchMakerReadyResult(_, isBattleStarting, areYouBanned)
		readyCheckPopup.MatchMakingComplete(isBattleStarting)
	end
	
	lobby:AddListener("OnMatchMakerReadyCheck", OnMatchMakerReadyCheck)
	lobby:AddListener("OnMatchMakerReadyUpdate", OnMatchMakerReadyUpdate)
	lobby:AddListener("OnMatchMakerReadyResult", OnMatchMakerReadyResult)
	
	return queuePanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Widget Interface

function widget:Update(dt)
	if queueStatusHandler and findingMatch then
		queueStatusHandler.UpdateTimer()
	end
	if readyCheckPopup then
		readyCheckPopup.UpdateTimer()
	end
end

function widget:Initialize()
	VFS.Include(LUA_DIRNAME .. "widgets/chobby/headers/exports.lua", nil, VFS.RAW_FIRST)

	WG.QueueStatusPanel = QueueStatusPanel
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
